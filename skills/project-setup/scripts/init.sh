#!/usr/bin/env bash
# project-setup: プロジェクトに知識管理システムを初期セットアップするスクリプト (v6.2.1)
#
# Usage: bash init.sh /path/to/target-project [オプション]
#
# 引数:
#   $1 - ターゲットプロジェクトのパス（必須）
#
# オプション:
#   --yes, -y             - すべての確認に yes と答える（非対話環境・CI 向け）
#   --legacy-claude       - .claude/skills に配置（v4.x 互換）
#   --cursor-only         - .cursor/skills に配置（Cursor のみ）
#   --with-agents-md      - AGENTS.md テンプレートも配置（既存は保持）。CLAUDE.md も
#                           同時に作成する（@AGENTS.md の import のみ、既存は保持）
#   --no-hooks            - hooks を配置しない
#   --no-agents           - subagent を配置しない
#   --no-claude-bridge    - .claude/skills への橋渡し（Claude Code 用）を作らない
#   --no-backup           - 再実行時に skills/ の退避を作らない
#
# デフォルト: .agents/skills に配置。Cursor はこれをそのまま読み、Claude Code は
# .agents/skills を標準では探索しないため、.claude/skills にシンボリックリンクで
# 橋渡しする（--legacy-claude / --cursor-only では不要なため作成しない）。

set -euo pipefail

TARGET=""
MODE="agents"
ASSUME_YES=false
WITH_AGENTS_MD=false
WITH_HOOKS=true
WITH_AGENTS=true
WITH_CLAUDE_BRIDGE=true
NO_BACKUP=false
LEGACY_CLAUDE=false
CURSOR_ONLY=false

for arg in "$@"; do
  case "$arg" in
    --yes|-y)             ASSUME_YES=true ;;
    --legacy-claude)      MODE="claude" ; LEGACY_CLAUDE=true ;;
    --cursor-only)        MODE="cursor" ; CURSOR_ONLY=true ;;
    --with-agents-md)     WITH_AGENTS_MD=true ;;
    --no-hooks)           WITH_HOOKS=false ;;
    --no-agents)          WITH_AGENTS=false ;;
    --no-claude-bridge)   WITH_CLAUDE_BRIDGE=false ;;
    --no-backup)          NO_BACKUP=true ;;
    -*)
      echo "エラー: 不明なオプション: $arg" >&2
      exit 1
      ;;
    *) if [ -z "$TARGET" ]; then TARGET="$arg"; fi ;;
  esac
done

if [ "$LEGACY_CLAUDE" = true ] && [ "$CURSOR_ONLY" = true ]; then
  echo "エラー: --legacy-claude と --cursor-only は同時に指定できません" >&2
  exit 1
fi

if [ -z "$TARGET" ]; then
  echo "エラー: ターゲットプロジェクトのパスを指定してください" >&2
  echo "Usage: bash init.sh /path/to/target-project [--yes] [--legacy-claude|--cursor-only] [--with-agents-md] [--no-hooks] [--no-agents] [--no-backup]" >&2
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

CKMS_LIST_ONLY=1
# shellcheck source=_skill-base.sh
source "$SCRIPT_DIR/_skill-base.sh"
unset CKMS_LIST_ONLY

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

echo "=== Cursor Knowledge Management System セットアップ (v6.2.1) ==="
echo "ターゲット: $TARGET"
echo "モード:     $LABEL"
echo "hooks:      $([ "$WITH_HOOKS" = true ] && echo '配置する' || echo '配置しない')"
echo "subagent:   $([ "$WITH_AGENTS" = true ] && echo '配置する' || echo '配置しない')"
echo "AGENTS.md:  $([ "$WITH_AGENTS_MD" = true ] && echo '配置する（CLAUDE.md も作成）' || echo '配置しない')"
if [ "$MODE" = "agents" ]; then
  echo "Claude Code 橋渡し (.claude/skills): $([ "$WITH_CLAUDE_BRIDGE" = true ] && echo '作成する' || echo '作成しない')"
fi
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
SKILLS_BACKUP=""

# スキル内の利用者データをコピーする。rel は skills/ からの相対パス。
# 第4引数が overlay のとき、ディレクトリは消さずに利用者のファイルを重ねる。
# 同じパスは利用者側が優先され、配布元だけにあるファイルは残る。
ckms_copy_preserved() {
  local skill_name="$1"
  local from="$2"
  local to="$3"
  local mode="${4:-replace}"
  local rel inner parent
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    case "$rel" in
      "$skill_name"/*) ;;
      *) continue ;;
    esac
    inner=${rel#"$skill_name"/}
    # シンボリックリンクはリンクのまま置く。overlay で中身をたどると、
    # 共有先へのリンクが実ディレクトリのコピーに変わる。
    if [ -L "$from/$inner" ]; then
      parent=$(dirname "$inner")
      mkdir -p "$to/$parent" || return 1
      rm -rf "$to/$inner" || return 1
      cp -a "$from/$inner" "$to/$inner" || return 1
    elif [ -d "$from/$inner" ]; then
      if [ "$mode" = overlay ]; then
        mkdir -p "$to/$inner" || return 1
        cp -a "$from/$inner/." "$to/$inner/" || return 1
      else
        parent=$(dirname "$inner")
        mkdir -p "$to/$parent" || return 1
        rm -rf "$to/$inner" || return 1
        cp -a "$from/$inner" "$to/$inner" || return 1
      fi
    elif [ -e "$from/$inner" ]; then
      parent=$(dirname "$inner")
      mkdir -p "$to/$parent" || return 1
      rm -f "$to/$inner" || return 1
      cp -a "$from/$inner" "$to/$inner" || return 1
    fi
  done < <(ckms_preserved_dirs; ckms_preserved_files)
}

ckms_replace_skill() {
  local name="$1"
  local src="$SOURCE_SKILLS/$name"
  local dest="$SKILLS_DEST/$name"
  local stage
  if [ ! -d "$dest" ]; then
    cp -a "$src" "$dest"
    echo "  追加: $name"
    return
  fi
  if [ -f "$dest/SKILL.md" ] && [ -f "$src/SKILL.md" ] && ! cmp -s "$dest/SKILL.md" "$src/SKILL.md"; then
    if [ -n "$SKILLS_BACKUP" ]; then
      echo "  警告: $name/SKILL.md は配布元と異なります（版の更新でも、カスタマイズでも起きます）。新しい内容で置き換えます。カスタマイズしていた場合は ${SKILLS_BACKUP}/$name/SKILL.md から戻してください"
    else
      echo "  警告: $name/SKILL.md は配布元と異なります。新しい内容で置き換えます（--no-backup のため退避していません）"
    fi
  fi
  stage=$(mktemp -d)
  incoming=""
  replaced_old=""
  # 失敗表示は呼び出し側で行う。trap ERR は set -E が無いと内側の関数まで
  # 届かず、届いても呼び出し元の変数が見えない。
  ckms_copy_preserved "$name" "$dest" "$stage" \
    || ckms_preserve_fail "$name" "$stage" "" "" "$dest" partial
  incoming=$(mktemp -d "$(dirname "$SKILLS_DEST")/.ckms-incoming.XXXXXX")
  cp -a "$src" "$incoming/$name" \
    || ckms_preserve_fail "$name" "$stage" "$incoming" "" "$dest"
  ckms_copy_preserved "$name" "$stage" "$incoming/$name" overlay \
    || ckms_preserve_fail "$name" "$stage" "$incoming" "" "$dest"
  # 同じボリューム内の rename にして、別ボリュームの mv 失敗を避ける。
  # 先に導入先をどかし、新しい方を置いてから古い方を消す。
  # どかし先は mktemp で作った空のディレクトリの中にする。既存の名前と
  # ぶつかると mv はその中へ入れてしまい、後の rm -rf で巻き込む。
  replaced_box=$(mktemp -d "$(dirname "$SKILLS_DEST")/.ckms-replaced.XXXXXX") \
    || ckms_preserve_fail "$name" "$stage" "$incoming" "" "$dest"
  replaced_old="$replaced_box/$name"
  swapped=""
  # 2 つの mv の間で中断されると、配置先が空になる。元に戻してから終える。
  trap ckms_swap_interrupted INT TERM
  if ! mv "$dest" "$replaced_old"; then
    trap - INT TERM
    rmdir "$replaced_box" 2>/dev/null || true
    ckms_preserve_fail "$name" "$stage" "$incoming" "" "$dest"
  fi
  if ! mv "$incoming/$name" "$dest"; then
    trap - INT TERM
    if [ -e "$dest" ]; then
      echo "エラー: 新しいスキルを置けませんでした。元のスキルは ${replaced_old} に残しています" >&2
    else
      mv "$replaced_old" "$dest" \
        || echo "エラー: 入れ替え前のスキルを戻せません: $replaced_old" >&2
    fi
    ckms_preserve_fail "$name" "$stage" "$incoming" "$replaced_old" "$dest"
  fi
  swapped=1
  trap - INT TERM
  rm -rf "$replaced_box" "$stage" "$incoming"
  echo "  更新: $name"
}

# ckms_replace_skill の入れ替え中に INT / TERM を受けたときの後始末。
# 変数は呼び出し中の ckms_replace_skill のローカル（動的スコープ）を読む。
ckms_swap_interrupted() {
  trap - INT TERM
  echo "" >&2
  echo "中断しました。" >&2
  if [ -z "${swapped:-}" ] && [ ! -e "$dest" ] && [ -e "$replaced_old" ]; then
    if mv "$replaced_old" "$dest"; then
      rmdir "$replaced_box" 2>/dev/null || true
    else
      echo "エラー: 入れ替え前のスキルを戻せません: $replaced_old" >&2
    fi
  fi
  if [ -n "${swapped:-}" ]; then
    echo "  $name は更新済みです。一時ディレクトリが残っています: $stage $replaced_box" >&2
    exit 130
  fi
  ckms_preserve_fail "$name" "$stage" "$incoming" "$replaced_old" "$dest"
}

ckms_preserve_fail() {
  # $6 が partial のときだけ、退避先が途中までである旨を出す。
  # 付けるのは、利用者データの最初のコピーが失敗した呼び出しだけ。
  echo "エラー: $1 の置き換えに失敗しました。利用者データの退避先: $2" >&2
  if [ -n "${3:-}" ] && [ -d "$3" ]; then
    echo "      組み立て済みのコピー: $3" >&2
  fi
  if [ -n "${4:-}" ] && [ -e "$4" ]; then
    echo "      入れ替え前のスキル: $4" >&2
    if [ -n "${5:-}" ] && [ -e "$5" ]; then
      echo "      配置先 $5 を削除してから、入れ替え前のスキルをそこへ移動してください。" >&2
    elif [ -n "${5:-}" ]; then
      echo "      入れ替え前のスキルを配置先 $5 へ移動してください。" >&2
    fi
  else
    echo "      導入先は変更していません。" >&2
    if [ "${6:-}" = partial ]; then
      echo "      表示した退避先は途中までのコピーです。" >&2
    fi
  fi
  exit 1
}

# skills/
# 初回は配布元をそのまま置く。再実行は配布元にあるスキルだけを置き換え、
# 記録・テンプレート・配布元に無いスキルは残す。
if [ ! -f "$SOURCE_ROOT/.cursor-plugin/plugin.json" ]; then
  echo "警告: 配布元が CKMS リポジトリではありません: $SOURCE_ROOT" >&2
  echo "      別プロジェクトの init.sh を使うと、その記録が導入先に入ります。" >&2
  echo "      CKMS リポジトリの init.sh を使ってください。" >&2
fi
if [ -d "$SKILLS_DEST" ]; then
  if [ -L "$SKILLS_DEST" ]; then
    echo "情報: $SKILLS_DEST はシンボリックリンクです（変更しません）"
  else
    source_real=$(cd -P "$SOURCE_SKILLS" && pwd)
    dest_real=$(cd -P "$SKILLS_DEST" && pwd)
    if [ "$source_real" = "$dest_real" ]; then
      echo "エラー: 配布元と導入先が同じディレクトリです: $dest_real" >&2
      echo "      CKMS リポジトリの init.sh を、導入先のパスを引数にして実行してください。" >&2
      exit 1
    fi
    skill_count=0
    for skill_dir in "$SOURCE_SKILLS"/*/; do
      [ -d "$skill_dir" ] || continue
      skill_count=$((skill_count + 1))
    done
    echo "情報: $SKILLS_DEST は既に存在します"
    echo "  CKMS の ${skill_count} スキルを置き換えます。decisions/ patterns/ improvements/ と *_TEMPLATE.md、プロジェクト固有のスキルは残します。"
    if confirm "続行しますか?"; then
      if [ "$NO_BACKUP" != true ]; then
        SKILLS_BACKUP="${SKILLS_DEST}.backup-$(date +%Y%m%d-%H%M%S)"
        backup_n=0
        while [ -e "$SKILLS_BACKUP" ]; do
          backup_n=$((backup_n + 1))
          SKILLS_BACKUP="${SKILLS_DEST}.backup-$(date +%Y%m%d-%H%M%S)-${backup_n}"
        done
        cp -a "$SKILLS_DEST" "$SKILLS_BACKUP" || {
          echo "エラー: バックアップの作成に失敗しました: $SKILLS_BACKUP" >&2
          echo "      作りかけのため削除します。" >&2
          rm -rf "$SKILLS_BACKUP"
          exit 1
        }
        echo "  バックアップ: $SKILLS_BACKUP"
      fi
      for skill_dir in "$SOURCE_SKILLS"/*/; do
        [ -d "$skill_dir" ] || continue
        ckms_replace_skill "$(basename "$skill_dir")"
      done
      for skill_dir in "$SKILLS_DEST"/*/; do
        [ -d "$skill_dir" ] || continue
        skill_name=$(basename "$skill_dir")
        if [ ! -d "$SOURCE_SKILLS/$skill_name" ]; then
          echo "  情報: $skill_name は配布元に無いので残しました"
        fi
      done
      echo "skills/ を更新しました"
    else
      echo "  skills/ の更新をスキップしました"
    fi
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

# .claude/skills への橋渡し（Claude Code 用）
# Claude Code は .agents/skills を標準では探索しないため、シンボリックリンクで
# 橋渡しする。複製すると更新のたびに drift するため、リンクが張れない環境
# （主に Windows で core.symlinks 未設定の場合）だけコピーにフォールバックする。
if [ "$MODE" = "agents" ] && [ "$WITH_CLAUDE_BRIDGE" = true ]; then
  CLAUDE_SKILLS_DEST="$TARGET/.claude/skills"
  if [ -e "$CLAUDE_SKILLS_DEST" ] || [ -L "$CLAUDE_SKILLS_DEST" ]; then
    echo "情報: $CLAUDE_SKILLS_DEST は既に存在します（変更しません）"
  else
    mkdir -p "$TARGET/.claude"
    if ln -s "../${BASE_DIR}/skills" "$CLAUDE_SKILLS_DEST" 2>/dev/null; then
      echo "Claude Code 用に .claude/skills を作成しました（$BASE_DIR/skills へのシンボリックリンク）"
    else
      cp -r "$SKILLS_DEST" "$CLAUDE_SKILLS_DEST"
      echo "警告: シンボリックリンクを作成できなかったため .claude/skills をコピーしました"
      echo "      このコピーは自動追従しません。$BASE_DIR/skills を更新したら再実行してください"
    fi
  fi
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

    # Claude Code 用 hooks（.agents 配置かつ橋渡しが有効な場合のみ）
    if [ "$MODE" = "agents" ] && [ "$WITH_CLAUDE_BRIDGE" = true ] && [ -d "${SOURCE_HOOKS}/claude-code" ]; then
      # ソースの構造（hooks/_hook-lib.sh を hooks/claude-code/*.sh が ../ で参照）を
      # そのまま維持して配置する。symlink は使わない（Windows で git の symlink
      # サポートが無効な checkout だと壊れた参照ファイルになるため）。
      CLAUDE_HOOKS_DEST="$TARGET/.claude/hooks"
      mkdir -p "$CLAUDE_HOOKS_DEST/claude-code"
      cp "${SOURCE_HOOKS}/_hook-lib.sh" "$CLAUDE_HOOKS_DEST/"
      cp "${SOURCE_HOOKS}/claude-code"/*.sh "$CLAUDE_HOOKS_DEST/claude-code/"
      chmod +x "$CLAUDE_HOOKS_DEST/_hook-lib.sh" "$CLAUDE_HOOKS_DEST/claude-code"/*.sh
      echo "Claude Code 用 hooks スクリプトを配置しました: $CLAUDE_HOOKS_DEST"

      CLAUDE_SETTINGS="$TARGET/.claude/settings.json"
      CLAUDE_SETTINGS_SRC="${SOURCE_TEMPLATES}/.claude/settings.json.template"
      if [ -f "$CLAUDE_SETTINGS" ]; then
        echo "情報: $CLAUDE_SETTINGS は既に存在します（上書きしません）"
        echo "      hooks / permissions を手動で統合してください: $CLAUDE_SETTINGS_SRC"
      elif [ -f "$CLAUDE_SETTINGS_SRC" ]; then
        cp "$CLAUDE_SETTINGS_SRC" "$CLAUDE_SETTINGS"
        echo "settings.json を作成しました: $CLAUDE_SETTINGS"
      fi
    fi
  fi
fi

# .cursorignore
CURSORIGNORE_SRC="${SOURCE_TEMPLATES}/.cursorignore"
if [ -f "$CURSORIGNORE_SRC" ]; then
  if [ -f "$TARGET/.cursorignore" ]; then
    if cmp -s "$CURSORIGNORE_SRC" "$TARGET/.cursorignore"; then
      echo "情報: $TARGET/.cursorignore は既に存在します（上書きしません）"
    else
      echo "情報: $TARGET/.cursorignore は既に存在し、配布元と差分があります（上書きしません）"
    fi
    # v6.1.1 以前の .cursorignore には退避先の除外が無い。再実行で作る
    # skills.backup-*/ が索引に入り、古い記録が検索に混じる。
    if ! grep -q 'skills\.backup-' "$TARGET/.cursorignore"; then
      echo "  再実行の退避先を索引から外すため、次の行を $TARGET/.cursorignore に追加してください:"
      grep 'skills\.backup-' "$CURSORIGNORE_SRC" | sed 's/^/    /'
    fi
  else
    cp "$CURSORIGNORE_SRC" "$TARGET/.cursorignore"
    echo ".cursorignore をコピーしました"
  fi
fi

# AGENTS.md（+ CLAUDE.md からの import）
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

  # Claude Code は AGENTS.md を自動では読まないため、import 一行だけの
  # CLAUDE.md を置いて橋渡しする（本文は複製しない）。
  CLAUDE_MD_DEST="$TARGET/CLAUDE.md"
  if [ -f "$CLAUDE_MD_DEST" ]; then
    echo "情報: $TARGET/CLAUDE.md は既に存在します（上書きしません）"
    echo "      AGENTS.md を読ませるには '@AGENTS.md' の行を追加してください"
  else
    printf '@AGENTS.md\n' > "$CLAUDE_MD_DEST"
    echo "CLAUDE.md を作成しました（@AGENTS.md を import）"
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
  agents)
    if [ "$WITH_CLAUDE_BRIDGE" = true ]; then
      echo "（Cursor は .agents/skills を、Claude Code は .claude/skills 経由の橋渡しで読み込みます。Codex は .agents/skills を直接読みます）"
    else
      echo "（Cursor / Codex は .agents/skills を読み込みます。Claude Code 用の橋渡しは --no-claude-bridge で無効化されています）"
    fi
    ;;
  claude) echo "（Cursor / Claude Code で .claude/skills を共有利用できます）" ;;
  cursor) echo "（.cursor/skills は Cursor のみが読み込みます）" ;;
esac
