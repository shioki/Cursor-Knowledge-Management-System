#!/usr/bin/env bash
# project-setup: 知識管理システムの構造を検証するスクリプト (v6.0.0)
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

echo "=== Cursor Knowledge Management System 構造検証 (v6.0.0) ==="
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

# 知識ディレクトリ
echo "--- 知識ディレクトリ検証 ---"
for entry in \
  "${SKILLS_BASE}/knowledge-management/references/decisions:技術判断" \
  "${SKILLS_BASE}/pattern-library/references/patterns:実装パターン" \
  "${SKILLS_BASE}/improvement-tracking/references/improvements:改善記録" \
  "${DATA_BASE}/debug-sessions:デバッグセッション"
do
  dir="${entry%%:*}"
  label="${entry##*:}"
  if [ -d "$dir" ]; then
    count=$(find "$dir" -maxdepth 1 -name '*.md' ! -name 'README.md' 2>/dev/null | wc -l | tr -d ' ')
    echo "  [OK] ${label}: ${dir}（${count} 件）"
  else
    echo "  [INFO] ${label}のディレクトリは未作成です: ${dir}（最初の記録時に作成されます）"
  fi
done

echo ""

# スクリプトの実行権限チェック
echo "--- スクリプト権限検証 ---"
SCRIPT_COUNT=0
MISSING_EXEC=0
for base in .agents/skills .claude/skills .cursor/skills .cursor/hooks; do
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
