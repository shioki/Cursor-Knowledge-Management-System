#!/usr/bin/env bash
# improvement-tracking: 改善記録を 1 改善 1 ファイルで作成するスクリプト
#
# Usage: bash .agents/skills/improvement-tracking/scripts/add-improvement.sh "改善タイトル"
#        （.claude/skills / .cursor/skills も検出対象）
#
# 引数:
#   $1 - 改善タイトル（必須）
#
# 出力: references/improvements/YYYY-MM-DD-スラッグ.md と、索引 README.md への 1 行追加

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../../project-setup/scripts/_skill-base.sh
source "${SCRIPT_DIR}/../../project-setup/scripts/_skill-base.sh"

TITLE="${1:?エラー: 改善タイトルを指定してください}"
DATE=$(date +%Y-%m-%d)
SLUG=$(ckms_slugify "$TITLE" "improvement-$(date +%H%M%S)")

IMPROVEMENTS_DIR="${SKILL_BASE}/improvement-tracking/references/improvements"
FILENAME="${DATE}-${SLUG}.md"
TARGET="${IMPROVEMENTS_DIR}/${FILENAME}"

mkdir -p "$IMPROVEMENTS_DIR"

if [ -e "$TARGET" ]; then
  echo "エラー: 既に存在します: $TARGET" >&2
  echo "進行中の改善であれば、既存ファイルのステータスを更新してください" >&2
  exit 1
fi

cat > "$TARGET" << EOF
---
title: $(ckms_yaml_escape "$TITLE")
description: "" # 1 行サマリを記入
tags: [improvement]
status: 提案
updated: ${DATE}
---

# 背景

<!-- 改善の動機・発見の経緯 -->

# 改善内容

<!-- 具体的な改善策 -->

# 効果

- **Before**:
- **After**:
- **改善率**:

# ステータス

提案

<!-- 提案 / 実装中 / 完了 / 保留。変更時は frontmatter の status と updated も更新する -->

# 関連

<!-- 派生元のデバッグセッションや技術判断への Markdown リンク -->
EOF

ckms_index_upsert \
  "${IMPROVEMENTS_DIR}/README.md" \
  "改善記録（Improvements）" \
  "リファクタリング・最適化・技術的負債の解消を 1 改善 1 ファイルで管理します。全文を読む前に、この一覧から関連するものを絞り込んでください。" \
  "$DATE" \
  "$TITLE" \
  "$FILENAME"

echo "改善記録を作成しました: ${TARGET}"
echo "索引を更新しました: ${IMPROVEMENTS_DIR}/README.md"
