#!/usr/bin/env bash
# スキル・データディレクトリのパス検出（プロジェクトルートから実行を想定）
# Cursor / Claude Code 共用対応: .claude 優先、.cursor にフォールバック

if [ -n "${SKILL_ROOT:-}" ]; then
  SKILL_BASE="$SKILL_ROOT"
elif [ -d ".claude/skills" ]; then
  SKILL_BASE=".claude/skills"
elif [ -d ".cursor/skills" ]; then
  SKILL_BASE=".cursor/skills"
else
  echo "エラー: .claude/skills または .cursor/skills が見つかりません"
  echo "プロジェクトルートから実行してください"
  exit 1
fi

# データディレクトリ（debug-sessions 等）
if [ -d ".claude/debug-sessions" ] || [ -d ".claude/skills" ]; then
  DATA_BASE=".claude"
elif [ -d ".cursor/debug-sessions" ] || [ -d ".cursor/skills" ]; then
  DATA_BASE=".cursor"
else
  DATA_BASE=".claude"
fi
