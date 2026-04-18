#!/usr/bin/env bash
# project-setup: プロジェクトに知識管理システムを初期セットアップするスクリプト (v5.0.0)
#
# Usage: bash init.sh /path/to/target-project [--legacy-claude|--cursor-only] [--with-agents-md]
#
# 引数:
#   $1 - ターゲットプロジェクトのパス（必須）
#   --legacy-claude   - .claude/skills に配置（v4.x 互換）
#   --cursor-only     - .cursor/skills に配置（Cursor のみ）
#   --with-agents-md  - AGENTS.md テンプレートも同時にコピー（既存は保持）
#
# デフォルト: .agents/skills に配置（Cursor 3.x / Claude Code / Codex 共用の公式ディレクトリ）

set -euo pipefail

TARGET=""
MODE="agents"
WITH_AGENTS_MD=false

for arg in "$@"; do
  case "$arg" in
    --legacy-claude)  MODE="claude" ;;
    --cursor-only)    MODE="cursor" ;;
    --with-agents-md) WITH_AGENTS_MD=true ;;
    *) if [ -z "$TARGET" ]; then TARGET="$arg"; fi ;;
  esac
done

if [ -z "$TARGET" ]; then
  echo "エラー: ターゲットプロジェクトのパスを指定してください"
  echo "Usage: bash init.sh /path/to/target-project [--legacy-claude|--cursor-only] [--with-agents-md]"
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  echo "エラー: ディレクトリが見つかりません: $TARGET"
  exit 1
fi

case "$MODE" in
  agents) BASE_DIR=".agents" ; LABEL="v5 共用 (.agents/)" ;;
  claude) BASE_DIR=".claude" ; LABEL="v4 互換 (.claude/)" ;;
  cursor) BASE_DIR=".cursor" ; LABEL="Cursor のみ (.cursor/)" ;;
esac

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_AGENTS_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TEMPLATES_ROOT="$(cd "$TEMPLATES_AGENTS_DIR/.." && pwd)"
TEMPLATES_CURSOR_DIR="${TEMPLATES_ROOT}/.cursor"

echo "=== Cursor Knowledge Management System セットアップ (v5.0.0) ==="
echo "ターゲット: $TARGET"
echo "モード:     $LABEL"
echo "AGENTS.md:  $([ "$WITH_AGENTS_MD" = true ] && echo '含む' || echo '含まない')"
echo ""

# 既存 .claude/skills の検出と移行提案
if [ "$MODE" = "agents" ] && [ -d "$TARGET/.claude/skills" ] && [ ! -d "$TARGET/.agents/skills" ]; then
  echo "検出: $TARGET/.claude/skills が存在します（v4.x 配置）"
  echo ""
  echo "v5.0.0 のデフォルト配置は .agents/skills です。"
  echo "  [m] .claude/skills を .agents/skills に移動してから上書き"
  echo "  [k] .claude/skills を維持し、.agents/skills にも新規配置（両方読み込まれます）"
  echo "  [c] キャンセル"
  read -r -p "選択 (m/k/c) [m]: " MIG
  MIG="${MIG:-m}"
  case "$MIG" in
    m|M)
      mv "$TARGET/.claude/skills" "$TARGET/.agents/skills"
      mkdir -p "$TARGET/.agents"
      if [ -d "$TARGET/.claude/debug-sessions" ]; then
        mv "$TARGET/.claude/debug-sessions" "$TARGET/.agents/debug-sessions"
      fi
      rmdir "$TARGET/.claude" 2>/dev/null || true
      echo ".claude/skills を .agents/skills に移動しました"
      ;;
    c|C)
      echo "中止しました"
      exit 0
      ;;
    *)
      echo "両方の配置を維持します（.claude/skills と .agents/skills の両方が読み込まれます）"
      ;;
  esac
  echo ""
fi

SKILLS_DEST="$TARGET/$BASE_DIR/skills"
SESSIONS_DEST="$TARGET/$BASE_DIR/debug-sessions"
VALIDATE_PATH="$BASE_DIR/skills/project-setup/scripts/validate.sh"

# skills/ のコピー
if [ -d "$SKILLS_DEST" ]; then
  echo "警告: $SKILLS_DEST は既に存在します。上書きしますか? (y/N)"
  read -r REPLY
  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "skills/ のコピーをスキップしました"
  else
    rm -rf "$SKILLS_DEST"
    cp -r "$TEMPLATES_AGENTS_DIR/skills" "$SKILLS_DEST"
    echo "skills/ をコピーしました"
  fi
else
  mkdir -p "$(dirname "$SKILLS_DEST")"
  cp -r "$TEMPLATES_AGENTS_DIR/skills" "$SKILLS_DEST"
  echo "skills/ をコピーしました"
fi

mkdir -p "$SESSIONS_DEST"
if [ ! -f "$SESSIONS_DEST/.gitkeep" ]; then
  touch "$SESSIONS_DEST/.gitkeep"
  echo "debug-sessions/ を作成しました"
fi

# commands/ のコピー（Cursor 専用、全モード共通）
if [ -d "$TARGET/.cursor/commands" ]; then
  echo "警告: $TARGET/.cursor/commands は既に存在します。上書きしますか? (y/N)"
  read -r REPLY
  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "commands/ のコピーをスキップしました"
  else
    rm -rf "$TARGET/.cursor/commands"
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

# AGENTS.md テンプレートのコピー（--with-agents-md 指定時）
if [ "$WITH_AGENTS_MD" = true ]; then
  AGENTS_MD_SRC="${TEMPLATES_ROOT}/AGENTS.md.template"
  AGENTS_MD_DEST="$TARGET/AGENTS.md"
  if [ ! -f "$AGENTS_MD_SRC" ]; then
    echo "警告: AGENTS.md.template が見つかりません: $AGENTS_MD_SRC"
  elif [ -f "$AGENTS_MD_DEST" ]; then
    echo "情報: $TARGET/AGENTS.md は既に存在します（上書きしません）"
  else
    cp "$AGENTS_MD_SRC" "$AGENTS_MD_DEST"
    echo "AGENTS.md をコピーしました"
  fi
fi

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
if [ "$MODE" = "agents" ]; then
  echo "（Cursor 3.x / Claude Code / Codex で .agents/skills を共有利用できます）"
elif [ "$MODE" = "claude" ]; then
  echo "（Cursor / Claude Code で .claude/skills を共有利用できます）"
fi
