#!/usr/bin/env bash
# project-setup: v2.x (.cursor/rules) から v4.0.0 (skills + commands) への移行スクリプト
#
# Usage: bash migrate-from-rules.sh /path/to/target-project [--no-confirm]
#
# 引数:
#   $1 - ターゲットプロジェクトのパス（必須）
#   --no-confirm - 確認プロンプトをスキップ（任意）
#
# 処理内容:
#   1. 旧ファイルを .cursor/backup-v2/ にバックアップ
#   2. 新しい skills/ と commands/ をコピー
#   3. 旧データファイルの内容を新しい references/ に転記
#   4. 旧 rules/ ディレクトリを削除
#   5. 移行結果のレポートを出力

set -euo pipefail

# --- 設定 ---
TARGET="${1:?エラー: ターゲットプロジェクトのパスを指定してください}"
NO_CONFIRM=false
if [[ "${2:-}" == "--no-confirm" ]]; then
  NO_CONFIRM=true
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_CLAUDE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
TEMPLATES_ROOT="$(cd "$TEMPLATES_CLAUDE_DIR/.." && pwd)"
TEMPLATES_CURSOR_DIR="${TEMPLATES_ROOT}/.cursor"

BACKUP_DIR="$TARGET/.cursor/backup-v2"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# カウンタ
MIGRATED=0
SKIPPED=0
ERRORS=0

# --- ユーティリティ関数 ---
log_info()  { echo "[migrate] INFO:  $*"; }
log_warn()  { echo "[migrate] WARN:  $*"; }
log_error() { echo "[migrate] ERROR: $*"; }
log_ok()    { echo "[migrate] OK:    $*"; }

confirm() {
  if $NO_CONFIRM; then return 0; fi
  local prompt="${1:-続行しますか?} (y/N): "
  read -r -p "$prompt" REPLY
  [[ "$REPLY" =~ ^[Yy]$ ]]
}

# --- 前提チェック ---
if [ ! -d "$TARGET" ]; then
  log_error "ディレクトリが見つかりません: $TARGET"
  exit 1
fi

if [ ! -d "$TARGET/.cursor" ]; then
  log_error ".cursor ディレクトリが見つかりません: $TARGET/.cursor"
  log_error "Cursor プロジェクトではないか、まだ初期化されていません"
  exit 1
fi

# --- 旧構造の検出 ---
echo ""
echo "========================================="
echo "  v2.x → v4.0.0 マイグレーションツール"
echo "========================================="
echo ""
echo "ターゲット: $TARGET"
echo ""

log_info "旧構造を検出中..."

HAS_RULES=false
HAS_DATA=false
FOUND_RULES=()
FOUND_DATA=()

# rules/ の検出
if [ -d "$TARGET/.cursor/rules" ]; then
  HAS_RULES=true
  while IFS= read -r -d '' file; do
    FOUND_RULES+=("$(basename "$file")")
  done < <(find "$TARGET/.cursor/rules" -name "*.mdc" -print0 2>/dev/null)
  log_info "rules/ ディレクトリを検出: ${#FOUND_RULES[@]} 個の .mdc ファイル"
  for f in "${FOUND_RULES[@]}"; do
    echo "         - $f"
  done
fi

# データファイルの検出
DATA_FILES=("knowledge.md" "patterns.md" "context.md" "debug-log.md" "improvements.md")
for df in "${DATA_FILES[@]}"; do
  if [ -f "$TARGET/.cursor/$df" ]; then
    HAS_DATA=true
    FOUND_DATA+=("$df")
  fi
done

if $HAS_DATA; then
  log_info "データファイルを検出: ${#FOUND_DATA[@]} 個"
  for f in "${FOUND_DATA[@]}"; do
    echo "         - .cursor/$f"
  done
fi

if ! $HAS_RULES && ! $HAS_DATA; then
  log_warn "v2.x の構造が検出されませんでした"
  log_info "新規セットアップの場合は init.sh を使用してください"
  exit 0
fi

# 既にスキルが存在するか確認（v4 は .claude/skills に配置）
if [ -d "$TARGET/.claude/skills" ]; then
  log_warn ".claude/skills/ ディレクトリが既に存在します"
  if ! confirm "上書きしますか?"; then
    log_info "中止しました"
    exit 0
  fi
fi

echo ""
if ! confirm "移行を開始しますか?"; then
  log_info "中止しました"
  exit 0
fi

# --- Phase 1: バックアップ ---
echo ""
log_info "Phase 1: バックアップを作成中..."

mkdir -p "$BACKUP_DIR"

if $HAS_RULES; then
  cp -r "$TARGET/.cursor/rules" "$BACKUP_DIR/rules_${TIMESTAMP}"
  log_ok "rules/ → backup-v2/rules_${TIMESTAMP}"
fi

for df in "${FOUND_DATA[@]}"; do
  cp "$TARGET/.cursor/$df" "$BACKUP_DIR/${df%.md}_${TIMESTAMP}.md"
  log_ok ".cursor/$df → backup-v2/${df%.md}_${TIMESTAMP}.md"
done

log_ok "バックアップ完了: $BACKUP_DIR"

# --- Phase 2: 新構造のコピー ---
echo ""
log_info "Phase 2: 新しい skills/ と commands/ をコピー中..."

# skills/ のコピー（v4: .claude/skills に配置）
mkdir -p "$TARGET/.claude"
cp -r "$TEMPLATES_CLAUDE_DIR/skills" "$TARGET/.claude/skills"
log_ok "skills/ を .claude/skills にコピーしました"

# debug-sessions/ の作成
mkdir -p "$TARGET/.claude/debug-sessions"
touch "$TARGET/.claude/debug-sessions/.gitkeep" 2>/dev/null || true
log_ok "debug-sessions/ を作成しました"

# commands/ のコピー（Cursor 専用）
if [ -d "$TEMPLATES_CURSOR_DIR/commands" ]; then
  mkdir -p "$TARGET/.cursor"
  cp -r "$TEMPLATES_CURSOR_DIR/commands" "$TARGET/.cursor/commands"
  log_ok "commands/ をコピーしました"
fi

# スクリプトに実行権限を付与
find "$TARGET/.claude/skills" -name "*.sh" -exec chmod +x {} \;
log_ok "スクリプトに実行権限を付与しました"

# .cursorignore の更新
if [ -f "$TEMPLATES_ROOT/.cursorignore" ]; then
  if [ -f "$TARGET/.cursorignore" ]; then
    cp "$TARGET/.cursorignore" "$BACKUP_DIR/cursorignore_${TIMESTAMP}"
    log_ok ".cursorignore をバックアップしました"
  fi
  cp "$TEMPLATES_ROOT/.cursorignore" "$TARGET/.cursorignore"
  log_ok ".cursorignore を更新しました"
fi

# --- Phase 3: データ転記 ---
echo ""
log_info "Phase 3: 旧データを新しい references/ に転記中..."

# マッピング定義: 旧ファイル → 新ファイル（v4: .claude/skills 以下）
declare -A DATA_MAP=(
  ["knowledge.md"]=".claude/skills/knowledge-management/references/KNOWLEDGE_TEMPLATE.md"
  ["patterns.md"]=".claude/skills/pattern-library/references/PATTERNS_TEMPLATE.md"
  ["context.md"]=".claude/skills/project-context/references/CONTEXT_TEMPLATE.md"
  ["debug-log.md"]=".claude/skills/debug-workflow/references/DEBUG_TEMPLATE.md"
  ["improvements.md"]=".claude/skills/improvement-tracking/references/IMPROVEMENTS_TEMPLATE.md"
)

for df in "${FOUND_DATA[@]}"; do
  SRC="$TARGET/.cursor/$df"
  DEST_REL="${DATA_MAP[$df]:-}"

  if [ -z "$DEST_REL" ]; then
    log_warn "マッピングが見つかりません: $df（スキップ）"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  DEST="$TARGET/$DEST_REL"

  # 旧ファイルにユーザーデータがあるか確認（テンプレートのままかどうか）
  # 「📋 ファイル概要」があればテンプレートのまま
  if grep -q "📋 ファイル概要" "$SRC" 2>/dev/null; then
    # テンプレートヘッダーを除いたユーザーデータ部分を抽出
    # 「---」以降のコンテンツを取得
    USER_CONTENT=$(sed -n '/^---$/,$ { /^---$/d; p; }' "$SRC" | tail -n +2)

    if [ -z "$(echo "$USER_CONTENT" | tr -d '[:space:]')" ]; then
      log_warn "$df はテンプレートのままです（データなし、スキップ）"
      SKIPPED=$((SKIPPED + 1))
      continue
    fi
  fi

  # 旧ファイルの内容が実質空でないか確認
  CONTENT_SIZE=$(wc -c < "$SRC" | tr -d ' ')
  if [ "$CONTENT_SIZE" -lt 50 ]; then
    log_warn "$df は内容が少なすぎます（スキップ）"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # 新テンプレートの先頭部分（タイトルとセクション構造）を保持しつつ、
  # 旧ファイルの全内容を末尾に追記
  {
    echo ""
    echo "<!-- === v2.x からの移行データ（$(date +%Y-%m-%d)） === -->"
    echo ""
    cat "$SRC"
    echo ""
    echo "<!-- === 移行データここまで === -->"
  } >> "$DEST"

  log_ok "$df → $DEST_REL に転記しました"
  MIGRATED=$((MIGRATED + 1))
done

# --- Phase 4: 旧ファイル削除 ---
echo ""
log_info "Phase 4: 旧ファイルの削除..."

if $HAS_RULES; then
  if confirm "旧 rules/ ディレクトリを削除しますか?（バックアップ済み）"; then
    rm -rf "$TARGET/.cursor/rules"
    log_ok "rules/ を削除しました"
  else
    log_warn "rules/ は残しました（手動で削除してください）"
  fi
fi

if [ ${#FOUND_DATA[@]} -gt 0 ]; then
  if confirm "旧データファイルを削除しますか?（バックアップ済み）"; then
    for df in "${FOUND_DATA[@]}"; do
      rm -f "$TARGET/.cursor/$df"
      log_ok ".cursor/$df を削除しました"
    done
  else
    log_warn "旧データファイルは残しました（手動で削除してください）"
  fi
fi

# --- レポート ---
echo ""
echo "========================================="
echo "  移行レポート"
echo "========================================="
echo ""
echo "  転記したファイル: $MIGRATED 件"
echo "  スキップ:         $SKIPPED 件"
echo "  エラー:           $ERRORS 件"
echo ""
echo "  バックアップ先:   $BACKUP_DIR"
echo ""
echo "  新しいスキル:     $(find "$TARGET/.claude/skills" -name "SKILL.md" | wc -l | tr -d ' ') 個"
echo "  新しいコマンド:   $(find "$TARGET/.cursor/commands" -name "*.md" 2>/dev/null | wc -l | tr -d ' ') 個"
echo ""
echo "========================================="
echo ""
echo "次のステップ:"
echo "  1. 転記されたデータを確認・整理してください"
echo "     各 references/ ファイルの <!-- 移行データ --> 部分を適切なセクションに振り分けてください"
echo ""
echo "  2. team-standards スキルをカスタマイズしてください"
echo "     .claude/skills/team-standards/SKILL.md をプロジェクトの規約に更新"
echo ""
echo "  3. 構造を検証してください"
echo "     bash .claude/skills/project-setup/scripts/validate.sh"
echo ""
echo "  4. Cursor で動作確認してください"
echo "     - Cursor Settings > Rules でスキルが表示されること"
echo "     - チャットで / を入力してコマンドが表示されること"
echo ""

if [ "$ERRORS" -gt 0 ]; then
  exit 1
fi
exit 0
