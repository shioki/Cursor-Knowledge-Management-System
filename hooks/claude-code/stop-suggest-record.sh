#!/usr/bin/env bash
# Stop フック（Claude Code）: 記録に値する作業をしたのに何も残していない場合、記録を促す。
#
# 発火条件は Cursor 版（../suggest-record.sh）と同じ。<base>/knowledge-hooks.conf に
#   suggest_record = true
# が無い限り既定では無効。
#
# Cursor 版は followup_message（次のユーザーメッセージとして自動送信）を使うが、
# Claude Code の Stop hook にはその仕組みが無いため、代わりに Stop のブロック機構
# （decision: "block" + reason）で「まだ続けるべき理由」として同じ文面を渡す。
# 挙動が完全に同じではない点に注意（次ターン送信ではなく、応答の継続を促す形になる）。
#
# 入力 (stdin): Claude Code の Stop イベント JSON（status 相当のフィールド名は
#              バージョンによって異なりうるため、本スクリプトは活動ログの日付だけで判定する）
# 出力 (stdout): {"decision":"block","reason":"..."} または {}

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../_hook-lib.sh
. "${SCRIPT_DIR}/../_hook-lib.sh"

INPUT="$(cat 2>/dev/null || true)"

# この Stop イベント自体が、直前の Stop hook の block によって発生したものなら
# 再度 block しない（無限ループ防止）。stop_hook_active はドキュメント上の
# フィールド名を推測で使っているため、導入後に実機で無限ループしないか確認すること。
case "$INPUT" in
  *'"stop_hook_active"'*':'*'true'*) ckms_noop_exit ;;
esac

BASE="$(ckms_detect_base)"
[ -n "$BASE" ] || ckms_noop_exit

[ "$(ckms_conf "$BASE" suggest_record false)" = "true" ] || ckms_noop_exit

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

MESSAGE="今回の作業で ${EDITED} 件のファイル編集がありましたが、技術判断の記録が追加されていません。設計上の選択をした場合は knowledge-management スキルの scripts/add-entry.sh で記録してください。記録するほどの判断がなければ、このまま応答を終えて構いません。"

printf '{"decision":"block","reason":"%s"}' "$(printf '%s' "$MESSAGE" | ckms_json_escape)"
