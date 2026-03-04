#!/usr/bin/env bash
# v4.0.0: 新テンプレート（.claude/skills）の init に転送
# Usage: bash init.sh /path/to/target-project [--cursor-only]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NEW_INIT="$(cd "$SCRIPT_DIR/../../../.claude/skills/project-setup/scripts" && pwd)/init.sh"
exec "$NEW_INIT" "$@"
