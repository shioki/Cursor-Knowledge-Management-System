#!/usr/bin/env bash
# project-setup: プロジェクトに知識管理システムを初期セットアップするスクリプト (v6.0.0)
#
# Usage: bash init.sh /path/to/target-project [オプション]
#
# 引数:
#   $1 - ターゲットプロジェクトのパス（必須）
#
# オプション:
#   --yes, -y         - すべての確認に yes と答える（非対話環境・CI 向け）
#   --legacy-claude   - .claude/skills に配置（v4.x 互換）
#   --cursor-only     - .cursor/skills に配置（Cursor のみ）
#   --with-agents-md  - AGENTS.md テンプレートも配置（既存は保持）
#   --no-hooks        - hooks を配置しない
#   --no-agents       - subagent を配置しない
#
# デフォルト: .agents/skills に配置（Cursor / Claude Code / Codex 共用の公式ディレクトリ）

set -euo pipefail

TARGET=""
MODE="agents"
ASSUME_YES=false
WITH_AGENTS_MD=false
WITH_HOOKS=true
WITH_AGENTS=true

for arg in "$@"; do
  case "$arg" in
    --yes|-y)         ASSUME_YES=true ;;
    --legacy-claude)  MODE="claude" ;;
    --cursor-only)    MODE="cursor" ;;
    --with-agents-md) WITH_AGENTS_MD=true ;;
    --no-hooks)       WITH_HOOKS=false ;;
    --no-agents)      WITH_AGENTS=false ;;
    -*)
      echo "エラー: 不明なオプション: $arg" >&2
      exit 1
      ;;
    *) if [ -z "$TARGET" ]; then TARGET="$arg"; fi ;;
  esac
done

if [ -z "$TARGET" ]; then
  echo "エラー: ターゲットプロジェクトのパスを指定してください" >&2
  echo "Usage: bash init.sh /path/to/target-project [--yes] [--legacy-claude|--cursor-only] [--with-agents-md] [--no-hooks] [--no-agents]" >&2
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  echo "エラー: ディレクトリが見つかりません: $TARGET" >&2
  exit 1
fi

case "$MODE" in
  agents) BASE_DIR=".agents" ; LABEL="共用 (.agents/)" ;;
  claude) BASE_DIR=".claude" ; LABEL="v4 互換 (.claude/)" ;;
  cursor) BASE_DIR=".cursor" ; LABEL="Cursor のみ (.cursor/)" ;;
esac

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_SKILLS="$(cd "$SCRIPT_DIR/../.." && pwd)"
SOURCE_ROOT="$(cd "$SOURCE_SKILLS/.." && pwd)"
SOURCE_HOOKS="${SOURCE_ROOT}/hooks"
SOURCE_AGENTS="${SOURCE_ROOT}/agents"
SOURCE_TEMPLATES="${SOURCE_ROOT}/templates"

# 確認プロンプト。--yes 指定時、または非対話環境では待たない。
confirm() {
  local prompt="$1"
  if [ "$ASSUME_YES" = true ]; then
    return 0
  fi
  if [ ! -t 0 ]; then
    echo "  非対話環境のためスキップします（上書きするには --yes を指定してください）"
    return 1
  fi
  local reply
  read -r -p "  ${prompt} (y/N): " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

echo "=== Cursor Knowledge Management System セットアップ (v6.0.0) ==="
echo "ターゲット: $TARGET"
echo "モード:     $LABEL"
echo "hooks:      $([ "$WITH_HOOKS" = true ] && echo '配置する' || echo '配置しない')"
echo "subagent:   $([ "$WITH_AGENTS" = true ] && echo '配置する' || echo '配置しない')"
echo "AGENTS.md:  $([ "$WITH_AGENTS_MD" = true ] && echo '配置する' || echo '配置しない')"
echo ""

# 既存 .claude/skills の検出と移行提案
if [ "$MODE" = "agents" ] && [ -d "$TARGET/.claude/skills" ] && [ ! -d "$TARGET/.agents/skills" ]; then
  echo "検出: $TARGET/.claude/skills が存在します（v4.x 配置）"
  echo "v6 のデフォルト配置は .agents/skills です。"
  if confirm ".claude/skills を .agents/skills へ移動しますか?"; then
    mkdir -p "$TARGET/.agents"
    mv "$TARGET/.claude/skills" "$TARGET/.agents/skills"
    if [ -d "$TARGET/.claude/debug-sessions" ]; then
      mv "$TARGET/.claude/debug-sessions" "$TARGET/.agents/debug-sessions"
    fi
    rmdir "$TARGET/.claude" 2>/dev/null || true
    echo "  .claude/skills を .agents/skills に移動しました"
  else
    echo "  両方の配置を維持します（.claude/skills と .agents/skills の両方が読み込まれます）"
  fi
  echo ""
fi

SKILLS_DEST="$TARGET/$BASE_DIR/skills"
SESSIONS_DEST="$TARGET/$BASE_DIR/debug-sessions"

# skills/
if [ -d "$SKILLS_DEST" ]; then
  echo "警告: $SKILLS_DEST は既に存在します"
  if confirm "上書きしますか?"; then
    rm -rf "$SKILLS_DEST"
    mkdir -p "$(dirname "$SKILLS_DEST")"
    cp -r "$SOURCE_SKILLS" "$SKILLS_DEST"
    echo "  skills/ をコピーしました"
  else
    echo "  skills/ のコピーをスキップしました"
  fi
else
  mkdir -p "$(dirname "$SKILLS_DEST")"
  cp -r "$SOURCE_SKILLS" "$SKILLS_DEST"
  echo "skills/ をコピーしました"
fi

mkdir -p "$SESSIONS_DEST"
if [ ! -f "$SESSIONS_DEST/.gitkeep" ]; then
  touch "$SESSIONS_DEST/.gitkeep"
  echo "debug-sessions/ を作成しました"
fi

# agents/（subagent は Cursor が .cursor/agents から読み込む）
if [ "$WITH_AGENTS" = true ]; then
  if [ ! -d "$SOURCE_AGENTS" ]; then
    echo "情報: 配布元に agents/ が無いためスキップします"
  else
    AGENTS_DEST="$TARGET/.cursor/agents"
    mkdir -p "$AGENTS_DEST"
    for src in "$SOURCE_AGENTS"/*.md; do
      [ -f "$src" ] || continue
      dest="$AGENTS_DEST/$(basename "$src")"
      if [ -f "$dest" ]; then
        echo "警告: $dest は既に存在します"
        confirm "上書きしますか?" || continue
      fi
      cp "$src" "$dest"
      echo "subagent を配置しました: $dest"
    done
  fi
fi

# hooks/
if [ "$WITH_HOOKS" = true ]; then
  if [ ! -d "$SOURCE_HOOKS" ]; then
    echo "情報: 配布元に hooks/ が無いためスキップします"
  else
    HOOKS_DEST="$TARGET/.cursor/hooks"
    mkdir -p "$HOOKS_DEST"
    cp "$SOURCE_HOOKS"/*.sh "$HOOKS_DEST/"
    chmod +x "$HOOKS_DEST"/*.sh
    echo "hooks スクリプトを配置しました: $HOOKS_DEST"

    HOOKS_JSON="$TARGET/.cursor/hooks.json"
    if [ -f "$HOOKS_JSON" ]; then
      echo "情報: $HOOKS_JSON は既に存在します（上書きしません）"
      echo "      次のエントリを手動で追記してください:"
      echo '        "sessionStart": [{ "command": ".cursor/hooks/inject-knowledge-index.sh" }]'
      echo '        "afterFileEdit": [{ "command": ".cursor/hooks/log-activity.sh" }]'
    else
      cat > "$HOOKS_JSON" << 'EOF'
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      {
        "command": ".cursor/hooks/inject-knowledge-index.sh",
        "timeout": 10
      }
    ],
    "afterFileEdit": [
      {
        "command": ".cursor/hooks/log-activity.sh",
        "timeout": 5
      }
    ],
    "stop": [
      {
        "command": ".cursor/hooks/suggest-record.sh",
        "timeout": 10,
        "loop_limit": 1
      }
    ]
  }
}
EOF
      echo "hooks.json を作成しました: $HOOKS_JSON"
    fi
  fi
fi

# .cursorignore
CURSORIGNORE_SRC="${SOURCE_TEMPLATES}/.cursorignore"
if [ -f "$CURSORIGNORE_SRC" ]; then
  if [ -f "$TARGET/.cursorignore" ]; then
    echo "警告: $TARGET/.cursorignore は既に存在します"
    if confirm "上書きしますか?"; then
      cp "$CURSORIGNORE_SRC" "$TARGET/.cursorignore"
      echo "  .cursorignore をコピーしました"
    else
      echo "  .cursorignore のコピーをスキップしました"
    fi
  else
    cp "$CURSORIGNORE_SRC" "$TARGET/.cursorignore"
    echo ".cursorignore をコピーしました"
  fi
fi

# AGENTS.md
if [ "$WITH_AGENTS_MD" = true ]; then
  AGENTS_MD_SRC="${SOURCE_TEMPLATES}/AGENTS.md.template"
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

if [ -d "$SKILLS_DEST" ]; then
  find "$SKILLS_DEST" -name "*.sh" -exec chmod +x {} \;
  echo "スクリプトに実行権限を付与しました"
fi

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "次のステップ:"
echo "  1. /update-context でプロジェクト基本情報を記入"
echo "  2. /record-decision で最初の技術判断を記録"
echo "  3. team-standards スキルをプロジェクトの規約に更新"
echo ""
echo "構造検証: bash $BASE_DIR/skills/project-setup/scripts/validate.sh"
echo ""
if [ "$WITH_HOOKS" = true ] && [ -d "$SOURCE_HOOKS" ]; then
  echo "hooks の設定: $BASE_DIR/knowledge-hooks.conf（詳細は hooks/README.md）"
  echo "  stop フックによる記録提案は既定で無効です。"
  echo ""
fi
case "$MODE" in
  agents) echo "（Cursor / Claude Code / Codex で .agents/skills を共有利用できます）" ;;
  claude) echo "（Cursor / Claude Code で .claude/skills を共有利用できます）" ;;
  cursor) echo "（.cursor/skills は Cursor のみが読み込みます）" ;;
esac
