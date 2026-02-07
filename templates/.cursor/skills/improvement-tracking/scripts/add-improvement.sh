#!/usr/bin/env bash
# improvement-tracking: 改善エントリを追加するスクリプト
#
# Usage: bash .cursor/skills/improvement-tracking/scripts/add-improvement.sh "改善タイトル"
#
# 引数:
#   $1 - 改善タイトル（必須）

set -euo pipefail

IMPROVEMENTS_FILE=".cursor/skills/improvement-tracking/references/IMPROVEMENTS_TEMPLATE.md"
TITLE="${1:?エラー: 改善タイトルを指定してください}"
DATE=$(date +%Y-%m-%d)

if [ ! -f "$IMPROVEMENTS_FILE" ]; then
  echo "エラー: $IMPROVEMENTS_FILE が見つかりません"
  echo "プロジェクトルートから実行してください"
  exit 1
fi

ENTRY="
### ${DATE} - ${TITLE}

#### 背景
<!-- 改善の動機・発見の経緯 -->

#### 改善内容
<!-- 具体的な改善策 -->

#### 効果
- **Before**:
- **After**:
- **改善率**:

#### ステータス
提案
"

# 「改善提案」セクションの直後に追加
if grep -q "## 改善提案" "$IMPROVEMENTS_FILE"; then
  sed -i "/## 改善提案/a\\${ENTRY}" "$IMPROVEMENTS_FILE"
  echo "改善エントリを追加しました: ${DATE} - ${TITLE}"
else
  echo "$ENTRY" >> "$IMPROVEMENTS_FILE"
  echo "改善エントリをファイル末尾に追加しました: ${DATE} - ${TITLE}"
fi
