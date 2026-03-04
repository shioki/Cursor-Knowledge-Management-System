#!/usr/bin/env bash
# project-setup: プロジェクトに知識管理システムを初期セットアップするスクリプト
#
# Usage: bash init.sh /path/to/target-project [--cursor-only]
#
# 引数:
#   $1 - ターゲットプロジェクトのパス（必須）
#   --cursor-only - Cursor 専用モード（.cursor/skills に配置。Claude Code 未使用時）
#
# デフォルト: .claude/skills に配置（Cursor と Claude Code で共有）

set -euo pipefail

TARGET=""
CURSOR_ONLY=false

for arg in "$@"; do
  if [ "$arg" = "--cursor-only" ]; then
    CURSOR_ONLY=true
  elif [ -z "$TARGET" ] && [ -d "$arg" ]; then
    TARGET="$arg"
  elif [ -z "$TARGET" ]; then
    TARGET="$arg"
  fi
done

if [ -z "$TARGET" ]; then
  echo "エラー: ターゲットプロジェクトのパスを指定してください"
  echo "Usage: bash init.sh /path/to/target-project [--cursor-only]"
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  echo "エラー: ディレクトリが見つかりません: $TARGET"
  exit 1
fi

# このスクリプトの場所を基準にテンプレートルートを特定
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_CLAUDE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TEMPLATES_ROOT="$(cd "$TEMPLATES_CLAUDE_DIR/.." && pwd)"
TEMPLATES_CURSOR_DIR="${TEMPLATES_ROOT}/.cursor"

echo "=== Cursor Knowledge Management System セットアップ (v4.0.0) ==="
echo "ターゲット: $TARGET"
echo "モード: $([ "$CURSOR_ONLY" = true ] && echo 'Cursor 専用 (.cursor/)' || echo '共有 (.claude/)')"
echo ""

if [ "$CURSOR_ONLY" = true ]; then
  SKILLS_DEST="$TARGET/.cursor/skills"
  SESSIONS_DEST="$TARGET/.cursor/debug-sessions"
  VALIDATE_PATH=".cursor/skills/project-setup/scripts/validate.sh"
else
  SKILLS_DEST="$TARGET/.claude/skills"
  SESSIONS_DEST="$TARGET/.claude/debug-sessions"
  VALIDATE_PATH=".claude/skills/project-setup/scripts/validate.sh"
fi

# skills/ のコピー
if [ -d "$SKILLS_DEST" ]; then
  echo "警告: $SKILLS_DEST は既に存在します。上書きしますか? (y/N)"
  read -r REPLY
  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "skills/ のコピーをスキップしました"
  else
    cp -r "$TEMPLATES_CLAUDE_DIR/skills" "$SKILLS_DEST"
    echo "skills/ をコピーしました"
  fi
else
  mkdir -p "$(dirname "$SKILLS_DEST")"
  cp -r "$TEMPLATES_CLAUDE_DIR/skills" "$SKILLS_DEST"
  echo "skills/ をコピーしました"
fi

# debug-sessions/ の作成（空ディレクトリ）
mkdir -p "$SESSIONS_DEST"
if [ ! -f "$SESSIONS_DEST/.gitkeep" ] 2>/dev/null; then
  touch "$SESSIONS_DEST/.gitkeep"
  echo "debug-sessions/ を作成しました"
fi

# commands/ のコピー（Cursor 専用、両モード共通）
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
CURSORIGNORE_SRC="${TEMPLATES_ROOT}/.cursorignore"
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
find "$SKILLS_DEST" -name "*.sh" -exec chmod +x {} \;
echo "スクリプトに実行権限を付与しました"

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "次のステップ:"
echo "  1. /update-context コマンドでプロジェクト基本情報を記入"
echo "  2. /record-decision コマンドで最初の技術判断を記録"
echo "  3. team-standards スキルをプロジェクトの規約に更新"
echo ""
echo "構造検証: bash $VALIDATE_PATH"
echo ""
if [ "$CURSOR_ONLY" != true ]; then
  echo "（Cursor と Claude Code の両方でスキルを利用できます）"
fi
