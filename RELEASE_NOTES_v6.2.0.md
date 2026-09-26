# Release Notes — v6.2.0

**リリース日**: 2026-09-26

v6.2.0 は、導入済みプロジェクトで `init.sh` / `init.ps1` を再実行すると、判断記録やプロジェクト固有のスキルまで削除されていた問題の修正です。

## Fixed

`init.sh --yes`（対話で上書きに `y` と答えた場合も同じ）は、導入先の `skills/` を削除してから配布元で作り直していました。`init.ps1` も同じです。案内どおりに更新した利用者が、判断記録・パターン・改善記録、プロジェクト固有のスキル、ほかの配布元のスキルを失っていました。

v6.2.0 では、配布元にあるスキルだけを置き換えます。`decisions/`、`patterns/`、`improvements/`、`*_TEMPLATE.md`、配布元に無いスキルは残します。置き換えの前に `skills.backup-YYYYmmdd-HHMMSS/` を作ります（`--no-backup` で省略）。導入先に入っている `init.sh` / `init.ps1` を、その導入先自身へ向けて実行した場合は、配布元と導入先が同じなのでエラーで止まります。

この版には、v6.1.1 以降に `main` へ入っていた修正も含みます。`--legacy-claude` と `--cursor-only` の同時指定を `init.sh` でも拒否すること、壊れた `.claude/skills` シンボリックリンクの判定、APM / `gh skill` では Claude Code 橋渡しを自動化しない旨の明記、などです。一覧は [CHANGELOG.md](CHANGELOG.md) を参照してください。

## すでに記録が消えている場合

v6.0.0〜v6.1.1 で再実行したことがあるプロジェクトは、導入先の Git 履歴か、手元に残したコピーから戻してください。手順は [導入済みプロジェクトの更新](docs/getting-started/updating.md) にあります。

## 関連

- [CHANGELOG.md](CHANGELOG.md)
- 前リリース: [v6.1.1](RELEASE_NOTES_v6.1.1.md)
