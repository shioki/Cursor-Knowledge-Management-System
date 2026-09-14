#!/usr/bin/env bash
# SessionStart フック（Claude Code）: 蓄積済み知識の索引を会話の初期コンテキストへ注入する。
#
# 索引の組み立ては ../_hook-lib.sh の ckms_build_knowledge_index が行う。
# Cursor 版は ../inject-knowledge-index.sh を参照（出力の JSON 形式が異なる）。
#
# 入力 (stdin): Claude Code の SessionStart イベント JSON（本スクリプトは中身を読まない）
# 出力 (stdout): {"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"..."}} または {}
#
# additionalContext の正確なキー名は Claude Code のバージョンによって変わる可能性がある。
# 導入後は「動作確認」（README.md 参照）で実際に会話へ注入されるか確認すること。

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../_hook-lib.sh
. "${SCRIPT_DIR}/../_hook-lib.sh"

cat > /dev/null 2>&1 || true

BASE="$(ckms_detect_base)"
[ -n "$BASE" ] || ckms_noop_exit

CONTEXT="$(ckms_build_knowledge_index "$BASE")"
[ -n "$CONTEXT" ] || ckms_noop_exit

ESCAPED="$(printf '%s' "$CONTEXT" | ckms_json_escape)"
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}' "$ESCAPED"
