#!/usr/bin/env bash
# knowledge-management: 技術判断エントリを追加するスクリプト
#
# Usage: bash .cursor/skills/knowledge-management/scripts/add-entry.sh "判断タイトル"
#
# 引数:
#   $1 - 判断タイトル（必須）

set -euo pipefail

KNOWLEDGE_FILE=".cursor/skills/knowledge-management/references/KNOWLEDGE_TEMPLATE.md"
TITLE="${1:?エラー: 判断タイトルを指定してください}"
DATE=$(date +%Y-%m-%d)

if [ ! -f "$KNOWLEDGE_FILE" ]; then
  echo "エラー: $KNOWLEDGE_FILE が見つかりません"
  echo "プロジェクトルートから実行してください"
  exit 1
fi

ENTRY="
### ${DATE} - ${TITLE}

#### 判断内容
<!-- 具体的な選択内容を記述 -->

#### 検討した選択肢
1. **選択肢A**
   - メリット:
   - デメリット:
2. **選択肢B**
   - メリット:
   - デメリット:

#### 決定と理由
**決定**:
**理由**:

#### 影響範囲
-
"

# 「設計判断の記録」セクションの直後に追加
if grep -q "## 設計判断の記録" "$KNOWLEDGE_FILE"; then
  # セクション見出しの次の行に挿入
  sed -i "/## 設計判断の記録/a\\${ENTRY}" "$KNOWLEDGE_FILE"
  echo "技術判断エントリを追加しました: ${DATE} - ${TITLE}"
else
  # セクションが無い場合はファイル末尾に追加
  echo "$ENTRY" >> "$KNOWLEDGE_FILE"
  echo "技術判断エントリをファイル末尾に追加しました: ${DATE} - ${TITLE}"
fi
