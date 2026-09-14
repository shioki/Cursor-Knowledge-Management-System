# Contributing

Thank you for improving Cursor Knowledge Management System. This document describes how to propose changes and keep release metadata consistent.

## Before you open a PR

1. **Run the full doc check locally** (requires Node.js):

   ```bash
   npm ci
   npm run docs:check
   ```

   This runs:

   - `npm run skills:check` — `skills/**/SKILL.md` against the Agent Skills spec, plus the guard against duplicating skills into `templates/`
   - `npm run components:check` — `hooks/hooks.json` event names, hook script existence and executable bit, subagent front matter in `agents/`
   - `npm run plugin:check` — `.cursor-plugin/plugin.json` against the official schema (ajv) and **version match** with `apm.yml`
   - `npm run links:check` — internal and external links in `README*.md`, `CHANGELOG.md`, `docs/`, `skills/`, `agents/`, `hooks/`, and `templates/`

2. **Keep edits focused** on the issue or feature. Avoid unrelated refactors and unsolicited large doc rewrites.

3. **Match existing style** in skills, hooks, and scripts (naming, front matter, language).

4. **Never duplicate `skills/` elsewhere.** It is the single source of truth. v5 maintained parallel copies under `templates/`, and all seven `SKILL.md` files drifted apart. See [AGENTS.md](AGENTS.md) for the repository's own development guidelines.

5. **When embedding user strings into YAML or Markdown tables in shell scripts**, use `ckms_yaml_escape` / `ckms_table_escape` from `_skill-base.sh`. Do not pass rows containing `\|` through `awk -v` (use `ENVIRON` instead). See [AGENTS.md](AGENTS.md)「スクリプトの制約」。

## Version alignment (releases)

When you prepare a **versioned release** (not every PR), these must stay in sync:

| File | Field |
|------|--------|
| [`.cursor-plugin/plugin.json`](.cursor-plugin/plugin.json) | `version` |
| [`apm.yml`](apm.yml) | `version` |
| [`README.md`](README.md) | Footer "バージョン" and 配布例のタグ（`gh --pin` / `apm` の例） |
| [`README.en.md`](README.en.md) | Footer version and examples, if you bump the tag |
| [`CHANGELOG.md`](CHANGELOG.md) | New section for the version |

Semantic versioning:

- **Patch** (6.0.x): documentation, metadata, non-breaking fixes, CI.
- **Minor** (6.x.0): new optional skills, hooks, or subagents, or backward-compatible behavior.
- **Major**: breaking path or format changes; document migration in `CHANGELOG.md` and, when appropriate, `RELEASE_NOTES_*.md`.

For tagging and GitHub Releases, use [`docs/reference/github-release.md`](docs/reference/github-release.md) and `npm run release -- vX.Y.Z` (Bash: Git Bash or WSL on Windows).

## Internationalization

- The canonical full README is [README.md](README.md) (Japanese for end users in this repo).
- [README.en.md](README.en.md) is a **short** English quick start; keep it in sync for install paths, version footers, and key commands when you change them in `README.md`.

## Questions

Historical design notes and older phases are in [docs/reference/development-log.md](docs/reference/development-log.md). For current behavior and breaking changes, prefer [CHANGELOG.md](CHANGELOG.md) and the main [README.md](README.md).
