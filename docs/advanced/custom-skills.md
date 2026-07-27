# カスタムスキル作成ガイド

本システムのスキルをカスタマイズしたり、プロジェクト固有のスキルを新しく作る方法を解説します。

## 2 種類のスキル

v6 のスキルは、起動のされ方で 2 つに分かれます。作り始める前に、どちらを作るのかを決めてください。frontmatter の書き方が変わります。

| 種類 | 起動 | frontmatter | 例 |
|------|------|------------|-----|
| ドメインスキル | エージェントが文脈から自動選択 | `description`（必要なら `paths`） | `knowledge-management`, `team-standards` |
| アクションスキル | ユーザーが `/名前` で明示起動 | `disable-model-invocation: true` | `/record-decision`, `/add-pattern` |

判断の目安は「エージェントに勝手に使ってほしいか」です。参照されるべき知識やレビュー観点はドメインスキル、ファイルを作る・記録を残すといった副作用のある手続きはアクションスキルが向いています。v5 まで slash command だったものは、すべて後者に該当します。

## 置き場所

| 対象 | 置き場所 |
|------|---------|
| 本リポジトリで配布物として作る | リポジトリ直下の `skills/` |
| 利用側プロジェクトに固有のスキルを足す | `.agents/skills/`（`.claude/skills/` / `.cursor/skills/` でも可） |

本リポジトリでは `skills/` が唯一の正です。`templates/` 以下に複製を置かないでください。v5 では同じ `SKILL.md` を 2 箇所で管理した結果すべてが drift しました。`npm run skills:check` はこの再発を検出します。

## 1. ディレクトリの作成

```bash
mkdir -p skills/my-custom-skill/{scripts,references}
```

フォルダ名は kebab-case にします。frontmatter の `name` と一致していなければ検証で落ちます。

## 2. SKILL.md の作成

```markdown
---
name: my-custom-skill
description: このスキルを使うべき場面の説明。エージェントはこれだけを見て読み込みを判断する。
license: MIT
compatibility: Cursor 3.x, Claude Code, Codex
metadata:
  tags: [example]
---

# スキルタイトル

スキルの概要説明。

## When to Use

- このスキルを使うべき場面 1
- このスキルを使うべき場面 2

## Instructions

### 1. 最初の手順

具体的な指示。

### 2. 次の手順

具体的な指示。
```

## 3. frontmatter のフィールド

[Agent Skills 仕様](https://agentskills.io)で定義されている最上位キーだけが有効です。仕様外のキーを書いても無視されるだけなので、`npm run skills:check` は警告を出します。

| キー | 必須 | 内容 |
|------|------|------|
| `name` | Yes | スキルの識別子。64 文字以下の kebab-case で、フォルダ名と一致させる |
| `description` | Yes | 1024 文字以下。どんなときに使うかを書く |
| `paths` | No | glob の文字列または配列。指定したファイルを扱っているときだけ surface する |
| `disable-model-invocation` | No | `true` にすると自動読み込みが止まり、`/名前` での明示起動だけになる |
| `license` | No | ライセンス。`gh skill publish` での配布時に推奨 |
| `compatibility` | No | 動作環境 |
| `metadata` | No | 任意のメタデータ。`metadata.tags` は検索性を上げる |
| `allowed-tools` | No | スキル実行中に許可するツールの制限 |
| `model` | No | 使用モデルの指定 |
| `version` | No | スキル自体のバージョン |

### description はエージェント向けに書く

ドメインスキルにとって `description` は唯一の判断材料です。エージェントは会話の冒頭で全スキルの `description` だけを読み、そこから読み込むスキルを選びます。本文がどれだけ充実していても、`description` が「〜を管理するスキル」のような静的な説明だと選ばれません。

```yaml
# 選ばれにくい
description: API 設計のスキル

# 選ばれやすい
description: REST API のエンドポイント追加・変更時に使用。命名規則、エラーレスポンス形式、バージョニング方針を提供する。
```

### paths で読み込み範囲を絞る

`paths` を指定すると、そのファイルを扱っているときだけスキルが候補に上がります。常時候補に出す必要のないスキルを絞り込むと、無関係な会話でのトークン消費を抑えられます。

本システムでは `team-standards` がこれを使っています。コーディング規約はソースコードを触っているときにだけ必要で、ドキュメントの編集中には要らないためです。

```yaml
paths:
  - "**/*.{ts,tsx,js,jsx,mjs,cjs}"
  - "**/*.{py,rb,go,rs,java,kt,swift}"
```

自分のスキルに設定する場合も、実際にそのスキルが役立つファイル種別だけを列挙してください。広く書きすぎると `paths` を付けない場合と変わらなくなります。

### disable-model-invocation でアクションスキルにする

```yaml
---
name: deploy-staging
description: ステージング環境へのデプロイ手順を実行する。ユーザーが /deploy-staging と明示的に入力したときだけ起動する。
disable-model-invocation: true
---
```

これでエージェントによる自動読み込みが止まり、チャットで `/deploy-staging` と入力したときだけ動きます。`description` にも「ユーザーが明示的に入力したときだけ起動する」と書いておくと、意図が読み手にも伝わります。

デプロイ、外部への通知、ファイルの一括生成のように、勝手に実行されると困る手続きはこちらにしてください。

## 4. スクリプトの追加（任意）

`scripts/` に自動化スクリプトを置くと、スキルの手順から呼び出せます。

```bash
#!/usr/bin/env bash
# my-custom-skill: スクリプトの説明
set -euo pipefail

echo "スクリプト実行完了"
```

- 外部依存を最小限にする。本システムの配布スクリプトは `jq` / `python` / `node` に依存させず、POSIX シェルと `sed` / `awk` / `find` の範囲で書いています。利用者の環境に何が入っているかは分からないためです
- `set -euo pipefail` でエラーを握りつぶさない
- 必須引数の存在を確認する
- 成功・失敗が分かる出力を出す
- 実行権限を付けてコミットする。`npm run skills:check` が検証します

## 5. リファレンスの追加（任意）

`references/` には、必要になったときだけ読ませたい詳細を置きます。`SKILL.md` は入口として軽く保ち、テンプレートや長い実例はこちらに分離してください。この段階的読み込みがトークン削減の中心です。

```
skills/my-custom-skill/
├── SKILL.md
├── scripts/
│   └── process.sh
└── references/
    ├── TEMPLATE.md
    └── EXAMPLES.md
```

蓄積型の記録を扱うスキルでは、1 概念 1 ファイルにして索引の `README.md` を置く形を推奨します。単一ファイルに追記し続けると、参照のたびに全文を読むことになり、段階的読み込みの意味が失われます。本システムの `knowledge-management` / `pattern-library` / `improvement-tracking` はこの構成です。

## 6. 検証

```bash
npm run skills:check
```

次を確認します。

- `SKILL.md` の存在と、frontmatter の構文
- `name` が kebab-case で 64 文字以下、かつフォルダ名と一致すること
- `description` が存在し 1024 文字以下であること（極端に短い場合は警告）
- `paths` が文字列または文字列配列であること
- `disable-model-invocation` が真偽値であること
- 仕様外の frontmatter キーがないこと（警告）
- `scripts/` 配下の `*.sh` に実行権限があること
- `templates/` 以下に `SKILL.md` の複製がないこと

利用側プロジェクトに配置したあとの構造は、次で検証できます。

```bash
bash .agents/skills/project-setup/scripts/validate.sh
```

## 配布

作成したスキルは、そのままリポジトリの `skills/` に置いておけば Cursor Plugin・`gh skill install`・`apm install` のいずれの経路でも配布できます。マニフェストへの追記は不要です。詳細は [Cursor Plugin 開発ガイド](plugin-development.md) を参照してください。

## 参考リンク

- [Agent Skills 標準仕様](https://agentskills.io)
- [Cursor エージェントスキルドキュメント](https://cursor.com/ja/docs/context/skills)
- [Cursor プラグイン・マーケットプレイス](../reference/cursor-plugins-and-marketplace.md)
- [hooks ガイド](hooks-guide.md)
- [subagents ガイド](subagents-guide.md)
