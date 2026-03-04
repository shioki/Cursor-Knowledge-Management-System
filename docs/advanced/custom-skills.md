# カスタムスキル・コマンド作成ガイド

本システムのスキルとコマンドをカスタマイズしたり、独自のスキル・コマンドを作成する方法を解説します。

## カスタムスキルの作成

### 1. ディレクトリ作成

`.claude/skills/`（または `.cursor/skills/`）配下に新しいフォルダを作成します:

```bash
mkdir -p .claude/skills/my-custom-skill/{scripts,references}
```

### 2. SKILL.md の作成

`SKILL.md` に YAML フロントマターと手順を記述します:

```markdown
---
name: my-custom-skill
description: このスキルが使われる場面の説明。エージェントが自動判断の際に参照します。
---

# スキルタイトル

スキルの概要説明。

## When to Use

- このスキルを使うべき場面1
- このスキルを使うべき場面2

## Instructions

### Step 1
具体的な手順

### Step 2
具体的な手順
```

### 3. フロントマターのフィールド

| フィールド | 必須 | 説明 |
|-----------|------|------|
| `name` | Yes | スキルの識別子。フォルダ名と一致させる |
| `description` | Yes | スキルの用途の説明。エージェントの自動判断に使用される |
| `license` | No | ライセンス情報 |
| `compatibility` | No | 環境要件 |
| `disable-model-invocation` | No | `true` で自動適用を無効化（手動呼び出しのみ） |

### 4. スクリプトの追加（任意）

`scripts/` ディレクトリに自動化スクリプトを配置します:

```bash
#!/usr/bin/env bash
# my-custom-skill: スクリプトの説明
set -euo pipefail

# 処理内容
echo "スクリプト実行完了"
```

スクリプトのベストプラクティス:
- **自己完結型**: 外部依存を最小限に
- **エラーハンドリング**: `set -euo pipefail` を使用
- **引数チェック**: 必須引数の存在確認
- **わかりやすい出力**: 成功/失敗のメッセージ

### 5. リファレンスの追加（任意）

`references/` ディレクトリに追加ドキュメントを配置します。エージェントは必要に応じてこれらを読み込みます。

```
.claude/skills/my-custom-skill/
├── SKILL.md
├── scripts/
│   └── process.sh
└── references/
    ├── TEMPLATE.md
    └── EXAMPLES.md
```

## カスタムコマンドの作成

### 1. Markdown ファイル作成

`.cursor/commands/` ディレクトリに Markdown ファイルを作成します:

```bash
touch .cursor/commands/my-command.md
```

### 2. コマンド内容の記述

```markdown
# コマンドタイトル

コマンドの概要説明。

## 手順

1. ユーザーに必要な情報をヒアリング
2. 関連するスキルのリファレンスを読み込み
3. 処理を実行
4. 結果を提示

## 注意事項

- 注意事項1
- 注意事項2
```

### 3. スキルとの連携

コマンドからスキルの機能を活用する記述例:

```markdown
## 手順

1. ユーザーに情報をヒアリング
2. `.claude/skills/knowledge-management/references/KNOWLEDGE_TEMPLATE.md` を読み込み
3. `scripts/add-entry.sh` でエントリ作成
4. 結果を提示
```

## 設計のベストプラクティス

### スキルの設計原則

1. **単一責任**: 1 つのスキルは 1 つのドメインに集中
2. **description の充実**: エージェントの自動判断精度に直結
3. **段階的読み込み**: SKILL.md は要点のみ、詳細は references/ に分離
4. **実行可能性**: scripts/ で自動化できる処理はスクリプト化

### コマンドの設計原則

1. **対話的**: ユーザーとの対話を前提に設計
2. **スキル連携**: 複雑な処理はスキルに委譲
3. **簡潔**: 手順は明確かつ最小限に
4. **エラーケース**: 想定外の入力への対応を記述

### スキル vs コマンドの選択基準

| スキルが適切 | コマンドが適切 |
|-------------|---------------|
| エージェントが自動判断すべき | ユーザーが明示的に起動すべき |
| 複雑な自動化処理が必要 | 定型的なワークフロー |
| リファレンスドキュメントが豊富 | シンプルな手順 |
| 複数の場面で適用される | 特定のアクションに紐付く |

## 自動呼び出しの制御

### 自動適用を無効にする

デフォルトではエージェントがスキルを自動適用しますが、`disable-model-invocation: true` で手動呼び出しのみにできます:

```yaml
---
name: dangerous-operation
description: データベースのマイグレーション実行
disable-model-invocation: true
---
```

この場合、チャットで `/dangerous-operation` と明示的に入力した場合のみ適用されます。

## 構造の検証

カスタムスキル・コマンドを追加した後は、以下で構造を検証できます:

```bash
bash .claude/skills/project-setup/scripts/validate.sh
```

作成したスキルは Cursor のスキルとしてそのまま利用できます。将来的に [Cursor Marketplace](https://cursor.com/ja/blog/marketplace) でプラグインとして共有する場合は、Skills に加えて MCP や Rules などをまとめたプラグインとして投稿する形が想定されています。詳細は [Cursor プラグイン・マーケットプレイス](../reference/cursor-plugins-and-marketplace.md) を参照してください。

## 参考リンク

- [Agent Skills 標準仕様](https://agentskills.io)
- [Cursor エージェントスキルドキュメント](https://cursor.com/ja/docs/context/skills)
- [Cursor コマンドドキュメント](https://cursor.com/ja/docs/context/commands)
