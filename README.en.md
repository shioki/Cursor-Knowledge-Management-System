# Cursor Knowledge Management System

A knowledge-management template for AI-assisted development. It accumulates technical decisions, implementation patterns, debug sessions, and improvements inside your project so the agent can reuse them later. The skill set lives in `.agents/skills/`, which **Cursor** and **Codex** read directly; **Claude Code** only looks under `.claude/skills/`, so `init.sh` bridges it there with a symlink (no duplication).

> **v6.1.0** makes Claude Code support actually work: since Claude Code doesn't discover `.agents/skills/` on its own, `init.sh`/`init.ps1` now create a `.claude/skills` symlink bridge and a `CLAUDE.md` that imports `AGENTS.md`, plus native Claude Code hooks alongside the Cursor ones. This release also hardens Windows compatibility (a symlink that broke on checkouts without symlink support, race conditions under concurrent Cursor/Claude Code use, and a CI blind spot where `init.ps1` was never actually executed).
>
> For the full narrative and the complete doc index, see the Japanese **[README.md](README.md)**.

## Why Agent Skills

With `.cursor/rules`, every `alwaysApply` rule was sent on every request and glob-matched rules were loaded regardless of relevance. Agent Skills instead let the model read only each skill's `description`, pick the ones that fit the conversation, and open `references/` only when needed.

v6 makes that progressive loading actually hold: each decision, pattern, and improvement is its own file, indexed by a per-directory `README.md`. Before v6, scripts appended to a single template file, so the whole history had to be read every time.

## Quick start (four distribution options)

### 1. `init.sh` (recommended)

```bash
git clone https://github.com/shioki/Cursor-Knowledge-Management-System.git
cd Cursor-Knowledge-Management-System

# Default: install under .agents/skills. Cursor/Codex read it directly;
# init.sh also symlinks .claude/skills there for Claude Code
bash skills/project-setup/scripts/init.sh /path/to/your-project

# Non-interactive (CI / automation)
bash skills/project-setup/scripts/init.sh /path/to/your-project --yes

# Also drop AGENTS.md (and a CLAUDE.md that imports it)
bash skills/project-setup/scripts/init.sh /path/to/your-project --with-agents-md

# Skip hooks / subagent / the Claude Code bridge
bash skills/project-setup/scripts/init.sh /path/to/your-project --no-hooks --no-agents --no-claude-bridge

# v4-compatible path (.claude/skills)
bash skills/project-setup/scripts/init.sh /path/to/your-project --legacy-claude

# Cursor-only (.cursor/skills)
bash skills/project-setup/scripts/init.sh /path/to/your-project --cursor-only
```

Windows: use `skills/project-setup/scripts/init.ps1` with the same options.

### 2. Cursor Marketplace (plugin)

Install from the Cursor Marketplace. See [plugin development](docs/advanced/plugin-development.md) and [Marketplace submission](docs/reference/marketplace-submission.md).

### 3. `gh skill` (single skill)

```bash
gh skill install shioki/Cursor-Knowledge-Management-System knowledge-management --agent cursor

# Pin a tag for supply-chain stability
gh skill install shioki/Cursor-Knowledge-Management-System knowledge-management --agent cursor --pin v6.1.0
```

Skills now live in the non-hidden `skills/` directory, so `--allow-hidden-dirs` is no longer needed. Details: [gh skill integration](docs/reference/gh-skill-integration.md).

### 4. Microsoft APM (bundle)

```yaml
dependencies:
  apm:
    - shioki/Cursor-Knowledge-Management-System#v6.1.0
```

Then `apm install`. Details: [APM integration](docs/reference/apm-integration.md).

## What you get

| Area | Notes |
|------|--------|
| **7 domain skills** | project-context, team-standards, knowledge-management, pattern-library, debug-workflow, improvement-tracking, project-setup |
| **6 action skills** | `/record-decision`, `/add-pattern`, `/start-debug`, `/log-improvement`, `/review-knowledge`, `/update-context` |
| **3 hooks (Cursor)** | `sessionStart` injects the knowledge index, `afterFileEdit` logs activity, `stop` nudges you to record (off by default) |
| **3 hooks (Claude Code)** | Same behavior, native schema: `SessionStart`, `PostToolUse` (matcher `Edit\|Write`), `Stop` (block+reason instead of `followup_message`) |
| **1 subagent** | `knowledge-curator` audits the knowledge base in an isolated, read-only context (Cursor only) |
| **Plugin manifest** | [.cursor-plugin/plugin.json](.cursor-plugin/plugin.json) |
| **APM manifest** | [apm.yml](apm.yml) |

Subagents are Cursor-specific; hooks now ship for both Cursor and Claude Code (different schemas, see [hooks guide](docs/advanced/hooks-guide.md)). Skills work everywhere and the system is fully functional without hooks or the subagent.

## After install

1. Run `/update-context` to fill in project basics.
2. Run `/record-decision` to log your first decision.
3. Edit the `team-standards` `SKILL.md` to match your conventions.

Skipping these leaves the skills pointing at empty templates.

## Requirements

- **Cursor** 3.0+ recommended for `.agents/skills/`, hooks, and subagents. Older versions can use `.cursor/skills/` for skills only.
- **Claude Code**: any version that reads `.claude/skills/`. The `.claude/settings.json` hooks schema (e.g. `hookSpecificOutput`) can vary by version — verify with the smoke commands in the [hooks guide](docs/advanced/hooks-guide.md) after installing.
- **Git** 2.0+ (creating the `.claude/skills` symlink may require `core.symlinks` enabled; on Windows, admin rights or Developer Mode)
- **Shell scripts**: Bash on Mac/Linux; on Windows prefer **Git Bash** or **WSL** for `init.sh` / `release.sh`.
- **Optional**: GitHub CLI (`gh`) 2.90.0+ for `gh skill`; [Microsoft APM](https://github.com/microsoft/apm) for `apm install`.

Hook scripts depend only on POSIX shell utilities — no `jq`, `python`, or `node` required.

## Quality checks (this repository)

```bash
npm ci
npm run docs:check
```

Runs skill structure validation against the Agent Skills spec, hooks/subagent component checks, plugin and APM manifest schema validation, and Markdown link checks.

## Docs (mixed JA / EN)

- [CHANGELOG.md](CHANGELOG.md) — release history
- [Quick start (JA)](docs/getting-started/quick-start.md)
- [Skills guide (JA)](docs/templates/skills-guide.md) · [Action skills guide (JA)](docs/templates/action-skills-guide.md)
- [Migration from v5 (JA)](docs/getting-started/migration-from-v5.md)
- [CONTRIBUTING.md](CONTRIBUTING.md) — PRs and version alignment

## License

[MIT](LICENSE)

---

**Last updated**: 2026-09-14  
**Version**: 6.1.0 ([CHANGELOG](CHANGELOG.md) · [release notes v6.1.0](RELEASE_NOTES_v6.1.0.md))
