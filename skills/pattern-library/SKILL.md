---
name: pattern-library
description: 新機能の実装時に既存パターンの検索・適用、または新しい実装パターンの登録を行う場合に使用。アーキテクチャパターン、実装パターン、テストパターンを管理する。
license: MIT
compatibility: Cursor 3.x, Claude Code, Codex
metadata:
  tags: [patterns, architecture, best-practices]
---

# パターンライブラリ

プロジェクトで使用する実装パターン、設計パターン、テストパターンを管理・適用するスキルです。

## When to Use

- 新機能の実装前に既存パターンを確認したいとき
- 実装方法のベストプラクティスを知りたいとき
- 新しい実装パターンを登録したいとき
- リファクタリング時にパターンの統一を図りたいとき

## Instructions

### 1. 既存パターンの確認

パターンは 1 パターン 1 ファイルで `references/patterns/` に保存されています。

まず `references/patterns/README.md`（索引）を読み、関連しそうなパターンだけを個別に開いてください。索引が存在しない場合や移行中のプロジェクトでは、レガシーな `references/PATTERNS_TEMPLATE.md` にも記録が残っている可能性があります。

### 2. パターンの分類

パターンは以下のカテゴリで管理します:

- **アーキテクチャパターン**: MVC/MVP/MVVM, Repository, Factory, Observer 等
- **実装パターン**: API呼び出し、エラーハンドリング、ログ出力、バリデーション等
- **テストパターン**: 単体テスト、統合テスト、E2Eテスト、モック活用等

### 3. パターンの記録テンプレート

新しいパターンは `references/patterns/スラッグ.md` として作成します。

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

- **制約事項**:
- **パフォーマンス影響**:
- **メンテナンス性**:

# 関連パターン

- **組み合わせ可能**:
- **代替パターン**:
```

ファイルを作成したら、`references/patterns/README.md` の一覧表にも 1 行追加してください。

### 4. パターンの追加

ひな形の生成と索引の更新は `scripts/add-pattern.sh` が行います:

```bash
bash .agents/skills/pattern-library/scripts/add-pattern.sh "パターン名"
# （.claude/skills / .cursor/skills も検出対象）
```

### 5. アクションスキルとの連携

ユーザーがパターンを登録したい場合は、`/add-pattern` の利用を案内してください。

### 6. パターン適用フロー

1. **要件分析**: 実装したい機能の要件を整理
2. **パターン検索**: `references/patterns/README.md` の索引から類似パターンを探す
3. **パターン選択**: 最適なパターンを選択・カスタマイズ
4. **実装・テスト**: パターンに基づいて実装
5. **フィードバック**: パターンの改善点を記録
