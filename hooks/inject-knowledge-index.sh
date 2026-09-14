#!/usr/bin/env bash
# sessionStart フック（Cursor）: 蓄積済み知識の索引を会話の初期コンテキストへ注入する。
#
# 索引の組み立ては hooks/_hook-lib.sh の ckms_build_knowledge_index が行う。
# Claude Code 版は hooks/claude-code/session-start.sh を参照（出力の JSON 形式が異なる）。
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

CONTEXT="$(ckms_build_knowledge_index "$BASE")"
[ -n "$CONTEXT" ] || ckms_noop_exit

printf '{"additional_context":"%s"}' "$(printf '%s' "$CONTEXT" | ckms_json_escape)"
