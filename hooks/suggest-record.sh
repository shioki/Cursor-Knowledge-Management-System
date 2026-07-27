#!/usr/bin/env bash
# stop フック: 記録に値する作業をしたのに何も残していない場合、記録を促す。
#
# followup_message は次のユーザーメッセージとして自動送信され、1 ターンを消費する。
# そのため既定では無効。有効にするには <base>/knowledge-hooks.conf に次を書く:
#
#   suggest_record = true
#
# 入力 (stdin): {"status": "completed"|"aborted"|"error", "loop_count": N}
# 出力 (stdout): {"followup_message": "..."} または {}

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=_hook-lib.sh
. "${SCRIPT_DIR}/_hook-lib.sh"

INPUT="$(cat 2>/dev/null || true)"

BASE="$(ckms_detect_base)"
[ -n "$BASE" ] || ckms_noop_exit

[ "$(ckms_conf "$BASE" suggest_record false)" = "true" ] || ckms_noop_exit

STATUS="$(printf '%s' "$INPUT" \
  | sed -n 's/.*"status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
[ "$STATUS" = "completed" ] || ckms_noop_exit

LOOP_COUNT="$(printf '%s' "$INPUT" \
  | sed -n 's/.*"loop_count"[[:space:]]*:[[:space:]]*\([0-9]*\).*/\1/p' | head -n 1)"
[ -z "$LOOP_COUNT" ] || [ "$LOOP_COUNT" -eq 0 ] || ckms_noop_exit

LOG="${BASE}/knowledge-activity.log"
[ -f "$LOG" ] || ckms_noop_exit

MIN_FILES="$(ckms_conf "$BASE" suggest_min_files 3)"
case "$MIN_FILES" in
  ''|*[!0-9]*) MIN_FILES=3 ;;
esac

TODAY="$(date +%Y-%m-%d)"
EDITED=$(grep -c "^${TODAY}" "$LOG" 2>/dev/null || printf '0')
[ "$EDITED" -ge "$MIN_FILES" ] || ckms_noop_exit

# 直近の編集より後に記録されたファイルがあれば、既に記録済みとみなす
DECISIONS_DIR="${BASE}/skills/knowledge-management/references/decisions"
if [ -d "$DECISIONS_DIR" ]; then
  RECENT=$(find "$DECISIONS_DIR" -maxdepth 1 -name '*.md' ! -name 'README.md' -newer "$LOG" 2>/dev/null | head -n 1)
  [ -z "$RECENT" ] || ckms_noop_exit
fi

MESSAGE="今回の作業で ${EDITED} 件のファイル編集がありましたが、技術判断の記録が追加されていません。設計上の選択をした場合は /record-decision で記録してください。記録するほどの判断がなければ「不要」と答えてこの提案を無視してください。"

printf '{"followup_message":"%s"}' "$(printf '%s' "$MESSAGE" | ckms_json_escape)"
