#!/usr/bin/env bash
# 導入済みプロジェクトへの init 再実行が、記録とプロジェクト固有スキルを残すことを確認する。
#
# 先に対象へ 1 回導入しておくこと。このスクリプトが記録を足してから、渡したコマンドで再実行する。
#
# Usage: bash scripts/smoke-init-rerun.sh <target> <base-dir> -- <init command...>
#   base-dir は .agents / .claude / .cursor
set -euo pipefail

if [ "$#" -lt 4 ] || [ "${3:-}" != "--" ]; then
  echo "Usage: bash scripts/smoke-init-rerun.sh <target> <base-dir> -- <init command...>" >&2
  exit 1
fi

TARGET="$1"
BASE="$2"
shift 3
SKILLS="$TARGET/$BASE/skills"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ ! -d "$SKILLS/knowledge-management" ]; then
  echo "error: skills are not installed at $SKILLS" >&2
  exit 1
fi

shopt -s nullglob
existing_backups=("$TARGET/$BASE"/skills.backup-*)
shopt -u nullglob
if [ "${#existing_backups[@]}" -ne 0 ]; then
  echo "error: backup already exists before rerun: ${existing_backups[0]}" >&2
  exit 1
fi

DECISIONS="$SKILLS/knowledge-management/references/decisions"
mkdir -p "$DECISIONS" "$SKILLS/my-project-skill" "$SKILLS/requirements-spec"
printf '%s\n' "test" > "$DECISIONS/2026-09-26-sample.md"
printf '%s\n' "| 2026-09-26 | sample row | [2026-09-26-sample.md](2026-09-26-sample.md) |" >> "$DECISIONS/README.md"
printf -- '%s\n' "---" "name: my-project-skill" "description: プロジェクト固有のスキルの例です。再実行で消えないことを確かめる。" "---" > "$SKILLS/my-project-skill/SKILL.md"
printf -- '%s\n' "---" "name: requirements-spec" "description: ほかの配布元のスキルの例です。" "---" > "$SKILLS/requirements-spec/SKILL.md"

MARKER="CKMS_RERUN_MARKER_$$"
printf '\n%s\n' "$MARKER" >> "$SKILLS/knowledge-management/SKILL.md"
printf '\n%s\n' "USER_CONTEXT_MARKER" >> "$SKILLS/project-context/references/CONTEXT_TEMPLATE.md"

"$@"

if [ ! -f "$DECISIONS/2026-09-26-sample.md" ]; then
  echo "error: decision record was removed" >&2
  exit 1
fi
if ! grep -q "sample row" "$DECISIONS/README.md"; then
  echo "error: index row was removed" >&2
  exit 1
fi
if [ ! -f "$SKILLS/my-project-skill/SKILL.md" ] || [ ! -f "$SKILLS/requirements-spec/SKILL.md" ]; then
  echo "error: non-CKMS skill was removed" >&2
  exit 1
fi
if grep -q "$MARKER" "$SKILLS/knowledge-management/SKILL.md"; then
  echo "error: distributed SKILL.md was not replaced" >&2
  exit 1
fi
if ! grep -q "USER_CONTEXT_MARKER" "$SKILLS/project-context/references/CONTEXT_TEMPLATE.md"; then
  echo "error: CONTEXT_TEMPLATE.md was overwritten" >&2
  exit 1
fi
if ! cmp -s "$REPO_ROOT/skills/knowledge-management/SKILL.md" "$SKILLS/knowledge-management/SKILL.md"; then
  echo "error: knowledge-management/SKILL.md does not match the distribution" >&2
  exit 1
fi

shopt -s nullglob
backups=("$TARGET/$BASE"/skills.backup-*)
shopt -u nullglob
if [ "${#backups[@]}" -ne 1 ]; then
  echo "error: expected one skills backup, found ${#backups[@]}" >&2
  exit 1
fi
if [ ! -f "${backups[0]}/knowledge-management/references/decisions/2026-09-26-sample.md" ]; then
  echo "error: backup is missing the pre-rerun decision record" >&2
  exit 1
fi
if ! grep -q "$MARKER" "${backups[0]}/knowledge-management/SKILL.md"; then
  echo "error: backup does not match the pre-rerun SKILL.md" >&2
  exit 1
fi

(cd "$TARGET" && bash "$BASE/skills/project-setup/scripts/validate.sh")
echo "ok: rerun preserved user data under $SKILLS"
