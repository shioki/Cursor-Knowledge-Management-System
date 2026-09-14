# Release Notes — v6.1.1

**Release Date**: 2026-09-14
**Codename**: Bridge

## 概要

v6.1.1 は、CKMS の中核主張だった「`.agents/skills/` に置けば Cursor・Claude Code・Codex すべてが同じスキルを読む」が **Claude Code には成立していなかった**問題を修正するマイナーリリースです。Claude Code は `.claude/skills/` しか標準では探索しないため、`init.sh` / `init.ps1` が `.claude/skills` へのシンボリックリンクで橋渡しし、`CLAUDE.md`（`@AGENTS.md` の import）と Claude Code ネイティブの hooks を新たに提供します。

あわせて、この修正作業そのものを検証する過程で見つかった Windows 互換性の問題（symlink checkout 破損、並行実行時のレースコンディション、Windows 実行系が CI で一度も検証されていなかった構造的な盲点）も解消しました。破壊的変更はありません。

## ハイライト

### 1. Claude Code 対応の実質化

- `init.sh` / `init.ps1` が既定（`.agents` モード）で `.claude/skills` を `.agents/skills` へのシンボリックリンクとして自動作成します（`--no-claude-bridge` / `-NoClaudeBridge` で無効化可）。シンボリックリンクを作成できない環境（主に Windows で権限が無い場合）はコピーにフォールバックします
- `--with-agents-md` 指定時、`AGENTS.md` に加えて `@AGENTS.md` を import するだけの `CLAUDE.md` も作成します。Claude Code は AGENTS.md を自動では読まないためです
- リポジトリ自身にも `CLAUDE.md` と `.claude/skills` を追加し、CKMS 開発時に Claude Code からもスキルと AGENTS.md が読み込まれるようにしました（dogfooding）

### 2. Claude Code ネイティブ hooks

Cursor 版（`hooks/*.sh` + `hooks.json`）とはスキーマが異なるため、`hooks/claude-code/` に専用のスクリプトを追加しました。

| Cursor | Claude Code | 役割 |
|--------|-------------|------|
| `sessionStart` | `SessionStart` | 蓄積済み知識の索引を初期コンテキストへ注入 |
| `afterFileEdit` | `PostToolUse`（matcher `Edit\|Write`） | 編集したファイルをログに追記 |
| `stop`（`followup_message`） | `Stop`（`decision: "block"` + `reason`） | 記録漏れを促す（既定で無効） |

索引の組み立ては `hooks/_hook-lib.sh` の `ckms_build_knowledge_index` に共通化し、両エージェント向けスクリプトから呼び出します。設定は `templates/.claude/settings.json.template`（permissions を含む）から生成されます。

### 3. Windows 互換性の横断的な見直し

Claude Code 対応を作り込む過程で、CI（Linux/macOS 中心）では検知できない Windows 固有の不具合が複数見つかりました。

- **symlink checkout 破損**: `hooks/claude-code/_hook-lib.sh` を symlink で実装していたため、git の symlink サポートが無効な Windows checkout だと壊れたプレースホルダーファイルになっていました。symlink をやめ、ソースと同じディレクトリ構造（`_hook-lib.sh` の実体 + `claude-code/` サブディレクトリ）をそのまま配置する方式に変更しました
- **並行実行のレースコンディション**: 索引 `README.md` の更新（`ckms_index_upsert`）と活動ログのトリム処理に排他制御が無く、Cursor と Claude Code を同一プロジェクトで併用すると記録が失われることがありました（実測で 40 件中 2 件の欠損）。mkdir ベースの軽量ロック（`ckms_with_lock`）を追加しています
- **`init.ps1` の機能不足**: v4.x → v6 の移行検出、および `Copy-Item` が引き継がない実行権限の付与（Git Bash 経由の `chmod`）が `init.sh` にはあるのに `init.ps1` には無く、bash 版と挙動が揃っていませんでした
- **CI の盲点**: `init.ps1` は一度も CI で実行されておらず、上記のような不具合が検知できない構造でした。`windows-latest` 上で `init.ps1` を実際に実行し、hooks を直接起動して検証する `windows-setup-smoke-test` ジョブを追加しています

### 4. その他の修正

- `skills/debug-workflow/scripts/search-sessions.sh`: `-v` のように `-` で始まるキーワードが `grep` のオプションとして誤解釈され、無言で検索が失敗する問題を修正（`grep --`）
- `scripts/release.sh`: `gh release create` に `--target` を渡していなかったため、タグ未作成時は GitHub 上のデフォルトブランチの最新状態からタグが作られ、ローカルで検証した内容と一致しない恐れがありました。作業ツリーのクリーンさと upstream との一致を確認し、検証済みコミットを `--target` に明示。実行前の確認プロンプトも追加しています

## 互換性

- 破壊的変更はありません。既存の v6.0.0 利用フロー（init / Marketplace / gh skill / APM）はそのまま利用できます
- `apm install` / `gh skill install` 経由のインストールでは、Claude Code 橋渡し（`.claude/skills` symlink、`CLAUDE.md`、Claude Code hooks）は自動化されません。これらの経路はファイルを配置するだけで、`init.sh` のような後処理スクリプトを実行しないためです。Claude Code でも使いたい場合は [README.md の「手動コピー」](README.md#手動コピー) を参照してください

## 検証

```bash
npm run docs:check
```

`skills:check` / `components:check`（Cursor 版 3 hooks・Claude Code 版 3 hooks・subagent 1 件）/ `plugin:check` / `links:check` がすべて通過することを確認しています。CI では `setup-smoke-test`（Linux）と `windows-setup-smoke-test`（Windows）の両方が、`init` の実行から hooks の起動までを通しで検証します。

## 関連ドキュメント

- [hooks ガイド](docs/advanced/hooks-guide.md) — Claude Code 版 hooks の節
- [Cursor + Claude Code 並行利用ガイド](docs/getting-started/parallel-use-cursor-claude.md)
- [CHANGELOG.md](CHANGELOG.md)
