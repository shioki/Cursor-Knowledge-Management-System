#!/usr/bin/env bash
# sessionStart フック: 蓄積済み知識の索引を会話の初期コンテキストへ注入する。
#
# 個々の知識ファイルは読み込まない。「何がどこにあるか」だけを渡し、
# 実際の読み込みはエージェントが必要と判断したときにさせる。
#
# 入力 (stdin): {"session_id": "...", "is_background_agent": bool, "composer_mode": "..."}
# 出力 (stdout): {"additional_context": "..."} または {}

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=_hook-lib.sh
. "${SCRIPT_DIR}/_hook-lib.sh"

cat > /dev/null 2>&1 || true

BASE="$(ckms_detect_base)"
[ -n "$BASE" ] || ckms_noop_exit

MAX_ENTRIES="$(ckms_conf "$BASE" index_max_entries 30)"
case "$MAX_ENTRIES" in
  ''|*[!0-9]*) MAX_ENTRIES=30 ;;
esac

# カテゴリ内のファイルを「- ファイル名 — title」の形式で列挙する。
# Usage: list_category <ディレクトリ> <見出し>
list_category() {
  local dir="$1" heading="$2" count=0 total=0 file title
  [ -d "$dir" ] || return 0

  total=$(find "$dir" -maxdepth 1 -name '*.md' ! -name 'README.md' 2>/dev/null | wc -l | tr -d ' ')
  [ "$total" -gt 0 ] || return 0

  printf '\n### %s（%s 件）\n' "$heading" "$total"
  while IFS= read -r file; do
    [ "$count" -lt "$MAX_ENTRIES" ] || break
    title="$(ckms_read_title "$file")"
    if [ -n "$title" ]; then
      printf -- '- `%s` — %s\n' "$(basename "$file")" "$title"
    else
      printf -- '- `%s`\n' "$(basename "$file")"
    fi
    count=$((count + 1))
  done <<< "$(find "$dir" -maxdepth 1 -name '*.md' ! -name 'README.md' 2>/dev/null | sort -r)"

  if [ "$total" -gt "$count" ]; then
    printf -- '- （ほか %s 件。ディレクトリを一覧して確認してください）\n' "$((total - count))"
  fi
}

BODY="$(
  list_category "${BASE}/skills/knowledge-management/references/decisions" "技術判断"
  list_category "${BASE}/skills/pattern-library/references/patterns" "実装パターン"
  list_category "${BASE}/skills/improvement-tracking/references/improvements" "改善記録"
  list_category "${BASE}/debug-sessions" "デバッグセッション"
)"

[ -n "$BODY" ] || ckms_noop_exit

CONTEXT="$(
  printf '## このプロジェクトに蓄積済みの知識（索引）\n'
  printf '\n'
  printf 'ベースディレクトリ: `%s/`\n' "$BASE"
  printf '%s\n' "$BODY"
  printf '\n'
  printf 'これは索引です。内容が必要になった時点で該当ファイルだけを読んでください。\n'
  printf '関連する判断やパターンが既にある作業では、まずここを参照してから提案してください。\n'
)"

printf '{"additional_context":"%s"}' "$(printf '%s' "$CONTEXT" | ckms_json_escape)"
