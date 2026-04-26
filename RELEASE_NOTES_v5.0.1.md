# Release Notes — v5.0.1

**Release Date**: 2026-04-26  
**Type**: Patch Release (docs / metadata / CI hardening)

## 概要

v5.0.1 は、v5.0.0 の配布機能を維持したまま、メタデータ整合性、ドキュメント鮮度、CI の継続検証、英語導線を強化するメンテナンスリリースです。

## ハイライト

### 1) メタデータの一貫性を改善

- [`.cursor-plugin/plugin.json`](.cursor-plugin/plugin.json) の `description` / `keywords` を更新
- [`apm.yml`](apm.yml) の `description` を README の表現と整合
- Cursor 3.x / Claude Code / Codex、`.agents/skills`、4 配布経路の表記を統一

### 2) ドキュメント運用を明確化

- [`docs/reference/development-log.md`](docs/reference/development-log.md) に v4/v5 要約を追記
- 同ドキュメント冒頭で、正典を [CHANGELOG.md](CHANGELOG.md) / [README.md](README.md) と明記
- `CONTRIBUTING.md` を新規追加し、PR 前チェックと版数同期手順を定義

### 3) 英語導線を追加

- [README.en.md](README.en.md) を新規追加（英語 Quick Start）
- 主要導入経路（init / Marketplace / gh skill / APM）を英語で簡潔に案内

### 4) CI と定期監視を強化

- [`.github/dependabot.yml`](.github/dependabot.yml) を追加（npm 週次更新）
- [`.github/workflows/docs-check.yml`](.github/workflows/docs-check.yml) に
  - 週次 `schedule`
  - `windows-latest` を含む OS マトリクス
  を追加し、リンク劣化やプラットフォーム差分の早期検知を強化

### 5) リンク検証対象を拡大

- [`scripts/check-links.mjs`](scripts/check-links.mjs) に `README.en.md` / `CONTRIBUTING.md` を追加
- 一部参照先 URL を現行ドキュメント構成に合わせて更新

## 互換性

- 破壊的変更はありません
- 既存の v5.0.0 利用フロー（init / Marketplace / gh skill / APM）はそのまま利用できます

## 検証

```bash
npm run docs:check
```

上記で `skills:check` / `commands:check` / `plugin:check` / `links:check` がすべて通過することを確認しています。
