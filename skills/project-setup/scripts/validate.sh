#!/usr/bin/env bash
# project-setup: 知識管理システムの構造を検証するスクリプト (v6.2.2)
#
# Usage: bash .agents/skills/project-setup/scripts/validate.sh
#        （.claude/skills / .cursor/skills も検出対象）
#
# プロジェクトルートから実行してください

set -euo pipefail

ERRORS=0
WARNINGS=0

# スキル配置先を検出（.agents 優先、.claude/.cursor にフォールバック）
if [ -d ".agents/skills" ]; then
  SKILLS_BASE=".agents/skills"
elif [ -d ".claude/skills" ]; then
  SKILLS_BASE=".claude/skills"
elif [ -d ".cursor/skills" ]; then
  SKILLS_BASE=".cursor/skills"
else
  echo "エラー: .agents/skills / .claude/skills / .cursor/skills のいずれも見つかりません"
  exit 1
fi

DATA_BASE="$(dirname "$SKILLS_BASE")"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CKMS_LIST_ONLY=1
# shellcheck source=_skill-base.sh
source "$SCRIPT_DIR/_skill-base.sh"
unset CKMS_LIST_ONLY

echo "=== Cursor Knowledge Management System 構造検証 (v6.2.2) ==="
echo "スキル配置: ${SKILLS_BASE}"
echo ""

# ドメインスキル: エージェントが文脈から自動選択する
DOMAIN_SKILLS=(
  "project-context"
  "team-standards"
  "knowledge-management"
  "pattern-library"
  "debug-workflow"
  "improvement-tracking"
  "project-setup"
)

# アクションスキル: ユーザーが / で明示起動する（disable-model-invocation: true）
ACTION_SKILLS=(
  "record-decision"
  "add-pattern"
  "start-debug"
  "log-improvement"
  "review-knowledge"
  "update-context"
)

check_skill() {
  local skill="$1" require_explicit="$2"
  local skill_dir="${SKILLS_BASE}/${skill}"
  local skill_file="${skill_dir}/SKILL.md"

  if [ ! -d "$skill_dir" ]; then
    echo "  [ERROR] スキルディレクトリが見つかりません: ${skill_dir}"
    ERRORS=$((ERRORS + 1))
    return
  fi

  if [ ! -f "$skill_file" ]; then
    echo "  [ERROR] SKILL.md が見つかりません: ${skill_file}"
    ERRORS=$((ERRORS + 1))
    return
  fi

  if ! head -1 "$skill_file" | grep -q "^---"; then
    echo "  [ERROR] SKILL.md にフロントマターがありません: ${skill_file}"
    ERRORS=$((ERRORS + 1))
    return
  fi

  if ! grep -q "^name: ${skill}$" "$skill_file"; then
    echo "  [WARN] SKILL.md の name がフォルダ名と一致しません: ${skill}"
    WARNINGS=$((WARNINGS + 1))
  fi

  if ! grep -q "^description:" "$skill_file"; then
    echo "  [ERROR] SKILL.md に description がありません: ${skill_file}"
    ERRORS=$((ERRORS + 1))
    return
  fi

  if [ "$require_explicit" = "true" ] \
    && ! grep -q "^disable-model-invocation:[[:space:]]*true$" "$skill_file"; then
    echo "  [WARN] アクションスキルに disable-model-invocation: true がありません: ${skill}"
    WARNINGS=$((WARNINGS + 1))
  fi

  # gh skill / marketplace 向けに license フィールドを確認（optional）
  if ! grep -q "^license:" "$skill_file"; then
    echo "  [WARN] SKILL.md に license フィールドがありません（gh skill 配布時に推奨）: ${skill}"
    WARNINGS=$((WARNINGS + 1))
  fi

  echo "  [OK] ${skill}"
}

echo "--- ドメインスキル検証 ---"
for skill in "${DOMAIN_SKILLS[@]}"; do
  check_skill "$skill" false
done

echo ""
echo "--- アクションスキル検証 ---"
for skill in "${ACTION_SKILLS[@]}"; do
  check_skill "$skill" true
done

echo ""

# 旧 .cursor/commands が残っていないか（v5 からの移行漏れ検出）
if [ -d ".cursor/commands" ]; then
  echo "--- 旧コマンドディレクトリ ---"
  echo "  [WARN] .cursor/commands が残っています。v6 ではアクションスキルへ統合されました。"
  echo "         内容を確認のうえ削除してください（残っていると / 候補が重複します）。"
  WARNINGS=$((WARNINGS + 1))
  echo ""
fi

# 知識ディレクトリ（保持対象は _skill-base.sh の一覧と揃える）
echo "--- 知識ディレクトリ検証 ---"
ckms_check_knowledge_dir() {
  local dir="$1" label="$2"
  if [ -d "$dir" ]; then
    count=$(find "$dir" -maxdepth 1 -name '*.md' ! -name 'README.md' 2>/dev/null | wc -l | tr -d ' ')
    echo "  [OK] ${label}: ${dir}（${count} 件）"
  else
    echo "  [INFO] ${label}のディレクトリは未作成です: ${dir}（最初の記録時に作成されます）"
  fi
}
while IFS= read -r rel; do
  [ -n "$rel" ] || continue
  case "$rel" in
    *decisions*) label="技術判断" ;;
    *patterns*) label="実装パターン" ;;
    *improvements*) label="改善記録" ;;
    *) label="$rel" ;;
  esac
  ckms_check_knowledge_dir "${SKILLS_BASE}/${rel}" "$label"
done < <(ckms_preserved_dirs)
ckms_check_knowledge_dir "${DATA_BASE}/debug-sessions" "デバッグセッション"

echo ""

# init の再実行が失敗・中断したときの残骸。skills/ 内の *.replacing.* は
# エージェントが同じ name のスキルとして読み込むことがある。
echo "--- 再実行の残骸 ---"
LEFTOVER_COUNT=0
while IFS= read -r leftover; do
  echo "  [WARN] init の再実行で残った一時ディレクトリです: ${leftover}"
  echo "         中の利用者データを確認してから削除してください"
  WARNINGS=$((WARNINGS + 1))
  LEFTOVER_COUNT=$((LEFTOVER_COUNT + 1))
done < <(
  find "$DATA_BASE" -mindepth 1 -maxdepth 1 -type d \( -name '.ckms-incoming*' -o -name '.ckms-replaced*' \) 2>/dev/null
  find "$SKILLS_BASE/" -mindepth 1 -maxdepth 1 -name '*.replacing.*' 2>/dev/null
)
BACKUP_COUNT=$(find "$DATA_BASE" -mindepth 1 -maxdepth 1 -type d -name 'skills.backup-*' 2>/dev/null | wc -l | tr -d ' ')
if [ "$BACKUP_COUNT" -gt 0 ]; then
  echo "  [INFO] 再実行前の退避が ${BACKUP_COUNT} 件あります: ${DATA_BASE}/skills.backup-*（不要なら削除できます）"
fi
if [ "$LEFTOVER_COUNT" -eq 0 ] && [ "$BACKUP_COUNT" -eq 0 ]; then
  echo "  [OK] 残骸はありません"
fi

echo ""

# スクリプトの実行権限チェック
echo "--- スクリプト権限検証 ---"
SCRIPT_COUNT=0
MISSING_EXEC=0
for base in .agents/skills .claude/skills .cursor/skills .cursor/hooks .claude/hooks; do
  # シンボリックリンク（Claude Code 橋渡し）は他の base の実体を指しているため、
  # 二重カウントを避けてここではスキップする（存在確認は別セクションで行う）。
  if [ -L "$base" ]; then
    continue
  fi
  if [ -d "$base" ]; then
    while IFS= read -r script; do
      SCRIPT_COUNT=$((SCRIPT_COUNT + 1))
      if [ ! -x "$script" ]; then
        echo "  [WARN] 実行権限がありません: ${script}"
        WARNINGS=$((WARNINGS + 1))
        MISSING_EXEC=$((MISSING_EXEC + 1))
      fi
    done < <(find "$base" -name "*.sh" 2>/dev/null)
  fi
done
if [ "$SCRIPT_COUNT" -eq 0 ]; then
  echo "  スクリプトが見つかりませんでした"
else
  echo "  ${SCRIPT_COUNT} 件を確認（実行権限なし: ${MISSING_EXEC} 件）"
fi

echo ""

# hooks / subagent（optional）
echo "--- 拡張コンポーネント ---"
if [ -f ".cursor/hooks.json" ]; then
  echo "  [OK] .cursor/hooks.json が見つかりました"
  if [ -f "${DATA_BASE}/knowledge-hooks.conf" ]; then
    echo "  [OK] hooks 設定: ${DATA_BASE}/knowledge-hooks.conf"
  else
    echo "  [INFO] hooks 設定はありません（既定値で動作します）"
  fi
else
  echo "  [INFO] hooks はありません（init.sh の --no-hooks を外すと配置されます）"
fi

if [ -f ".cursor/agents/knowledge-curator.md" ]; then
  echo "  [OK] knowledge-curator subagent が見つかりました"
else
  echo "  [INFO] knowledge-curator subagent はありません（/review-knowledge は単独でも動作します）"
fi

if [ -f "AGENTS.md" ]; then
  echo "  [OK] AGENTS.md が見つかりました"
else
  echo "  [INFO] AGENTS.md はありません（init.sh --with-agents-md で追加できます）"
fi

if [ -f "CLAUDE.md" ]; then
  if grep -q '^@AGENTS.md$' "CLAUDE.md" 2>/dev/null; then
    echo "  [OK] CLAUDE.md が見つかりました（@AGENTS.md を import）"
  else
    echo "  [WARN] CLAUDE.md はありますが @AGENTS.md の import がありません"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo "  [INFO] CLAUDE.md はありません（init.sh --with-agents-md で追加できます）"
fi

if [ "$SKILLS_BASE" = ".agents/skills" ]; then
  if [ -L ".claude/skills" ]; then
    if [ -d ".claude/skills" ]; then
      echo "  [OK] .claude/skills（Claude Code 橋渡し）が ${SKILLS_BASE} を正しく解決しています"
    else
      echo "  [ERROR] .claude/skills が壊れたシンボリックリンクです（リンク先が存在しません）"
      ERRORS=$((ERRORS + 1))
    fi
  elif [ -d ".claude/skills" ]; then
    echo "  [WARN] .claude/skills がシンボリックリンクではなくコピーです。${SKILLS_BASE} の更新が反映されません"
    WARNINGS=$((WARNINGS + 1))
  else
    echo "  [INFO] .claude/skills（Claude Code 橋渡し）はありません（init.sh --no-claude-bridge を外すと作成されます）"
  fi
fi

echo ""
echo "=== 検証結果 ==="
echo "  エラー: ${ERRORS} 件"
echo "  警告: ${WARNINGS} 件"

if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo "エラーがあります。構造を修正してください。"
  exit 1
fi

echo ""
echo "構造は正常です。"
