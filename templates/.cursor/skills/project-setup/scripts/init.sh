#!/usr/bin/env bash
# v5.0.0: 新テンプレート（.agents/skills）の init に転送
# Usage: bash init.sh /path/to/target-project [--cursor-only|--legacy-claude]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NEW_INIT="$(cd "$SCRIPT_DIR/../../../.agents/skills/project-setup/scripts" && pwd)/init.sh"
exec "$NEW_INIT" "$@"
