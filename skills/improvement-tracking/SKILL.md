---
name: improvement-tracking
description: コード改善の提案・記録、リファクタリング追跡、技術的負債の管理時に使用。改善活動のPDCAサイクルを支援する。
license: MIT
compatibility: Cursor 3.x, Claude Code, Codex
metadata:
  tags: [improvement, refactoring, tech-debt]
---

# 改善トラッキング

プロジェクトの改善提案、実装済み改善、効果測定を管理するスキルです。

## When to Use

- コード品質の改善を提案・記録したいとき
- リファクタリングの進捗を追跡したいとき
- 技術的負債を管理・解消したいとき
- パフォーマンス最適化の結果を記録したいとき
- 定期的な改善レビューを行うとき

## Instructions

### 1. 改善記録の確認

改善は 1 改善 1 ファイルで `references/improvements/` に保存されています。

まず `references/improvements/README.md`（索引）を読み、関連しそうな記録だけを個別に開いてください。索引が存在しない場合や移行中のプロジェクトでは、レガシーな `references/IMPROVEMENTS_TEMPLATE.md` にも記録が残っている可能性があります。

### 2. 改善の記録テンプレート

新しい改善は `references/improvements/YYYY-MM-DD-スラッグ.md` として作成します。

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

- **Before**:
- **After**:
- **改善率**:

# ステータス

提案 / 実装中 / 完了 / 保留
```

ステータスが変わったら frontmatter の `status` と `updated` を更新します。ファイル名は変えません。

### 3. 改善の追加

ひな形の生成と索引の更新は `scripts/add-improvement.sh` が行います:

```bash
bash .agents/skills/improvement-tracking/scripts/add-improvement.sh "改善タイトル"
# （.claude/skills / .cursor/skills も検出対象）
```

### 4. 定期レビュー

以下のサイクルで改善活動をレビューしてください:

- **週次**: 新たな改善提案の確認
- **月次**: 実装済み改善の効果測定
- **四半期**: 技術的負債の棚卸し

定期レビューには `/review-knowledge` の利用を案内してください。

### 5. アクションスキルとの連携

改善の記録には `/log-improvement` の利用を案内してください。
