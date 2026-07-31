# Release Notes — v6.0.0

**Release Date**: 2026-08-01
**Codename**: Habit

## 概要

v6.0.0 は、CKMS の全機能を **Agent Skills に統一**し、記録を習慣化するための **hooks** と **subagent** を追加したメジャーリリースです。あわせて、v5 で機能していなかったプラグインマニフェストを公式スキーマ準拠に修正し、知識の保存形式を **1 概念 1 ファイル**に変更しました。

このリリースが解こうとしている問題は「仕組みはあるのに記録が続かない」という点です。スキルは知識の読み書きを担いますが、ユーザーが記録しようと思った瞬間にしか動きません。hooks はその瞬間を作る役割を持ちます。

## ハイライト

### 1. すべてが Agent Skills になった

`.cursor/commands/` にあった 7 つのコマンドのうち 6 つを、`disable-model-invocation: true` を持つスキルに変換しました。`/record-decision` などの呼び出し方は変わりませんが、Cursor 固有の仕組みに依存しなくなったため、Claude Code や Codex からも同じワークフローを使えます。

`/migrate-from-rules` は廃止しました。Cursor 組み込みの `/migrate-to-skills` と役割が重複し、対象である v2.x の rules 形式は 4 メジャーバージョン前のものだからです。

### 2. hooks による記録の習慣化

| イベント | 役割 | 既定 |
|---------|------|------|
| `sessionStart` | 蓄積済み知識の索引を初期コンテキストへ注入 | 有効 |
| `afterFileEdit` | 編集したファイルを `knowledge-activity.log` に追記 | 有効 |
| `stop` | 記録漏れがありそうなときに記録を促す | 無効 |

`stop` フックは 1 ターンを消費するため既定で無効にしています。まず 2 つで運用し、それでも記録が続かない場合に有効化してください。

hook スクリプトは POSIX シェルと `sed` / `awk` / `find` だけで書かれており、`jq` / `python` / `node` に依存しません。導入先の環境を選ばないようにするためです。

### 3. knowledge-curator subagent

`/review-knowledge` が [`agents/knowledge-curator.md`](agents/knowledge-curator.md)（`readonly: true`）に走査を委譲します。判断が 50 件あれば読み込みは数万トークンになりますが、必要な結論は「どれを直すべきか」という数十行だけです。この非対称性が大きい作業に限って subagent を使っています。

subagent を 1 つしか提供していないのは意図的です。委譲のたびにコンテキストの受け渡しコストがかかるため、Cursor の公式ドキュメントも多用をアンチパターンとしています。

### 4. 1 概念 1 ファイルへの分割

v5 までは `add-entry.sh` などが単一の `KNOWLEDGE_TEMPLATE.md` に追記し続ける設計でした。記録が増えるほど 1 ファイルが肥大化し、参照のたびに全体を読むことになるため、CKMS が掲げてきた「オンデマンドの段階的読み込み」が実際には成立していませんでした。

v6 では判断・パターン・改善のそれぞれを個別ファイルにし、ディレクトリごとの `README.md` を索引にします。記録スクリプトが索引行の追加まで行います。

| 種類 | 保存先 |
|------|--------|
| 技術判断 | `<base>/skills/knowledge-management/references/decisions/YYYY-MM-DD-スラッグ.md` |
| 実装パターン | `<base>/skills/pattern-library/references/patterns/スラッグ.md` |
| 改善記録 | `<base>/skills/improvement-tracking/references/improvements/YYYY-MM-DD-スラッグ.md` |
| デバッグセッション | `<base>/debug-sessions/`（変更なし） |

既存の `*_TEMPLATE.md` はレガシーファイルとして読める状態のまま残ります。一括変換ツールは提供しません。「まだ有効か」「切り出す価値があるか」は人が判断すべきものだからです。

### 5. plugin.json がようやく機能する

v5 のマニフェストは公式スキーマに存在しない `paths` / `compatibility` を使い、`repository` の型も誤っていました。スキーマは `additionalProperties: false` なので、**このマニフェストではコンポーネントが 1 つも読み込まれません**。Marketplace またはローカルプラグインとして v5 を導入していた場合、スキルが認識されていなかった可能性があります。

v6 では公式スキーマを [`schemas/`](schemas/) にベンダリングし、ajv による検証を CI に組み込みました。同種の乖離が再発しないようにするためです。

### 6. 配布物をリポジトリ直下へ集約

スキルの実体を `templates/.agents/skills/` からルート直下の [`skills/`](skills/) に移しました。Cursor Plugin のデフォルト探索・`gh skill install`・`apm install` の 3 経路すべてが、この配置をそのまま読めます。とくに `gh skill` は `--allow-hidden-dirs` なしでは隠しディレクトリ配下を検出しないため、v5 の利用者は毎回このフラグを付ける必要がありました。

あわせて、drift していた複製 `templates/.cursor/skills/` を削除しました。7 つの `SKILL.md` すべてに差分があり、`init.ps1` は v3 の実装のまま取り残されていました。`npm run skills:check` が複製の再発を検出します。

### 7. CI の実効性向上

- **仕様準拠の検証**: `check-skill-structure.mjs` を YAML パーサベースに書き換え、`name` の長さと kebab-case、`description` の長さ、未知キー、`paths` / `disable-model-invocation` の型を Agent Skills 仕様に沿って検証します
- **スモークテスト**: `init.sh` → `validate.sh` → 記録スクリプト → hooks を通しで実行し、生成物を検査します。日本語タイトルでファイル名が壊れる不具合はこの経路で検出できます
- **`gh skill publish --dry-run`**: 配布可能性を毎回確認します
- **リンク検証の拡張**: 対象に `skills/` / `agents/` / `hooks/` / `templates/` を追加しました

### 8. dogfooding

このリポジトリ自身が CKMS を使うようになりました。ルートに [`AGENTS.md`](AGENTS.md) と `.cursor/hooks.json` を置いています。手元で違和感のあるものは、利用者にとっても違和感があります。

## 破壊的変更

| 項目 | v5.x | v6.0.0 |
|-----|------|--------|
| スキルの実体 | `templates/.agents/skills/` | `skills/` |
| `init.sh` のパス | `templates/.agents/skills/project-setup/scripts/init.sh` | `skills/project-setup/scripts/init.sh` |
| カスタムコマンド | `.cursor/commands/*.md` 7 種 | 廃止（アクションスキル 6 種に統合） |
| `/migrate-from-rules` | 提供 | 廃止 |
| `templates/.cursor/skills/` | 非推奨で残置 | 削除 |
| 知識の保存形式 | `*_TEMPLATE.md` への追記 | 1 概念 1 ファイル + `README.md` 索引 |
| `plugin.json` | 独自フィールド（スキーマ違反） | 公式スキーマ準拠 |
| npm script | `commands:check` | `components:check` |

## 修正

- **日本語タイトルでファイル名が壊れる問題**: スラッグが空になり `2026-07-28-.md` のようなファイルが生成されていました。スラッグ化を共通関数に集約し、変換結果が空の場合はタイムスタンプにフォールバックします
- **frontmatter の `description`**: HTML コメントを値にしていた箇所を、空文字列 + 行コメントに修正しました

## 移行

`init.sh` を再実行すると、スキルの更新と hooks / subagent の配置が行われます。`.cursor/commands/` は手動で削除してください。

```bash
cd /path/to/your-project
cp -r .agents .agents.v5-backup

bash /path/to/Cursor-Knowledge-Management-System/skills/project-setup/scripts/init.sh /path/to/your-project
rm -rf .cursor/commands
bash .agents/skills/project-setup/scripts/validate.sh
```

`*_TEMPLATE.md` と `team-standards/SKILL.md` は上書きされます。カスタマイズしていた場合はバックアップから書き戻してください。手順の詳細と元に戻す方法は [v5 からの移行ガイド](docs/getting-started/migration-from-v5.md) にあります。

## 関連ドキュメント

- [hooks ガイド](docs/advanced/hooks-guide.md)
- [subagents ガイド](docs/advanced/subagents-guide.md)
- [アクションスキルガイド](docs/templates/action-skills-guide.md)
- [v5 からの移行ガイド](docs/getting-started/migration-from-v5.md)
- [CHANGELOG.md](CHANGELOG.md)
