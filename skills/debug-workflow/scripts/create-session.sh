#!/usr/bin/env bash
# debug-workflow: デバッグセッションファイルを作成するスクリプト
#
# Usage: bash .agents/skills/debug-workflow/scripts/create-session.sh "問題の概要"
#        （.claude/skills / .cursor/skills も検出対象）
#
# 引数:
#   $1 - 問題の概要（必須）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../project-setup/scripts/_skill-base.sh
source "${SCRIPT_DIR}/../../project-setup/scripts/_skill-base.sh"

SESSIONS_DIR="${DATA_BASE}/debug-sessions"
SUMMARY="${1:?エラー: 問題の概要を指定してください}"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
# 日本語のみの概要ではスラッグが空になるため、その場合は時刻をフォールバックに使う
SAFE_NAME=$(ckms_slugify "$SUMMARY" "session-$(date +%H%M%S)")
FILENAME="${DATE}_${SAFE_NAME}.md"

mkdir -p "$SESSIONS_DIR"

if [ -e "${SESSIONS_DIR}/${FILENAME}" ]; then
  echo "エラー: 既に存在します: ${SESSIONS_DIR}/${FILENAME}" >&2
  exit 1
fi

cat > "${SESSIONS_DIR}/${FILENAME}" << EOF
# デバッグセッション: ${SUMMARY}

## 基本情報

| 項目 | 内容 |
|------|------|
| 発生日時 | ${DATE} ${TIME} |
| 環境 | <!-- 開発/ステージング/本番 --> |
| 影響範囲 | <!-- 機能/ユーザー範囲 --> |
| 緊急度 | <!-- 高/中/低 --> |
| ステータス | 調査中 |

## 症状

### エラーメッセージ

\`\`\`
<!-- エラーメッセージを貼り付け -->
\`\`\`

### 再現手順

1.
2.
3.

### 期待動作


### 実際の動作


## 調査

### 仮説

1.
2.

### 調査ログ

- [ ]

## 解決策

### 根本原因


### 修正内容


### テスト結果


## 再発防止

### 予防策


### 関連する改善提案

<!-- /log-improvement で記録 -->

EOF

echo "デバッグセッションを作成しました: ${SESSIONS_DIR}/${FILENAME}"
