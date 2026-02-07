# 知識ベースレビュー

蓄積した知識ベースを棚卸しし、陳腐化した情報の更新やアーカイブを行います。

## 手順

1. 以下のファイルをすべて読み込んでください:
   - `.cursor/skills/knowledge-management/references/KNOWLEDGE_TEMPLATE.md`
   - `.cursor/skills/pattern-library/references/PATTERNS_TEMPLATE.md`
   - `.cursor/skills/improvement-tracking/references/IMPROVEMENTS_TEMPLATE.md`
   - `.cursor/skills/debug-workflow/references/DEBUG_TEMPLATE.md`
   - `.cursor/skills/project-context/references/CONTEXT_TEMPLATE.md`

2. 各ファイルについて以下の観点でレビューしてください:
   - **陳腐化**: 現在の技術スタックや方針と合わなくなった記録
   - **矛盾**: ファイル間で矛盾する情報
   - **不足**: 記録されるべきだが欠けている情報
   - **重複**: 複数箇所に同じ情報がある

3. レビュー結果をユーザーに報告してください:

```markdown
## レビュー結果サマリー

### 更新推奨
- [ファイル名] [セクション]: 理由

### アーカイブ推奨
- [ファイル名] [セクション]: 理由

### 不足している情報
- [カテゴリ]: 内容

### 矛盾の検出
- [ファイルA] vs [ファイルB]: 内容
```

4. ユーザーの確認後、合意した更新を実施してください。

## レビュー頻度の推奨

- **週次**: 新たな記録の確認、ステータス更新
- **月次**: パターンと改善の効果測定、陳腐化チェック
- **四半期**: 全体の棚卸し、アーキテクチャ決定の振り返り

## 注意事項

- 削除ではなくアーカイブを推奨してください（履歴として価値があります）
- 大きな更新を行う前にユーザーの確認を取ってください
- コンテキスト情報の更新が必要な場合は `/update-context` コマンドを案内してください
