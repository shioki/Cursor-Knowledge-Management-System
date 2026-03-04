---
name: improvement-tracking
description: コード改善の提案・記録、リファクタリング追跡、技術的負債の管理時に使用。改善活動のPDCAサイクルを支援する。
compatibility: Cursor, Claude Code
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

まず `references/IMPROVEMENTS_TEMPLATE.md` を読み込み、既存の改善記録を確認してください。

### 2. 改善の記録テンプレート

新しい改善を記録する場合は以下の形式で:

```markdown
### YYYY-MM-DD - 改善タイトル

#### 背景
改善の動機・発見の経緯

#### 改善内容
具体的な改善策

#### 効果
- **Before**:
- **After**:
- **改善率**:

#### ステータス
提案 / 実装中 / 完了 / 保留
```

### 3. 改善の追加

改善エントリを追加するには `scripts/add-improvement.sh` を実行できます:

```bash
bash .claude/skills/improvement-tracking/scripts/add-improvement.sh "改善タイトル"
# （.cursor/skills にも対応）
```

### 4. 定期レビュー

以下のサイクルで改善活動をレビューしてください:

- **週次**: 新たな改善提案の確認
- **月次**: 実装済み改善の効果測定
- **四半期**: 技術的負債の棚卸し

定期レビューには `/review-knowledge` コマンドの利用を案内してください。

### 5. コマンドとの連携

改善の記録には `/log-improvement` コマンドの利用を案内してください。
