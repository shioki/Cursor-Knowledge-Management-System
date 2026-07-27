---
name: review-knowledge
description: 蓄積した知識ベースを棚卸しし、陳腐化・矛盾・重複・リンク切れを検出して更新方針を提案する。ユーザーが /review-knowledge と明示的に入力したときだけ起動する。
disable-model-invocation: true
license: MIT
compatibility: Cursor 3.x, Claude Code, Codex
metadata:
  tags: [review, maintenance, knowledge, action]
---

# 知識ベースレビュー

蓄積した知識を棚卸しし、陳腐化した情報の更新やアーカイブを行います。

## Instructions

### 1. 走査は knowledge-curator サブエージェントに委譲する

知識ベース全体の読み込みは出力が大きく、メインの会話コンテキストを圧迫します。`knowledge-curator` サブエージェントに委譲してください。

```text
knowledge-curator サブエージェントで知識ベースを棚卸しして
```

このサブエージェントは読み取り専用で動作し、走査結果のレポートだけを返します。利用できない環境（サブエージェント非対応のエージェント）では、次のファイル群を自分で読んでください。

- `knowledge-management/references/decisions/` と `KNOWLEDGE_TEMPLATE.md`
- `pattern-library/references/patterns/` と `PATTERNS_TEMPLATE.md`
- `improvement-tracking/references/improvements/` と `IMPROVEMENTS_TEMPLATE.md`
- `project-context/references/CONTEXT_TEMPLATE.md`
- ベースディレクトリ配下の `debug-sessions/`

スキルの配置先は `.agents/skills/` を優先し、`.claude/skills/` / `.cursor/skills/` も検出対象です。

### 2. 記録漏れの確認

hooks を有効にしている場合、`.agents/knowledge-activity.log` に直近の編集ファイルが記録されています。このログに頻出するモジュールで、対応する技術判断やパターンが残っていないものは記録漏れの候補です。

### 3. レビュー結果の報告

サブエージェントのレポートを受け取ったら、ユーザーが判断できる形に整理して提示してください。

```markdown
## レビュー結果サマリー

### 更新推奨
- [ファイル]: 理由

### アーカイブ推奨
- [ファイル]: 理由

### 記録漏れの候補
- [対象]: 内容

### 矛盾・重複
- [ファイル A] vs [ファイル B]: 内容

### リンク切れ
- [ファイル]: 参照先
```

### 4. 更新の実施

ユーザーが合意した項目だけを実施してください。全部まとめてではなく、影響の大きいものから順に確認を取ります。

## レビュー頻度の推奨

- **週次**: 新たな記録の確認、ステータス更新
- **月次**: パターンと改善の効果測定、陳腐化チェック
- **四半期**: 全体の棚卸し、アーキテクチャ決定の振り返り

## 注意事項

- 削除ではなくアーカイブを推奨してください（判断の履歴自体に価値があります）
- 大きな更新の前には必ずユーザーの確認を取ってください
- コンテキスト情報の更新が必要な場合は `/update-context` を案内してください
