#!/usr/bin/env bash
# pattern-library: 実装パターンを 1 パターン 1 ファイルで登録するスクリプト
#
# Usage: bash .agents/skills/pattern-library/scripts/add-pattern.sh "パターン名"
#        （.claude/skills / .cursor/skills も検出対象）
#
# 引数:
#   $1 - パターン名（必須）
#
# 出力: references/patterns/スラッグ.md と、索引 README.md への 1 行追加

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../../project-setup/scripts/_skill-base.sh
source "${SCRIPT_DIR}/../../project-setup/scripts/_skill-base.sh"

NAME="${1:?エラー: パターン名を指定してください}"
DATE=$(date +%Y-%m-%d)
SLUG=$(ckms_slugify "$NAME" "pattern-$(date +%H%M%S)")

PATTERNS_DIR="${SKILL_BASE}/pattern-library/references/patterns"
FILENAME="${SLUG}.md"
TARGET="${PATTERNS_DIR}/${FILENAME}"

mkdir -p "$PATTERNS_DIR"

if [ -e "$TARGET" ]; then
  echo "エラー: 既に存在します: $TARGET" >&2
  echo "既存パターンへの追記を検討してください" >&2
  exit 1
fi

cat > "$TARGET" << EOF
---
title: ${NAME}
description: "" # 1 行サマリを記入
tags: [pattern]
updated: ${DATE}
---

# 目的

- **解決する問題**:
- **適用場面**:
- **期待効果**:

# 実装例

\`\`\`
// コード例を記述
\`\`\`

# 使用上の注意

- **制約事項**:
- **パフォーマンス影響**:
- **メンテナンス性**:

# 関連パターン

- **組み合わせ可能**:
- **代替パターン**:
EOF

ckms_index_upsert \
  "${PATTERNS_DIR}/README.md" \
  "実装パターン（Patterns）" \
  "プロジェクトで再利用する実装パターンを 1 パターン 1 ファイルで管理します。全文を読む前に、この一覧から関連するものを絞り込んでください。" \
  "$DATE" \
  "$NAME" \
  "$FILENAME"

echo "パターンを作成しました: ${TARGET}"
echo "索引を更新しました: ${PATTERNS_DIR}/README.md"
