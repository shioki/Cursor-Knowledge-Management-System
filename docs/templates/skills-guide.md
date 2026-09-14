# スキルガイド

本システムが提供するスキル 13 種の使い方を解説します。

スキルは起動のされ方で 2 つに分かれます。ドメインスキル 7 種はエージェントが会話の文脈から自動で選択するもので、ユーザーが意識して呼ぶ必要はありません。アクションスキル 6 種は `disable-model-invocation: true` が設定されていて、ユーザーが `/` で明示的に起動したときだけ動きます。記録を作る操作はすべて後者です。

| スキル | 種類 | 用途 |
|--------|------|------|
| [project-context](#project-context) | ドメイン | プロジェクトの背景・制約・技術スタックに基づいた提案 |
| [team-standards](#team-standards) | ドメイン | コーディング規約、命名規則、開発フローの標準 |
| [knowledge-management](#knowledge-management) | ドメイン | 技術判断の記録・参照・検索 |
| [pattern-library](#pattern-library) | ドメイン | 実装パターンの検索・適用・登録 |
| [debug-workflow](#debug-workflow) | ドメイン | デバッグプロセスの支援と過去事例の検索 |
| [improvement-tracking](#improvement-tracking) | ドメイン | 改善提案の記録・効果測定・追跡 |
| [project-setup](#project-setup) | ドメイン | 導入・構造検証・初期カスタマイズ |
| [/record-decision](#record-decision) | アクション | 技術判断を ADR として記録 |
| [/add-pattern](#add-pattern) | アクション | 実装パターンを登録 |
| [/start-debug](#start-debug) | アクション | デバッグセッションを開始 |
| [/log-improvement](#log-improvement) | アクション | 改善内容を記録 |
| [/review-knowledge](#review-knowledge) | アクション | 知識ベースを棚卸し |
| [/update-context](#update-context) | アクション | コンテキスト情報を更新 |

本ガイドではファイルの場所を配布元リポジトリの `skills/` 起点で示します。プロジェクトに導入したあとは、既定では `.agents/skills/` に読み替えてください（`--legacy-claude` なら `.claude/skills/`、`--cursor-only` なら `.cursor/skills/`）。

---

## ドメインスキル

### project-context

#### 概要

プロジェクトの背景、制約、技術スタック、アーキテクチャを参照し、その前提に沿った提案を行うスキルです。

#### 自動適用される場面

- 新機能の設計・実装方針を提案するとき
- 技術スタックに関する質問があったとき
- アーキテクチャの議論や、制約を踏まえた判断が必要なとき

#### 関連ファイル

| ファイル | 内容 |
|---------|------|
| `skills/project-context/references/CONTEXT_TEMPLATE.md` | プロジェクトの基本情報。ここを埋めるのが導入時の最初の作業 |

#### カスタマイズ方法

`CONTEXT_TEMPLATE.md` にプロジェクト情報を記入します。手で書くよりも `/update-context` を使うほうが、既存の記録との差分を提示してもらえるぶん確実です。

```markdown
## プロジェクト基本情報

| 項目 | 内容 |
|------|------|
| プロジェクト名 | My Awesome App |
| 目的 | EC サイトのリニューアル |
| 開始時期 | 2026-01 |
| チーム規模 | 5 名 |

## 技術スタック

### フロントエンド

| 技術 | バージョン | 用途 |
|------|-----------|------|
| React | 19.x | UI フレームワーク |
| TypeScript | 5.x | 型安全性 |
```

ここが古いと他のすべてのスキルの提案精度が落ちます。技術スタックを変えたら `/update-context` で追随させてください。

#### 連携するアクションスキル

- `/update-context` — コンテキスト情報の更新

---

### team-standards

#### 概要

コーディング規約、命名規則、ブランチ戦略、コミットメッセージ規約、コードレビュー基準を提供するスキルです。

#### 自動適用される場面

frontmatter に `paths` が設定されており、ソースコードを扱っているときにだけ surface します。ドキュメントだけを編集している会話では読み込まれません。

```yaml
paths:
  - "**/*.{ts,tsx,js,jsx,mjs,cjs}"
  - "**/*.{py,rb,go,rs,java,kt,swift}"
  - "**/*.{c,h,cc,cpp,hpp,cs,php}"
  - "**/*.{vue,svelte,css,scss}"
  - "**/*.{sql,sh,ps1}"
```

#### カスタマイズ方法

`skills/team-standards/SKILL.md` の各セクションをチームの規約に合わせて書き換えます。既定値は一般的な JavaScript / TypeScript プロジェクトを想定した内容なので、そのまま使えるチームは多くありません。導入直後に必ず調整してください。

```markdown
#### 命名規則

- **変数・関数**: snake_case（Python プロジェクトの場合）
- **クラス**: PascalCase
- **定数**: UPPER_SNAKE_CASE
- **ファイル名**: snake_case.py
```

`paths` もチームが実際に使う言語だけに絞ると、無関係な会話でのトークン消費を抑えられます。

---

### knowledge-management

#### 概要

技術判断・設計決定の記録と参照を管理するスキルです。「なぜこの技術を選んだのか」に後から答えられる状態を保つことが目的です。

#### 自動適用される場面

- 「なぜこの技術を選んだ？」といった質問があったとき
- 技術選定を議論するとき
- 過去の決定を参照する必要があるとき

#### 関連ファイル

| ファイル | 内容 |
|---------|------|
| `skills/knowledge-management/references/decisions/README.md` | 索引。まずここを読んで対象を絞る |
| `skills/knowledge-management/references/decisions/YYYY-MM-DD-スラッグ.md` | 個々の技術判断 |
| `skills/knowledge-management/references/KNOWLEDGE_TEMPLATE.md` | v5 以前のレガシー記録の保管場所 |

1 判断 1 ファイルです。エージェントは索引だけを読み、関連しそうな判断を個別に開きます。全文を読み込まないので、記録が増えてもコンテキストを圧迫しません。

#### 記録フォーマット

```markdown
---
title: 判断タイトル
description: 1 行サマリ
tags: [adr]
updated: YYYY-MM-DD
---

# 判断内容

# 検討した選択肢

# 決定と理由

# 影響範囲
```

不採用にした選択肢とその理由を残すことが重要です。後から同じ検討を蒸し返さずに済みます。

#### 自動化スクリプト

```bash
bash .agents/skills/knowledge-management/scripts/add-entry.sh "判断タイトル"
```

`decisions/YYYY-MM-DD-スラッグ.md` を作成し、`decisions/README.md` の索引にも 1 行追加します。

#### 連携するアクションスキル

- `/record-decision` — 対話形式で技術判断を記録
- `/review-knowledge` — 知識ベースの棚卸し

---

### pattern-library

#### 概要

実装パターン、設計パターン、テストパターンの検索・適用・登録を管理するスキルです。

#### 自動適用される場面

- 新機能の実装前に既存パターンを確認するとき
- 実装方法のベストプラクティスを知りたいとき
- リファクタリングでパターンの統一を図るとき

#### 関連ファイル

| ファイル | 内容 |
|---------|------|
| `skills/pattern-library/references/patterns/README.md` | 索引 |
| `skills/pattern-library/references/patterns/スラッグ.md` | 個々のパターン |
| `skills/pattern-library/references/PATTERNS_TEMPLATE.md` | v5 以前のレガシー記録の保管場所 |

技術判断と違ってパターンは日付に紐づかないため、ファイル名にはスラッグだけを使います。

#### 記録フォーマット

```markdown
---
title: パターン名
description: 1 行サマリ
tags: [pattern]
updated: YYYY-MM-DD
---

# 目的

- **解決する問題**:
- **適用場面**:
- **期待効果**:

# 実装例

# 使用上の注意

# 関連パターン
```

実装例には擬似コードではなく動作する具体的なコードを入れてください。適用場面を明示して、過剰な一般化を避けます。

#### 自動化スクリプト

```bash
bash .agents/skills/pattern-library/scripts/add-pattern.sh "パターン名"
```

#### 連携するアクションスキル

- `/add-pattern` — 対話形式でパターンを登録

---

### debug-workflow

#### 概要

問題の特定から解決、記録までのデバッグプロセス全体を支援するスキルです。

#### 自動適用される場面

- バグやエラーが発生したとき
- パフォーマンス問題を調査するとき
- 過去の類似問題を検索したいとき

#### 関連ファイル

| ファイル | 内容 |
|---------|------|
| `skills/debug-workflow/references/DEBUG_TEMPLATE.md` | セッション記録のテンプレートと過去事例 |
| `<base>/debug-sessions/YYYY-MM-DD_スラッグ.md` | 個々のデバッグセッション |

セッションファイルの保存先はスキルの下ではなく、ベースディレクトリ直下の `debug-sessions/` です（既定では `.agents/debug-sessions/`）。

#### デバッグの流れ

1. `/start-debug` でセッションを開始する
2. 症状・環境・再現手順をヒアリングする
3. 過去の類似問題を検索する
4. 仮説を複数立て、確認コストの低いものから検証する
5. 調査の各ステップをセッションファイルに追記する
6. 解決後、`/log-improvement` で再発防止策を改善記録に残す

結論だけを残すと類似問題の参考になりません。試して外した仮説も残してください。

#### 自動化スクリプト

```bash
# セッション作成
bash .agents/skills/debug-workflow/scripts/create-session.sh "ログイン画面のエラー"

# 過去セッション検索
bash .agents/skills/debug-workflow/scripts/search-sessions.sh "認証"
```

#### 連携するアクションスキル

- `/start-debug` — デバッグセッション開始
- `/log-improvement` — 解決後の改善記録

---

### improvement-tracking

#### 概要

改善提案、リファクタリング、技術的負債の記録と効果測定を管理するスキルです。

#### 自動適用される場面

- リファクタリング後の効果を測定するとき
- 技術的負債を議論するとき
- コードレビューで改善を提案するとき

#### 関連ファイル

| ファイル | 内容 |
|---------|------|
| `skills/improvement-tracking/references/improvements/README.md` | 索引 |
| `skills/improvement-tracking/references/improvements/YYYY-MM-DD-スラッグ.md` | 個々の改善記録 |
| `skills/improvement-tracking/references/IMPROVEMENTS_TEMPLATE.md` | v5 以前のレガシー記録の保管場所 |

#### 記録フォーマット

```markdown
---
title: 改善タイトル
description: 1 行サマリ
tags: [improvement]
status: 提案
updated: YYYY-MM-DD
---

# 背景

# 改善内容

# 効果

- **Before**: 平均 450ms
- **After**: 平均 50ms（キャッシュヒット時）
- **改善率**: 89%

# ステータス
```

ステータスが変わったら frontmatter の `status` と `updated` を更新します。ファイル名は変えません。日付は記録を始めた日を指すので、進行に合わせて変えると履歴が追えなくなります。

#### 自動化スクリプト

```bash
bash .agents/skills/improvement-tracking/scripts/add-improvement.sh "API レスポンスキャッシュ導入"
```

#### 連携するアクションスキル

- `/log-improvement` — 改善内容を記録
- `/review-knowledge` — 効果の定期レビュー

---

### project-setup

#### 概要

プロジェクトへの導入、構造検証、初期カスタマイズを支援するスキルです。

#### 使用場面

- 新規プロジェクトに導入するとき
- 既存プロジェクトにスキル・hooks・subagent を追加するとき
- セットアップの正しさを検証したいとき

#### セットアップ

```bash
# 既定: .agents/skills に配置。Claude Code へは .claude/skills のシンボリックリンクで橋渡し
bash skills/project-setup/scripts/init.sh /path/to/your-project

# 非対話モード（CI 向け）
bash skills/project-setup/scripts/init.sh /path/to/your-project --yes
```

| オプション | 効果 |
|-----------|------|
| `--yes` / `-y` | すべての確認に yes と答える |
| `--legacy-claude` | `.claude/skills` に配置（v4.x 互換） |
| `--cursor-only` | `.cursor/skills` に配置（Cursor のみ） |
| `--with-agents-md` | `AGENTS.md` テンプレートも配置（`CLAUDE.md` も同時に作成） |
| `--no-hooks` | hooks を配置しない |
| `--no-agents` | subagent を配置しない |
| `--no-claude-bridge` | `.claude/skills` への橋渡しを作らない |

Windows では同じディレクトリの `init.ps1`、または Git Bash / WSL で `init.sh` を使ってください。

#### 構造の検証

```bash
bash .agents/skills/project-setup/scripts/validate.sh
```

スキル 13 種の存在と frontmatter、知識ディレクトリ、スクリプトの実行権限、hooks と subagent の配置を確認します。v5 の `.cursor/commands/` が残っている場合も警告します。

#### 詳細

[クイックスタート](../getting-started/quick-start.md) を参照してください。

---

## アクションスキル

いずれもチャットで `/` に続けてスキル名を入力したときだけ起動します。エージェントが自動で実行することはありません。記録の作成という副作用があるためです。

ここでは概要のみを示します。ヒアリング項目や出力例を含む詳しい手順は [アクションスキルガイド](action-skills-guide.md) を参照してください。

### /record-decision

技術判断・設計決定を 1 判断 1 ファイルの ADR として記録します。判断内容・検討した選択肢・決定理由・影響範囲をヒアリングし、既存の判断と重複しないか索引を確認したうえで `decisions/YYYY-MM-DD-スラッグ.md` を作成します。既存判断を覆す決定の場合は、古い記録にもその旨を追記します。

### /add-pattern

実装パターンをパターンライブラリに登録します。目的・実装例・注意事項をヒアリングし、`patterns/スラッグ.md` を作成します。類似パターンが既にある場合は、新規作成ではなく既存への統合を提案します。

### /start-debug

デバッグセッションを開始します。症状・環境・再現手順・緊急度をヒアリングし、過去の類似セッションを検索したうえで `<base>/debug-sessions/YYYY-MM-DD_スラッグ.md` を作成します。以降の調査ログはこのファイルに追記していきます。

### /log-improvement

リファクタリング・最適化・技術的負債の解消を記録します。背景・改善内容・Before/After・ステータスをヒアリングし、`improvements/YYYY-MM-DD-スラッグ.md` を作成します。効果は可能な限り数値で残してください。

### /review-knowledge

蓄積した知識ベースを棚卸しし、陳腐化・矛盾・重複・リンク切れ・記録漏れを洗い出します。走査は `knowledge-curator` subagent に委譲されるため、メインの会話には結果のレポートだけが返ります。更新はユーザーが合意した項目だけを実施します。

### /update-context

プロジェクトの技術スタック・アーキテクチャ・制約・チーム体制を更新します。`package.json` などの依存定義と記録の差分を先に洗い出したうえで、更新内容を差分として提示してから書き換えます。

---

## 知識の保存先

記録の種類ごとの保存先です。`<base>` は既定で `.agents` です。

| 種類 | 保存先 | ファイル名 |
|------|--------|-----------|
| 技術判断 | `<base>/skills/knowledge-management/references/decisions/` | `YYYY-MM-DD-スラッグ.md` |
| 実装パターン | `<base>/skills/pattern-library/references/patterns/` | `スラッグ.md` |
| 改善記録 | `<base>/skills/improvement-tracking/references/improvements/` | `YYYY-MM-DD-スラッグ.md` |
| デバッグセッション | `<base>/debug-sessions/` | `YYYY-MM-DD_スラッグ.md` |
| プロジェクト背景 | `<base>/skills/project-context/references/` | `CONTEXT_TEMPLATE.md` |

各ディレクトリの `README.md` が索引です。スクリプトが自動で 1 行追記するため、手で更新する必要はありません。手動でファイルを追加した場合だけ、索引にも追記してください。

`sessionStart` フックを有効にしている場合、会話の冒頭でこれらの索引が自動的に注入されます（[hooks ガイド](../advanced/hooks-guide.md)）。

## 関連ドキュメント

- [アクションスキルガイド](action-skills-guide.md)
- [クイックスタート](../getting-started/quick-start.md)
- [カスタムスキル作成ガイド](../advanced/custom-skills.md)
- [チーム導入ガイド](../advanced/team-implementation.md)
- [subagents ガイド](../advanced/subagents-guide.md)
