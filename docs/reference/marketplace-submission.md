# Cursor Marketplace 提出手順

Cursor Marketplace は公開前に手動セキュリティレビューが行われます。本ドキュメントは、本プラグイン（Cursor Knowledge Management System）を Marketplace に提出する際のチェックリストと手順を示します。

## 提出前チェックリスト

### 必須

- [ ] [.cursor-plugin/plugin.json](../../.cursor-plugin/plugin.json) の `version` が最新のリリースタグと一致している
- [ ] [apm.yml](../../apm.yml) の `version` も同じ値に揃っている
- [ ] `npm run docs:check` が全てパスしている（内訳は後述）
- [ ] 各 SKILL.md のフロントマターに `name` / `description` / `license` が揃っている
- [ ] アクションスキルに `disable-model-invocation: true` が設定されている
- [ ] hooks スクリプトに実行権限が付いた状態でコミットされている
- [ ] README.md にインストール方法（init.sh / Marketplace / gh skill / apm）が記載されている
- [ ] [LICENSE](../../LICENSE) ファイルがリポジトリルートに存在する
- [ ] 最新の [CHANGELOG.md](../../CHANGELOG.md) にリリースノートが反映されている

### 推奨

- [ ] GitHub リポジトリで **release immutability** を有効化している（`Settings → General → Releases → Enable release immutability`）
- [ ] **Tag protection** を設定し、勝手にタグを書き換えられないようにしている
- [ ] **Secret scanning** を有効化している
- [ ] **Code scanning** を有効化している（CodeQL など）
- [ ] パブリックな [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish) からの提出が通る状態（メタデータ・サムネイル完備）

### docs:check の内訳

`npm run docs:check` は 4 つの検証を順に実行します。v6 で構成が変わったため、v5 の `commands:check` は `components:check` に置き換わっています。

| コマンド | 検証内容 |
|---------|---------|
| `npm run skills:check` | `skills/` 配下の SKILL.md を Agent Skills 仕様に照らして検証する。frontmatter は yaml パーサで読み、仕様外の最上位キーを警告する。あわせて `templates/` に SKILL.md の複製が復活していないかを確認する |
| `npm run components:check` | `hooks/hooks.json` のイベント名・スクリプトの実在と実行権限・`stop` 系イベントの `loop_limit`、および `agents/` 配下の subagent 定義を検証する |
| `npm run plugin:check` | `.cursor-plugin/plugin.json` を [ベンダリングした公式スキーマ](../../schemas/cursor-plugin.schema.json) で ajv 検証する。`apm.yml` とのバージョン一致と、デフォルト探索でコンポーネントが実際に見つかることも確認する |
| `npm run links:check` | `docs/` に加えて `skills/` / `agents/` / `hooks/` / `templates/` の Markdown リンクを検証する |

`templates/` への複製ガードを `skills:check` に組み込んでいるのは、v5 で `templates/.agents/skills/` と `templates/.cursor/skills/` の二重管理により 7 つの SKILL.md すべてが drift した経緯があるためです。

スキル公開の検証は `npm run skill:check`（`gh skill publish --dry-run`）で別途行えます。`npm run release` からも自動的に実行されます。

## 提出手順

### 1. 最終チェック

```bash
npm run docs:check
npm run skill:check
```

セットアップ経路に変更が入っている場合は、実際に導入できることも確認します。

```bash
mkdir -p /tmp/ckms-check
bash skills/project-setup/scripts/init.sh /tmp/ckms-check --yes
(cd /tmp/ckms-check && bash .agents/skills/project-setup/scripts/validate.sh)
```

### 2. タグとリリースを作成

```bash
npm run release -- v6.0.0
```

### 3. Marketplace へ提出

[cursor.com/marketplace/publish](https://cursor.com/marketplace/publish) を開き、以下を提出します:

- GitHub リポジトリ URL（例: `https://github.com/shioki/Cursor-Knowledge-Management-System`）
- プラグインの概要説明（`.cursor-plugin/plugin.json` の description を流用）
- スクリーンショット（推奨）
- プラグインのカテゴリ（`plugin.json` の `category` は `productivity`）

### 4. セキュリティレビュー

Cursor チームが以下を手動で確認します:

- プラグインが悪意のあるコード・スクリプトを含まないこと
- MCP サーバー定義の安全性（本プラグインでは未同梱）
- 依存関係の整合性
- README / ドキュメントの正確性

v6 から hooks と subagent を同梱しているため、レビュー時にはこれらの挙動も確認対象になります。説明しやすいよう、hook スクリプトは外部依存を持たず、既定で有効なのは読み取りとログ追記のみに留めています。ネットワークアクセスや外部プロセスの起動は行いません。`stop` フックだけは会話のターンを消費しうるため、設定ファイルで明示的に有効化しない限り何もせずに終了します。詳細は [hooks/README.md](../../hooks/README.md) を参照してください。

subagent は [`agents/knowledge-curator.md`](../../agents/knowledge-curator.md) の 1 件のみで、`readonly: true` を設定しています。

レビューは通常 2 〜 7 営業日です。

### 5. 公開

承認されると Marketplace に掲載されます。以降のアップデートは Git タグをプッシュする毎にレビューを受ける形になります。

## アップデートの流れ

1. 機能追加・修正をブランチで行う
2. [CHANGELOG.md](../../CHANGELOG.md) にエントリを追加
3. `.cursor-plugin/plugin.json` と `apm.yml` の `version` をインクリメント
4. `npm run docs:check` を実行
5. `npm run release -- vX.Y.Z` でタグ付与と GitHub Release を作成
6. Marketplace 側で自動的に新しいバージョンが検出され、再レビューされる

版数を揃える対象はマニフェストだけではありません。README や `init.sh` / `init.ps1` / `validate.sh` の表示文字列も含めた一覧は [AGENTS.md](../../AGENTS.md) の「ドキュメントの版数」にあります。自動検証されるのは `plugin.json` と `apm.yml` の一致だけなので、それ以外は手で確認してください。

## 参考

- [Cursor Plugins 公式ドキュメント](https://cursor.com/ja/docs/plugins)
- [Marketplace security review](https://cursor.com/help/security-and-privacy/marketplace-security)
- [Cursor Marketplace](https://cursor.com/marketplace)
