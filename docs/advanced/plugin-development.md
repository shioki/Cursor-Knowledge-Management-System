# Cursor Plugin 開発ガイド

本リポジトリは **Cursor Plugin** として配布可能な構造になっています。このドキュメントでは、ローカルテストから Marketplace 提出までの手順を解説します。

## プラグイン構成

マニフェストは [.cursor-plugin/plugin.json](../../.cursor-plugin/plugin.json) です。

```json
{
  "$schema": "https://cursor.com/schemas/cursor-plugin/plugin.json",
  "name": "cursor-knowledge-management-system",
  "version": "6.1.1",
  "author": { "name": "shioki" },
  "license": "MIT",
  "repository": "https://github.com/shioki/Cursor-Knowledge-Management-System"
}
```

コンポーネントの場所は**明示していません**。Cursor はプラグインルート直下の既定のディレクトリを探索するため、そこに置いておけば設定は不要です。

| コンポーネント | 探索先 |
|---------------|--------|
| Skills | `skills/` |
| Subagents | `agents/` |
| Hooks | `hooks/hooks.json` |
| Commands | `commands/`（v6 では未使用） |
| Rules | `rules/`（未使用） |

### v5 での失敗と、v6 で明示をやめた理由

v5 のマニフェストは `paths.skills` / `paths.commands` でコンポーネントの場所を指定していましたが、**公式スキーマに `paths` というフィールドは存在しません**。スキーマは `additionalProperties: false` なので、このマニフェストは検証を通らず、コンポーネントは 1 つも読み込まれませんでした。

コンポーネント指定は最上位の `skills` / `commands` / `agents` / `hooks` で行います。ただし既定の探索先に置いてあれば指定自体が不要なため、v6 では配布物をルート直下に移して明示をやめました。設定が減り、ずれる余地もなくなります。

隠しディレクトリを避けたのも意図的です。`gh skill install` は `--allow-hidden-dirs` なしでは隠しディレクトリ配下のスキルを検出しません。`skills/` をルートに置くことで、Plugin・`gh skill`・`apm` の 3 経路が同じ配置で動きます。

## ローカルテスト

本リポジトリを Cursor にローカルインストールして動作確認する手順です。

### 1. シンボリックリンクで読み込む

```bash
# Mac/Linux
mkdir -p ~/.cursor/plugins/local
ln -s "$(pwd)" ~/.cursor/plugins/local/cursor-knowledge-management-system
```

```powershell
# Windows (PowerShell 管理者)
New-Item -ItemType Directory -Path "$HOME\.cursor\plugins\local" -Force
New-Item -ItemType SymbolicLink `
  -Path "$HOME\.cursor\plugins\local\cursor-knowledge-management-system" `
  -Target (Get-Location).Path
```

### 2. Cursor を再起動

`Cmd/Ctrl+Shift+P` → **Developer: Reload Window** を実行するか、Cursor 自体を再起動してください。

### 3. 読み込み確認

- **Cursor Settings → Skills** にドメインスキル 7 種が表示されること
- チャットで `/` を入力し、アクションスキル 6 種（`/record-decision` など）が候補に出ること
- サブエージェント一覧に `knowledge-curator` が出ること
- 新しい会話の冒頭で hooks が知識の索引を読み込むこと

### 4. 外す

```bash
rm ~/.cursor/plugins/local/cursor-knowledge-management-system
```

## dogfooding — このリポジトリで CKMS 自身を使う

CKMS の開発中に CKMS を使うと、スキルの説明文が実際に発火するか、hooks が邪魔にならないかを、利用者と同じ条件で確認できます。

### hooks と AGENTS.md

リポジトリルートに [AGENTS.md](../../AGENTS.md) と [.cursor/hooks.json](../../.cursor/hooks.json) を置いてあります。`.cursor/hooks.json` は `hooks/` 配下のスクリプトを直接参照しているため、ローカルプラグインとして読み込まなくても hooks は動きます。

`stop` フックはこのリポジトリでは有効にしていません。開発中は編集回数が多く、記録提案が頻繁に出ると邪魔になるためです。

### 知識ベース

CKMS 自身の知識ベースは、リポジトリに含めず `.agents/` にローカル生成します（`.gitignore` 済み）。`skills/` 配下の `references/` は配布テンプレートなので、ここに CKMS 自身の記録を入れると利用者のプロジェクトにも混入します。

```bash
bash skills/project-setup/scripts/init.sh . --yes --no-hooks --no-agents
```

これで `.agents/skills/` にスキルの複製ができ、`/record-decision` などが `.agents/skills/knowledge-management/references/decisions/` に書き込むようになります。hooks の索引注入もこのディレクトリを読みます。

複製は使い捨てです。`skills/` を変更したら作り直してください。

```bash
rm -rf .agents && bash skills/project-setup/scripts/init.sh . --yes --no-hooks --no-agents
```

### 知識ベースを作らない場合

`.agents/` が無くても hooks は空の JSON を返して何もしません。dogfooding せずに開発しても壊れません。

## マニフェストの検証

```bash
npm run plugin:check
```

[schemas/cursor-plugin.schema.json](../../schemas/cursor-plugin.schema.json) にベンダリングした公式スキーマを使い、`ajv` で検証します。加えて次を確認します。

- `$schema` の URL が公式の `$id` と一致するか
- `plugin.json` と `apm.yml` のバージョンが一致するか
- 既定の探索先にコンポーネントが実在するか（スキーマは通るのに 0 件、という事故の防止）

スキーマを更新する場合は、公式の [`$id`](https://cursor.com/schemas/cursor-plugin/plugin.json) か [cursor/plugins](https://github.com/cursor/plugins) の `schemas/plugin.schema.json` から取得し直してコミットしてください。

## 全体の検証

```bash
npm run docs:check
```

| チェック | 内容 |
|---------|------|
| `skills:check` | Agent Skills 仕様への準拠、`templates/` への複製ガード |
| `components:check` | `hooks.json` のイベント名・スクリプト存在・実行権限、subagent の frontmatter |
| `plugin:check` | 公式スキーマ検証、バージョン整合、コンポーネント探索 |
| `links:check` | `README` / `docs` / `skills` / `agents` / `hooks` / `templates` のリンク切れ |

`gh` が使える環境では配布形式の確認もできます。

```bash
npm run skill:check   # gh skill publish --dry-run
```

## Marketplace への提出

Cursor 公式の [Marketplace 提出フォーム](https://cursor.com/marketplace/publish) から審査にかけます。提出前のチェックリストは [docs/reference/marketplace-submission.md](../reference/marketplace-submission.md) を参照してください。

## 関連ドキュメント

- [hooks ガイド](hooks-guide.md)
- [subagents ガイド](subagents-guide.md)
- [Cursor Plugins 公式ドキュメント](https://cursor.com/ja/docs/plugins)
- [Cursor プラグインテンプレート](https://github.com/cursor/plugin-template)
- [Marketplace セキュリティレビュー](https://cursor.com/help/security-and-privacy/marketplace-security)
