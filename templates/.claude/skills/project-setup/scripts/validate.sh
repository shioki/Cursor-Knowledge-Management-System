#!/usr/bin/env bash
# project-setup: 知識管理システムの構造を検証するスクリプト
#
# Usage: bash .claude/skills/project-setup/scripts/validate.sh
#        （.cursor/skills にも対応）
#
# プロジェクトルートから実行してください

set -euo pipefail

ERRORS=0
WARNINGS=0

# スキル配置先を検出（.claude 優先、.cursor にフォールバック）
if [ -d ".claude/skills" ]; then
  SKILLS_BASE=".claude/skills"
elif [ -d ".cursor/skills" ]; then
  SKILLS_BASE=".cursor/skills"
else
  echo "エラー: .claude/skills または .cursor/skills が見つかりません"
  exit 1
fi

echo "=== Cursor Knowledge Management System 構造検証 (v4.0.0) ==="
echo "スキル配置: ${SKILLS_BASE}"
echo ""

# スキルの検証
EXPECTED_SKILLS=(
  "project-context"
  "team-standards"
  "knowledge-management"
  "pattern-library"
  "debug-workflow"
  "improvement-tracking"
  "project-setup"
)

echo "--- スキル検証 ---"
for skill in "${EXPECTED_SKILLS[@]}"; do
  SKILL_DIR="${SKILLS_BASE}/${skill}"
  SKILL_FILE="${SKILL_DIR}/SKILL.md"

  if [ ! -d "$SKILL_DIR" ]; then
    echo "  [ERROR] スキルディレクトリが見つかりません: ${SKILL_DIR}"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  if [ ! -f "$SKILL_FILE" ]; then
    echo "  [ERROR] SKILL.md が見つかりません: ${SKILL_FILE}"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # フロントマターの確認
  if ! head -1 "$SKILL_FILE" | grep -q "^---"; then
    echo "  [ERROR] SKILL.md にフロントマターがありません: ${SKILL_FILE}"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # name フィールドの確認
  if ! grep -q "^name: ${skill}$" "$SKILL_FILE"; then
    echo "  [WARN] SKILL.md の name がフォルダ名と一致しません: ${skill}"
    WARNINGS=$((WARNINGS + 1))
  fi

  # description フィールドの確認
  if ! grep -q "^description:" "$SKILL_FILE"; then
    echo "  [ERROR] SKILL.md に description がありません: ${SKILL_FILE}"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  echo "  [OK] ${skill}"
done

echo ""

# コマンドの検証
echo "--- コマンド検証 ---"
COMMANDS_DIR=".cursor/commands"
if [ ! -d "$COMMANDS_DIR" ]; then
  echo "  [ERROR] コマンドディレクトリが見つかりません: ${COMMANDS_DIR}"
  ERRORS=$((ERRORS + 1))
else
  EXPECTED_COMMANDS=(
    "record-decision"
    "add-pattern"
    "start-debug"
    "log-improvement"
    "review-knowledge"
    "update-context"
  )
  for cmd in "${EXPECTED_COMMANDS[@]}"; do
    CMD_FILE="${COMMANDS_DIR}/${cmd}.md"
    if [ ! -f "$CMD_FILE" ]; then
      echo "  [ERROR] コマンドファイルが見つかりません: ${CMD_FILE}"
      ERRORS=$((ERRORS + 1))
    elif [ ! -s "$CMD_FILE" ]; then
      echo "  [ERROR] コマンドファイルが空です: ${CMD_FILE}"
      ERRORS=$((ERRORS + 1))
    else
      echo "  [OK] /${cmd}"
    fi
  done
fi

echo ""

# スクリプトの実行権限チェック（.claude と .cursor の両方）
echo "--- スクリプト権限検証 ---"
SCRIPT_COUNT=0
for base in .claude/skills .cursor/skills; do
  if [ -d "$base" ]; then
    while IFS= read -r script; do
      SCRIPT_COUNT=$((SCRIPT_COUNT + 1))
      if [ ! -x "$script" ]; then
        echo "  [WARN] 実行権限がありません: ${script}"
        WARNINGS=$((WARNINGS + 1))
      else
        echo "  [OK] ${script}"
      fi
    done < <(find "$base" -name "*.sh" 2>/dev/null)
  fi
done
if [ "$SCRIPT_COUNT" -eq 0 ]; then
  echo "  スクリプトが見つかりませんでした"
fi

echo ""
echo "=== 検証結果 ==="
echo "  エラー: ${ERRORS} 件"
echo "  警告: ${WARNINGS} 件"

if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo "エラーがあります。構造を修正してください。"
  exit 1
else
  echo ""
  echo "構造は正常です。"
  exit 0
fi
