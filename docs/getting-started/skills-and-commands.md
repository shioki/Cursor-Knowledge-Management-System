# スキルの全体像

v6.0.0 で、CKMS が提供する機能はすべて Agent Skills に統一されました。以前は「スキル 7 種 + Cursor 専用コマンド 7 種」でしたが、コマンドはアクションスキルとして取り込まれています。

この統一により、`/record-decision` のような記録ワークフローが Cursor だけでなく Claude Code や Codex でも使えるようになりました。コマンドは Cursor 独自の仕組みで、他のエージェントには存在しないためです。

## Agent Skills とは

エージェントにドメイン固有の能力を追加する仕組みです。`SKILL.md` を含むフォルダとして定義し、`.agents/skills/` に置くと Cursor・Claude Code・Codex が共通して読み込みます。

```text
.agents/skills/
└── skill-name/
    ├── SKILL.md          # スキル定義（必須）
    ├── scripts/          # 実行可能なスクリプト（任意）
    └── references/       # 追加ドキュメント（任意）
```

`SKILL.md` は YAML frontmatter と本文からなります。

```markdown
---
name: skill-name
description: スキルの説明。エージェントはこれを読んで、いつ使うかを判断します。
license: MIT
---

# スキルタイトル

## When to Use

## Instructions
```

エージェントが最初に読むのは `description` だけです。関連しそうだと判断したときに本文を読み、さらに必要なら `references/` を開きます。この段階的な読み込みが、コンテキストを節約しながら知識を提供する仕組みです。

## 2 種類のスキル

CKMS のスキルは、起動のされ方で 2 つに分かれます。

| | ドメインスキル | アクションスキル |
|---|---------------|-----------------|
| 起動 | エージェントが文脈から自動選択 | ユーザーが `/名前` で明示起動 |
| frontmatter | 通常 | `disable-model-invocation: true` |
| 役割 | 質問への回答に知識を反映する | 記録・レビューのワークフローを実行する |
| 件数 | 7 | 6 |

### なぜ分けるのか

「認証を実装して」と頼んだときに規約が自動で参照されるのは望ましい挙動です。一方で、頼んでもいないのに勝手に技術判断を記録し始めるのは困ります。記録はユーザーの意思で行うべき行為なので、明示起動に限定しています。

`disable-model-invocation: true` を設定すると、モデルは自動でそのスキルを読み込まなくなり、ユーザーが `/名前` と入力したときだけ動きます。以前のコマンドと同じ使用感です。

## ドメインスキル 7 種

| スキル | 役割 |
|--------|------|
| `project-context` | プロジェクト背景・技術スタックに基づいた提案 |
| `team-standards` | コーディング規約・レビュー基準の提供 |
| `knowledge-management` | 技術判断の記録・参照 |
| `pattern-library` | 実装パターンの管理・提案 |
| `debug-workflow` | デバッグプロセスの支援 |
| `improvement-tracking` | 改善活動の追跡 |
| `project-setup` | 新規プロジェクトへの導入 |

`team-standards` には frontmatter の `paths` が設定してあり、ソースコードを扱っているときだけ読み込まれます。ドキュメントを書いているときにコーディング規約を持ち出されても邪魔なだけだからです。

## アクションスキル 6 種

| 起動 | アクション |
|------|-----------|
| `/record-decision` | 技術判断を対話形式で記録 |
| `/add-pattern` | 実装パターンを登録 |
| `/start-debug` | デバッグセッションを開始 |
| `/log-improvement` | 改善内容を記録 |
| `/review-knowledge` | 知識ベースの棚卸し |
| `/update-context` | プロジェクトコンテキストの更新 |

`/review-knowledge` は走査を `knowledge-curator` サブエージェントに委譲します（[subagents ガイド](../advanced/subagents-guide.md)）。

## 動作例

**ドメインスキルが自動適用される場面**

- 「ユーザー認証を実装して」→ `team-standards` が規約を、`pattern-library` が既存パターンを参照
- 「このバグの原因は？」→ `debug-workflow` が過去の類似セッションを検索
- 「なぜ PostgreSQL を使っているの？」→ `knowledge-management` が該当する技術判断を参照

**アクションスキルを明示起動する場面**

- `/record-decision` → 判断内容をヒアリングし、`decisions/YYYY-MM-DD-スラッグ.md` を生成
- `/start-debug` → 症状をヒアリングし、セッションファイルを作成して調査を開始

## 知識はどこに溜まるか

記録は 1 概念 1 ファイルで保存されます。

```text
.agents/
├── skills/
│   ├── knowledge-management/references/decisions/
│   │   ├── README.md                          # 索引
│   │   └── 2026-06-18-adopt-postgresql.md
│   ├── pattern-library/references/patterns/
│   └── improvement-tracking/references/improvements/
└── debug-sessions/
```

各ディレクトリの `README.md` が索引です。エージェントはまず索引を読み、関連しそうなファイルだけを開きます。1 つの大きなファイルに追記し続ける方式だと、記録が増えるほど毎回の読み込みが重くなるため、v6 でこの構成に変えました。

hooks を有効にしている場合、会話の開始時にこの索引が自動で渡されます（[hooks ガイド](../advanced/hooks-guide.md)）。

## 次のステップ

- [スキルガイド](../templates/skills-guide.md) — ドメインスキル 7 種の詳細
- [アクションスキルガイド](../templates/action-skills-guide.md) — アクションスキル 6 種の詳細
- [カスタムスキルの作り方](../advanced/custom-skills.md) — 独自スキルの追加
