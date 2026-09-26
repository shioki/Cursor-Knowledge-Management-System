#!/usr/bin/env bash
# knowledge-management: 技術判断を 1 判断 1 ファイルで記録するスクリプト
#
# Usage: bash .agents/skills/knowledge-management/scripts/add-entry.sh "判断タイトル"
#        （.claude/skills / .cursor/skills も検出対象）
#
# 引数:
#   $1 - 判断タイトル（必須）
#
# 出力: references/decisions/YYYY-MM-DD-スラッグ.md と、索引 README.md への 1 行追加

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

TITLE="${1:?エラー: 判断タイトルを指定してください}"
DATE=$(date +%Y-%m-%d)
SLUG=$(ckms_slugify "$TITLE" "decision-$(date +%H%M%S)")

DECISIONS_DIR="${SKILL_BASE}/knowledge-management/references/decisions"
FILENAME="${DATE}-${SLUG}.md"
TARGET="${DECISIONS_DIR}/${FILENAME}"

mkdir -p "$DECISIONS_DIR"

if [ -e "$TARGET" ]; then
  echo "エラー: 既に存在します: $TARGET" >&2
  echo "別のタイトルを指定するか、既存ファイルを直接編集してください" >&2
  exit 1
fi

cat > "$TARGET" << EOF
---
title: $(ckms_yaml_escape "$TITLE")
description: "" # 1 行サマリを記入
tags: [adr]
updated: ${DATE}
---

# 判断内容

<!-- 具体的な選択内容 -->

# 検討した選択肢

1. **選択肢A**
   - メリット:
   - デメリット:
2. **選択肢B**
   - メリット:
   - デメリット:

# 決定と理由

**決定**:

**理由**:

# 影響範囲

-

# 関連

<!-- 関連する判断・パターンへの Markdown リンク -->
EOF

ckms_index_upsert \
  "${DECISIONS_DIR}/README.md" \
  "技術判断（Decisions）" \
  "プロジェクトの設計判断・ADR を 1 判断 1 ファイルで管理します。全文を読む前に、この一覧から関連するものを絞り込んでください。" \
  "$DATE" \
  "$TITLE" \
  "$FILENAME"

echo "技術判断を作成しました: ${TARGET}"
echo "索引を更新しました: ${DECISIONS_DIR}/README.md"
