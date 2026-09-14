#!/usr/bin/env bash
# PostToolUse フック（Claude Code、matcher: "Edit|Write"）:
# エージェントが編集したファイルを軽量ログに追記する。
#
# /review-knowledge が「よく触っているのに記録が無いモジュール」を洗い出すための材料。
# fire-and-forget で動き、失敗しても本体の動作には影響しない。
# ロジックは Cursor 版（../log-activity.sh）と同じだが、ファイルパスの取り出し先が異なる。
#
# 入力 (stdin): {"tool_name":"Edit","tool_input":{"file_path":"<絶対パス>", ...}, ...}
#              （"file_path" がトップレベルにある形式にも後方互換で対応する）
# 出力 (stdout): {}

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=_hook-lib.sh
. "${SCRIPT_DIR}/_hook-lib.sh"

INPUT="$(cat 2>/dev/null || true)"

BASE="$(ckms_detect_base)"
[ -n "$BASE" ] || ckms_noop_exit

FILE_PATH="$(printf '%s' "$INPUT" \
  | sed -n 's/.*"tool_input"[[:space:]]*:[[:space:]]*{[^}]*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  | head -n 1)"
if [ -z "$FILE_PATH" ]; then
  FILE_PATH="$(printf '%s' "$INPUT" \
    | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
    | head -n 1)"
fi
[ -n "$FILE_PATH" ] || ckms_noop_exit

# 知識ベース自身の編集は記録しない（記録行為でログが埋まるのを避ける）
case "$FILE_PATH" in
  *"/${BASE}/"*|"${BASE}/"*) ckms_noop_exit ;;
esac

# プロジェクトルートからの相対パスに正規化する
REL_PATH="${FILE_PATH#"$PWD"/}"

LOG="${BASE}/knowledge-activity.log"
MAX_LINES="$(ckms_conf "$BASE" activity_log_max_lines 500)"
case "$MAX_LINES" in
  ''|*[!0-9]*) MAX_LINES=500 ;;
esac

{
  printf '%s\t%s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$REL_PATH" >> "$LOG"

  # ログが膨らみすぎないよう末尾だけ残す
  line_count=$(wc -l < "$LOG" 2>/dev/null | tr -d ' ')
  if [ -n "$line_count" ] && [ "$line_count" -gt "$MAX_LINES" ]; then
    tail -n "$MAX_LINES" "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
  fi
} 2>/dev/null || true

printf '{}'
