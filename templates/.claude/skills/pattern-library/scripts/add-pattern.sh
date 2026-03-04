#!/usr/bin/env bash
# pattern-library: 実装パターンエントリを追加するスクリプト
#
# Usage: bash .claude/skills/pattern-library/scripts/add-pattern.sh "パターン名"
#        （.cursor/skills にも対応）
#
# 引数:
#   $1 - パターン名（必須）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../project-setup/scripts/_skill-base.sh
source "${SCRIPT_DIR}/../../project-setup/scripts/_skill-base.sh"

PATTERNS_FILE="${SKILL_BASE}/pattern-library/references/PATTERNS_TEMPLATE.md"
NAME="${1:?エラー: パターン名を指定してください}"
DATE=$(date +%Y-%m-%d)

if [ ! -f "$PATTERNS_FILE" ]; then
  echo "エラー: $PATTERNS_FILE が見つかりません"
  echo "プロジェクトルートから実行してください"
  exit 1
fi

ENTRY="
## パターン名: ${NAME}

> 登録日: ${DATE}

### 目的
- **解決する問題**:
- **適用場面**:
- **期待効果**:

### 実装例
\`\`\`
// コード例を記述
\`\`\`

### 使用上の注意
- **制約事項**:
- **パフォーマンス影響**:
- **メンテナンス性**:

### 関連パターン
- **組み合わせ可能**:
- **代替パターン**:
"

# 「プロジェクト固有パターン」セクションの直後に追加
if grep -q "## プロジェクト固有パターン" "$PATTERNS_FILE"; then
  sed -i "/## プロジェクト固有パターン/a\\${ENTRY}" "$PATTERNS_FILE"
  echo "パターンを追加しました: ${NAME}"
else
  echo "$ENTRY" >> "$PATTERNS_FILE"
  echo "パターンをファイル末尾に追加しました: ${NAME}"
fi
