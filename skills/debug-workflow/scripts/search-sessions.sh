#!/usr/bin/env bash
# debug-workflow: 過去のデバッグセッションをキーワード検索するスクリプト
#
# Usage: bash .agents/skills/debug-workflow/scripts/search-sessions.sh "キーワード"
#        （.claude/skills / .cursor/skills も検出対象）
#
# 引数:
#   $1 - 検索キーワード（必須）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# スキル配置の検出とエスケープ処理は project-setup の _skill-base.sh にある。
# gh skill / apm でスキルを個別に入れると、project-setup が無いことがある。
CKMS_SKILL_BASE="${SCRIPT_DIR}/../../project-setup/scripts/_skill-base.sh"
if [ ! -f "$CKMS_SKILL_BASE" ]; then
  echo "エラー: project-setup スキルが見つかりません: ${CKMS_SKILL_BASE}" >&2
  echo "      このスクリプトは project-setup の _skill-base.sh を使います。" >&2
  echo "      スキルを個別に入れた場合は、project-setup も同じ場所に入れてください。" >&2
  exit 1
fi
# shellcheck source=../../project-setup/scripts/_skill-base.sh
source "$CKMS_SKILL_BASE"

SESSIONS_DIR="${DATA_BASE}/debug-sessions"
KEYWORD="${1:?エラー: 検索キーワードを指定してください}"

if [ ! -d "$SESSIONS_DIR" ]; then
  echo "デバッグセッションディレクトリが見つかりません: $SESSIONS_DIR"
  echo "まだセッションが記録されていません。"
  exit 0
fi

echo "=== デバッグセッション検索: \"${KEYWORD}\" ==="
echo ""

FOUND=0
for file in "$SESSIONS_DIR"/*.md; do
  [ -f "$file" ] || continue
  # キーワードは文字列そのものとして探す。正規表現として扱うと、[ で
  # エラーになり（捨てているので「見つからない」になる）、\| や .* で無関係な
  # セッションまで当たる。
  if grep -qliF -- "$KEYWORD" "$file" 2>/dev/null; then
    FOUND=$((FOUND + 1))
    echo "--- $(basename "$file") ---"
    grep -n -i -F -- "$KEYWORD" "$file" | head -5
    echo ""
  fi
done

if [ "$FOUND" -eq 0 ]; then
  echo "該当するセッションが見つかりませんでした。"
else
  echo "=== ${FOUND} 件のセッションが見つかりました ==="
fi
