# Cursor Knowledge Management System

A knowledge-management template for AI-assisted development using **Agent Skills** (`.agents/skills/`) and **Custom Commands** (`.cursor/commands/`). The same skill set can be shared across **Cursor 3.x**, **Claude Code**, and **Codex**.

> **v5.x** ships as an installable **Cursor Plugin**, uses the standard **`.agents/skills/`** layout, and supports **four distribution paths**: manual **init**, **Cursor Marketplace**, **`gh skill`**, and **Microsoft APM**. `AGENTS.md` templates are included.
>
> For the full narrative, infographics, and complete doc index, see the Japanese **[README.md](README.md)**.

## Why skills + commands

Compared to heavy `alwaysApply` rules, Agent Skills load **only what the model needs**, with details in `references/`. Custom commands start structured workflows with `/command-name`.

## Quick start (four distribution options)

### 1. `init.sh` (recommended)

```bash
git clone https://github.com/shioki/Cursor-Knowledge-Management-System.git
cd Cursor-Knowledge-Management-System

# Default (v5): install under .agents/skills (shared with Cursor / Claude Code / Codex)
bash templates/.agents/skills/project-setup/scripts/init.sh /path/to/your-project

# Also drop AGENTS.md templates
bash templates/.agents/skills/project-setup/scripts/init.sh /path/to/your-project --with-agents-md

# v4-compatible path (.claude/skills)
bash templates/.agents/skills/project-setup/scripts/init.sh /path/to/your-project --legacy-claude

# Cursor-only (.cursor/skills)
bash templates/.agents/skills/project-setup/scripts/init.sh /path/to/your-project --cursor-only
```

Windows: use `templates/.agents/skills/project-setup/scripts/init.ps1` with the same intent.

### 2. Cursor Marketplace (plugin)

Install from the Cursor Marketplace as a plugin. See [Plugin development](docs/advanced/plugin-development.md) and [Marketplace submission](docs/reference/marketplace-submission.md).

### 3. `gh skill` (single skill)

```bash
gh skill install shioki/Cursor-Knowledge-Management-System knowledge-management --agent cursor

# Pin a tag for supply-chain stability
gh skill install shioki/Cursor-Knowledge-Management-System knowledge-management --agent cursor --pin v5.0.1
```

Details: [gh skill integration](docs/reference/gh-skill-integration.md).

### 4. Microsoft APM (bundle)

```yaml
dependencies:
  apm:
    - shioki/Cursor-Knowledge-Management-System#v5.0.1
```

Then `apm install`. Details: [APM integration](docs/reference/apm-integration.md).

## What you get

| Area | Notes |
|------|--------|
| **7 skills** | project-context, team-standards, knowledge-management, pattern-library, debug-workflow, improvement-tracking, project-setup |
| **7 commands** | e.g. `/record-decision`, `/add-pattern`, `/update-context`, `/migrate-from-rules` |
| **Plugin manifest** | [.cursor-plugin/plugin.json](.cursor-plugin/plugin.json) |
| **APM manifest** | [apm.yml](apm.yml) |

## After install

1. Run `/update-context` in Cursor to fill project basics.
2. Run `/record-decision` to log your first decision.
3. Edit `team-standards` `SKILL.md` to match your conventions.

## Requirements

- **Cursor** 3.0+ recommended for `.agents/skills/`. Older versions may use `.cursor/skills/` or `.claude/skills/`.
- **Git** 2.0+
- **Shell scripts**: Bash on Mac/Linux; on Windows prefer **Git Bash** or **WSL** for `init.sh` / `release.sh`.
- **Optional**: GitHub CLI (`gh`) for `gh skill`; [Microsoft APM](https://github.com/microsoft/apm) for `apm install`.

## Quality checks (this repository)

```bash
npm ci
npm run docs:check
```

Runs skill structure, command structure, plugin/apm manifest checks, and Markdown link checks.

## Docs (mixed JA / EN)

- [CHANGELOG.md](CHANGELOG.md) — release history
- [Quick start (JA)](docs/getting-started/quick-start.md)
- [Skills guide (JA)](docs/templates/skills-guide.md) · [Commands guide (JA)](docs/templates/commands-guide.md)
- [CONTRIBUTING.md](CONTRIBUTING.md) — PRs and version alignment

## License

[MIT](LICENSE)

---

**Last updated**: 2026-04-26  
**Version**: 5.0.1 ([CHANGELOG](CHANGELOG.md) · [release notes v5.0.0](RELEASE_NOTES_v5.0.0.md))
