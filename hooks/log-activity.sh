#!/usr/bin/env bash
# afterFileEdit フック: エージェントが編集したファイルを軽量ログに追記する。
#
# /review-knowledge が「よく触っているのに記録が無いモジュール」を洗い出すための材料。
# fire-and-forget で動き、失敗しても本体の動作には影響しない。
#
# 入力 (stdin): {"file_path": "<絶対パス>", "edits": [...]}
# 出力 (stdout): {}

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=_hook-lib.sh
. "${SCRIPT_DIR}/_hook-lib.sh"

INPUT="$(cat 2>/dev/null || true)"

BASE="$(ckms_detect_base)"
[ -n "$BASE" ] || ckms_noop_exit

FILE_PATH="$(printf '%s' "$INPUT" \
  | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  | head -n 1)"
[ -n "$FILE_PATH" ] || ckms_noop_exit

# バックスラッシュ区切りのパス（Windows ネイティブな渡され方をした場合）を
# 正規化する。通常は Git Bash / WSL の POSIX パスが渡ってくるはずだが、
# 念のための防御。
FILE_PATH="${FILE_PATH//\\//}"

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

LINE="$(printf '%s\t%s' "$(date +%Y-%m-%dT%H:%M:%S)" "$REL_PATH")"
ckms_append_and_trim_log "$LOG" "$LINE" "$MAX_LINES" 2>/dev/null || true

printf '{}'
