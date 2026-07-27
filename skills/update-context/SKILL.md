---
name: update-context
description: プロジェクトの技術スタック・アーキテクチャ・制約などのコンテキスト情報を更新する。ユーザーが /update-context と明示的に入力したときだけ起動する。
disable-model-invocation: true
license: MIT
compatibility: Cursor 3.x, Claude Code, Codex
metadata:
  tags: [context, architecture, action]
---

# コンテキスト更新

プロジェクトの前提情報を最新の状態に保ちます。ここが古いと、他のすべてのスキルの提案精度が落ちます。

## Instructions

### 1. 現状の確認

`project-context/references/CONTEXT_TEMPLATE.md` を読み、現在の記録内容を把握してください。スキルの配置先は `.agents/skills/` を優先し、`.claude/skills/` / `.cursor/skills/` も検出対象です。

### 2. 変更点のヒアリング

- **技術スタック**: ライブラリ・フレームワークの採用やバージョンアップ
- **アーキテクチャ**: システム構成の変更、サービスの追加
- **制約**: パフォーマンス要件、セキュリティ要件の変更
- **チーム体制**: メンバーの増減、役割変更
- **開発フロー**: ブランチ戦略、デプロイフローの変更

可能であれば `package.json` や `pyproject.toml` などの依存定義を読み、記録との差分を自分で見つけてから確認してください。

### 3. 差分の提示と更新

更新内容のプレビューを差分として提示し、ユーザーの確認後にファイルを更新してください。

### 4. 波及の確認

大きな変更があった場合は次も推奨してください。

- `/record-decision` で変更の判断理由を記録
- `team-standards` スキルの規約に影響がないか確認
- 影響を受けるパターンの更新が必要ないか確認

## 注意事項

- 更新前に必ず現在の内容を確認し、差分を提示してください
- 大きな方針転換の場合は `/record-decision` での記録を強く推奨してください
- チーム共有が必要な変更は、変更内容のサマリーを提示してください
