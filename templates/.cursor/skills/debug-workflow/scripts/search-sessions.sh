#!/usr/bin/env bash
# debug-workflow: 過去のデバッグセッションをキーワード検索するスクリプト
#
# Usage: bash .cursor/skills/debug-workflow/scripts/search-sessions.sh "キーワード"
#
# 引数:
#   $1 - 検索キーワード（必須）

set -euo pipefail

SESSIONS_DIR=".cursor/debug-sessions"
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
  if grep -li "$KEYWORD" "$file" 2>/dev/null; then
    FOUND=$((FOUND + 1))
    echo "--- $(basename "$file") ---"
    grep -n -i "$KEYWORD" "$file" | head -5
    echo ""
  fi
done

if [ "$FOUND" -eq 0 ]; then
  echo "該当するセッションが見つかりませんでした。"
else
  echo "=== ${FOUND} 件のセッションが見つかりました ==="
fi
