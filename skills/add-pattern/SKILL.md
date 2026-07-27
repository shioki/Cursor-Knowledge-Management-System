---
name: add-pattern
description: 実装パターンをパターンライブラリに 1 パターン 1 ファイルで登録する。ユーザーが /add-pattern と明示的に入力したときだけ起動する。
disable-model-invocation: true
license: MIT
compatibility: Cursor 3.x, Claude Code, Codex
metadata:
  tags: [patterns, architecture, action]
---

# パターンを登録

再利用したい実装パターンをパターンライブラリに登録します。

## Instructions

### 1. ヒアリング

- **パターン名**: 具体的で検索しやすい名前
- **目的**: 解決する問題、適用場面、期待効果
- **実装例**: 動作する具体的なコード
- **注意事項**: 制約、パフォーマンス影響、メンテナンス性

### 2. 重複の確認

`pattern-library/references/patterns/README.md` を読み、類似パターンが既にないか確認してください。似たものがあれば、新規登録ではなく既存パターンへの追記・統合を提案します。

スキルの配置先は `.agents/skills/` を優先し、`.claude/skills/` / `.cursor/skills/` も検出対象です。

### 3. ファイルの作成

```bash
bash .agents/skills/pattern-library/scripts/add-pattern.sh "パターン名"
```

`patterns/スラッグ.md` が作られ、`patterns/README.md` の索引にも 1 行追加されます。生成されたファイルをヒアリング内容で埋めてください。

```markdown
---
title: パターン名
description: 1 行サマリ
tags: [pattern]
updated: YYYY-MM-DD
---

# 目的

# 実装例

# 使用上の注意

# 関連パターン
```

### 4. 関連付けと報告

組み合わせ可能なパターン、代替パターン、根拠となった技術判断へのリンクを追加してください。最後に作成したファイルのパスを提示します。

## 注意事項

- 実装例は擬似コードではなく、動作する具体的なコードを含めてください
- 適用場面を明確にし、過剰な一般化を避けてください
- 類似パターンが既にある場合は、新規作成より統合を優先してください
