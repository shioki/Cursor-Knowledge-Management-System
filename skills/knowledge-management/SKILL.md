---
name: knowledge-management
description: 技術判断の記録・参照、過去の設計決定の検索、技術的知見の蓄積を行う際に使用。「なぜこの技術を選んだ？」等の質問時にも活用する。
license: MIT
compatibility: Cursor 3.x, Claude Code, Codex
metadata:
  tags: [knowledge, adr, decision-log]
---

# 知識管理

プロジェクトにおける技術的判断、設計決定、学習記録を体系的に管理するスキルです。

## When to Use

- 技術的な判断や設計決定を記録したいとき
- 過去の技術判断を参照・検索したいとき
- 「なぜこの技術を選んだのか？」といった質問に答えるとき
- アーキテクチャ決定記録（ADR）を管理するとき

## Instructions

### 1. 知識の参照

技術判断は 1 判断 1 ファイルで `references/decisions/` に保存されています。

まず `references/decisions/README.md`（索引）を読み、関連しそうな判断だけを個別に開いてください。全ファイルを一括で読む必要はありません。索引が存在しない場合や、v5 以前から移行中のプロジェクトでは、レガシーな `references/KNOWLEDGE_TEMPLATE.md` にも記録が残っている可能性があります。

### 2. 技術判断の記録

新しい判断は `references/decisions/YYYY-MM-DD-スラッグ.md` として作成します。スラッグは英数字とハイフンのみで構成し、本文は日本語で構いません。

```markdown
---
title: "判断タイトル"
description: "" # 1 行サマリを記入
tags: [adr]
updated: YYYY-MM-DD
---

# 判断内容

# 検討した選択肢

# 決定と理由

# 影響範囲
```

`title` に `|` や `:` や `"` が含まれる場合はダブルクォートで囲みます。`scripts/add-entry.sh` は `ckms_yaml_escape` で自動処理します。

ファイルを作成したら、`references/decisions/README.md` の一覧表にも 1 行追加してください。

### 3. 記録の自動化

ひな形の生成と索引の更新は `scripts/add-entry.sh` が行います:

```bash
bash .agents/skills/knowledge-management/scripts/add-entry.sh "判断タイトル"
# （.claude/skills / .cursor/skills も検出対象）
```

### 4. 関連付け

判断どうし、および実装パターンとは Markdown リンクで接続してください。「なぜこの技術を選んだのか」に答えるとき、根拠となる判断へのリンクをたどれることが重要です。

### 5. アクションスキルとの連携

ユーザーが技術判断を記録したい場合は、`/record-decision` の利用を案内してください。棚卸しには `/review-knowledge` を案内します。
