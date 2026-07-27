---
name: log-improvement
description: リファクタリング・最適化・技術的負債解消などの改善内容を 1 改善 1 ファイルで記録する。ユーザーが /log-improvement と明示的に入力したときだけ起動する。
disable-model-invocation: true
license: MIT
compatibility: Cursor 3.x, Claude Code, Codex
metadata:
  tags: [improvement, refactoring, tech-debt, action]
---

# 改善を記録

コード品質の改善、リファクタリング、最適化の内容と効果を記録します。

## Instructions

### 1. ヒアリング

- **改善タイトル**: 簡潔な内容の説明
- **背景**: 改善の動機・発見の経緯
- **改善内容**: 具体的に何をしたか / するか
- **効果**: Before / After の比較（可能な限り数値で）
- **ステータス**: 提案 / 実装中 / 完了 / 保留

### 2. 既存記録の確認

`improvement-tracking/references/improvements/README.md` を読み、同じ対象の改善が進行中でないか確認してください。

スキルの配置先は `.agents/skills/` を優先し、`.claude/skills/` / `.cursor/skills/` も検出対象です。

### 3. ファイルの作成

```bash
bash .agents/skills/improvement-tracking/scripts/add-improvement.sh "改善タイトル"
```

`improvements/YYYY-MM-DD-スラッグ.md` が作られ、`improvements/README.md` の索引にも 1 行追加されます。

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

# ステータス
```

### 4. 関連付けと報告

関連する技術判断・実装パターン・デバッグセッションへのリンクを追加してください。最後に作成したファイルのパスを提示します。

## 注意事項

- 効果は可能な限り数値で記録してください（レスポンス時間、コード行数、テストカバレッジなど）
- デバッグセッションから派生した改善は、元のセッションファイルへのリンクを含めてください
- ステータスが変わったら frontmatter の `status` と `updated` を更新してください。ファイル名は変えません
