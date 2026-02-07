#!/usr/bin/env bash
# project-setup: プロジェクトに知識管理システムを初期セットアップするスクリプト
#
# Usage: bash init.sh /path/to/target-project
#
# 引数:
#   $1 - ターゲットプロジェクトのパス（必須）

set -euo pipefail

TARGET="${1:?エラー: ターゲットプロジェクトのパスを指定してください}"

# このスクリプトの場所を基準にテンプレートルートを特定
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_CURSOR_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

if [ ! -d "$TARGET" ]; then
  echo "エラー: ディレクトリが見つかりません: $TARGET"
  exit 1
fi

echo "=== Cursor Knowledge Management System セットアップ ==="
echo "ターゲット: $TARGET"
echo ""

# skills/ のコピー
if [ -d "$TARGET/.cursor/skills" ]; then
  echo "警告: $TARGET/.cursor/skills は既に存在します。上書きしますか? (y/N)"
  read -r REPLY
  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "skills/ のコピーをスキップしました"
  else
    cp -r "$TEMPLATES_CURSOR_DIR/skills" "$TARGET/.cursor/skills"
    echo "skills/ をコピーしました"
  fi
else
  mkdir -p "$TARGET/.cursor"
  cp -r "$TEMPLATES_CURSOR_DIR/skills" "$TARGET/.cursor/skills"
  echo "skills/ をコピーしました"
fi

# commands/ のコピー
if [ -d "$TARGET/.cursor/commands" ]; then
  echo "警告: $TARGET/.cursor/commands は既に存在します。上書きしますか? (y/N)"
  read -r REPLY
  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "commands/ のコピーをスキップしました"
  else
    cp -r "$TEMPLATES_CURSOR_DIR/commands" "$TARGET/.cursor/commands"
    echo "commands/ をコピーしました"
  fi
else
  mkdir -p "$TARGET/.cursor"
  cp -r "$TEMPLATES_CURSOR_DIR/commands" "$TARGET/.cursor/commands"
  echo "commands/ をコピーしました"
fi

# .cursorignore のコピー
CURSORIGNORE_SRC="$(cd "$TEMPLATES_CURSOR_DIR/.." && pwd)/.cursorignore"
if [ -f "$CURSORIGNORE_SRC" ]; then
  if [ -f "$TARGET/.cursorignore" ]; then
    echo "警告: $TARGET/.cursorignore は既に存在します。上書きしますか? (y/N)"
    read -r REPLY
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
      echo ".cursorignore のコピーをスキップしました"
    else
      cp "$CURSORIGNORE_SRC" "$TARGET/.cursorignore"
      echo ".cursorignore をコピーしました"
    fi
  else
    cp "$CURSORIGNORE_SRC" "$TARGET/.cursorignore"
    echo ".cursorignore をコピーしました"
  fi
fi

# スクリプトに実行権限を付与
find "$TARGET/.cursor/skills" -name "*.sh" -exec chmod +x {} \;
echo "スクリプトに実行権限を付与しました"

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "次のステップ:"
echo "  1. /update-context コマンドでプロジェクト基本情報を記入"
echo "  2. /record-decision コマンドで最初の技術判断を記録"
echo "  3. team-standards スキルをプロジェクトの規約に更新"
echo ""
echo "構造検証: bash .cursor/skills/project-setup/scripts/validate.sh"
