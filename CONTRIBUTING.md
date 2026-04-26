# Contributing

Thank you for improving Cursor Knowledge Management System. This document describes how to propose changes and keep release metadata consistent.

## Before you open a PR

1. **Run the full doc check locally** (requires Node.js):

   ```bash
   npm ci
   npm run docs:check
   ```

   This runs:

   - `npm run skills:check` — skill layout, `SKILL.md` front matter, optional `license` / `metadata`
   - `npm run commands:check` — custom command files under `templates/.cursor/commands/`
   - `npm run plugin:check` — `.cursor-plugin/plugin.json` and `apm.yml` shape and **version match**
   - `npm run links:check` — internal and external links in `README.md`, `CHANGELOG.md`, and `docs/**/*.md`

2. **Keep edits focused** on the issue or feature. Avoid unrelated refactors and unsolicited large doc rewrites.

3. **Match existing style** in skills, commands, and scripts (naming, front matter, language).

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

- **Patch** (5.0.x): documentation, metadata, non-breaking fixes, CI.
- **Minor** (5.x.0): new optional skills/commands or backward-compatible behavior.
- **Major**: breaking path or format changes; document migration in `CHANGELOG.md` and, when appropriate, `RELEASE_NOTES_*.md`.

For tagging and GitHub Releases, use [`docs/reference/github-release.md`](docs/reference/github-release.md) and `npm run release -- vX.Y.Z` (Bash: Git Bash or WSL on Windows).

## Internationalization

- The canonical full README is [README.md](README.md) (Japanese for end users in this repo).
- [README.en.md](README.en.md) is a **short** English quick start; keep it in sync for install paths, version footers, and key commands when you change them in `README.md`.

## Questions

Historical design notes and older phases are in [docs/reference/development-log.md](docs/reference/development-log.md). For current behavior and breaking changes, prefer [CHANGELOG.md](CHANGELOG.md) and the main [README.md](README.md).
