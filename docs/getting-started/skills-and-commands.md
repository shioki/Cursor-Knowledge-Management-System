# スキルとコマンドの概要

## エージェントスキル（Agent Skills）とは

エージェントスキルは、Cursor AI のエージェントにドメイン固有の能力を追加するための仕組みです。スキルは `.cursor/skills/` ディレクトリに配置し、エージェントが文脈に応じて自動的に適用します。

### スキルの構造

各スキルは `SKILL.md` ファイルを含むフォルダです:

```
.cursor/skills/
└── skill-name/
    ├── SKILL.md          # スキル定義（必須）
    ├── scripts/          # 実行可能なスクリプト（任意）
    └── references/       # 追加ドキュメント（任意）
```

### SKILL.md の形式

```markdown
---
name: skill-name
description: スキルの説明。エージェントがいつ使うか判断するために使われます。
---

# スキルタイトル

## When to Use
- このスキルを使うべき場面

## Instructions
- エージェントへの具体的な指示
```

### スキルの動作

1. Cursor 起動時にスキルディレクトリから自動検出
2. エージェントが会話の文脈に基づいてスキルを自動選択
3. `/skill-name` で明示的に呼び出すことも可能
4. スキル内の scripts/ を実行して処理を自動化
5. references/ から必要な情報を段階的に読み込み

## カスタムコマンド（Commands）とは

カスタムコマンドは、チャット入力で `/` を入力するだけで呼び出せる再利用可能なワークフローです。`.cursor/commands/` ディレクトリに Markdown ファイルとして配置します。

### コマンドの構造

```
.cursor/commands/
├── record-decision.md
├── add-pattern.md
└── start-debug.md
```

### コマンドの動作

1. チャットで `/` を入力
2. 利用可能なコマンドが一覧表示
3. コマンドを選択すると、Markdown の内容がエージェントへの指示として読み込まれる
4. エージェントがワークフローに従って対話的に作業を実行

## スキルとコマンドの使い分け

| 特徴 | Skills | Commands |
|------|--------|----------|
| 起動方法 | エージェント自動判断 / `/skill-name` | ユーザーが `/command-name` で起動 |
| ファイル形式 | SKILL.md + scripts/ + references/ | Markdown ファイル 1 つ |
| 主な用途 | ドメイン知識の提供、複雑な自動化 | 定型ワークフローの実行 |
| 適用タイミング | 会話の文脈に応じて自動 | ユーザーが必要な時に明示的に |
| スクリプト実行 | 可能 | 不可（スキル経由で実行） |

### 具体例

**スキルが自動適用される場面:**
- 「ユーザー認証を実装して」→ team-standards スキルが規約を自動参照
- 「このバグの原因は？」→ debug-workflow スキルが過去の類似問題を検索

**コマンドで明示起動する場面:**
- `/record-decision` → 技術判断の記録ワークフローを開始
- `/start-debug` → デバッグセッションを構造化して開始

## 本システムでの活用

### 7 つのスキル

| スキル | 役割 |
|--------|------|
| project-context | プロジェクト背景に基づいた提案 |
| team-standards | コーディング規約の提供 |
| knowledge-management | 技術判断の記録・参照 |
| pattern-library | 実装パターンの管理・提案 |
| debug-workflow | デバッグプロセスの支援 |
| improvement-tracking | 改善活動の追跡 |
| project-setup | 新規プロジェクトへの導入 |

### 6 つのコマンド

| コマンド | アクション |
|----------|-----------|
| /record-decision | 技術判断を対話形式で記録 |
| /add-pattern | 実装パターンを登録 |
| /start-debug | デバッグセッションを開始 |
| /log-improvement | 改善内容を記録 |
| /review-knowledge | 知識ベースの定期レビュー |
| /update-context | プロジェクトコンテキスト更新 |

## 次のステップ

- [スキルガイド](../templates/skills-guide.md) - 各スキルの詳細な使い方
- [コマンドガイド](../templates/commands-guide.md) - 各コマンドの詳細な使い方
- [カスタムスキル・コマンド作成](../advanced/custom-skills.md) - 独自のスキルとコマンドの作り方
