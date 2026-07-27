---
name: record-decision
description: 技術判断・設計決定を 1 判断 1 ファイルの ADR として記録する。ユーザーが /record-decision と明示的に入力したときだけ起動する。
disable-model-invocation: true
license: MIT
compatibility: Cursor 3.x, Claude Code, Codex
metadata:
  tags: [knowledge, adr, decision-log, action]
---

# 技術判断を記録

技術的な判断・設計決定を、検索しやすい 1 ファイル 1 判断の形式で記録します。

## Instructions

### 1. ヒアリング

ユーザーから次の情報を集めてください。すでに会話の中で判明している項目は聞き直さず、確認だけで済ませます。

- **判断内容**: 何を決定したか
- **検討した選択肢**: 比較した候補とそれぞれのメリット・デメリット
- **決定と理由**: 最終的な選択とその根拠
- **影響範囲**: この決定が影響するコンポーネントや機能

### 2. 既存記録の確認

`knowledge-management/references/decisions/README.md` を読み、同じテーマの判断が既にないか確認してください。既存判断を覆す決定であれば、その旨を新しいファイルに明記し、古い方にも追記します。

スキルの配置先は `.agents/skills/` を優先し、`.claude/skills/` / `.cursor/skills/` も検出対象です。

### 3. ファイルの作成

スクリプトでひな形を生成できます。

```bash
bash .agents/skills/knowledge-management/scripts/add-entry.sh "判断タイトル"
```

`decisions/YYYY-MM-DD-スラッグ.md` が作られ、`decisions/README.md` の索引にも 1 行追加されます。生成されたファイルを、ヒアリング内容で埋めてください。

スクリプトを使わない場合も、同じ命名規則とフォーマットに従ってください。

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

### 4. 関連付けと報告

関連する実装パターンや過去の判断があれば、Markdown リンクで相互に接続してください。最後に記録内容のサマリーと作成したファイルのパスを提示します。

## 注意事項

- 判断の背景と理由を必ず含めてください（将来の参照時にいちばん価値がある部分です）
- 不採用にした選択肢も理由とともに残してください
- 日付は記録日の実際の日付を使ってください。不確かな場合は `date +%Y-%m-%d` で確認します
- レガシーな `KNOWLEDGE_TEMPLATE.md` への追記も引き続き読み取れますが、新規記録は個別ファイルに作成してください
