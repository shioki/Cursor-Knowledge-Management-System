#!/usr/bin/env bash
# スキル・データディレクトリのパス検出（プロジェクトルートから実行を想定）
# 優先順: .agents/skills → .claude/skills → .cursor/skills
# v5.0.0: .agents/skills を正規ディレクトリとして優先。
#         .claude/skills / .cursor/skills も後方互換でサポート。

if [ -n "${SKILL_ROOT:-}" ]; then
  SKILL_BASE="$SKILL_ROOT"
elif [ -d ".agents/skills" ]; then
  SKILL_BASE=".agents/skills"
elif [ -d ".claude/skills" ]; then
  SKILL_BASE=".claude/skills"
elif [ -d ".cursor/skills" ]; then
  SKILL_BASE=".cursor/skills"
else
  echo "エラー: .agents/skills / .claude/skills / .cursor/skills のいずれも見つかりません"
  echo "プロジェクトルートから実行してください"
  exit 1
fi

# データディレクトリ（debug-sessions 等）
# v5.0.0: .agents > .claude > .cursor の順で優先
if [ -d ".agents/debug-sessions" ] || [ -d ".agents/skills" ]; then
  DATA_BASE=".agents"
elif [ -d ".claude/debug-sessions" ] || [ -d ".claude/skills" ]; then
  DATA_BASE=".claude"
elif [ -d ".cursor/debug-sessions" ] || [ -d ".cursor/skills" ]; then
  DATA_BASE=".cursor"
else
  DATA_BASE=".agents"
fi
