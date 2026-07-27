---
name: start-debug
description: デバッグセッションを開始し、調査経過を記録するファイルを作成する。ユーザーが /start-debug と明示的に入力したときだけ起動する。
disable-model-invocation: true
license: MIT
compatibility: Cursor 3.x, Claude Code, Codex
metadata:
  tags: [debug, troubleshooting, action]
---

# デバッグセッション開始

問題の調査を開始し、経過と結論を残せるセッションファイルを作成します。

## Instructions

### 1. ヒアリング

- **問題の概要**: 何が起きているか
- **環境**: 開発 / ステージング / 本番
- **再現手順**: どうすれば再現できるか
- **エラーメッセージ**: 表示されているエラー（あれば）
- **期待動作**: 本来どう動くべきか
- **緊急度**: 高 / 中 / 低

### 2. 過去事例の検索

同じ問題を過去に解いていないか確認してください。

```bash
bash .agents/skills/debug-workflow/scripts/search-sessions.sh "キーワード"
```

スキルの配置先は `.agents/skills/` を優先し、`.claude/skills/` / `.cursor/skills/` も検出対象です。セッションの保存先は検出されたベースディレクトリ配下の `debug-sessions/` です。

### 3. セッションファイルの作成

```bash
bash .agents/skills/debug-workflow/scripts/create-session.sh "問題の概要"
```

`debug-sessions/YYYY-MM-DD_スラッグ.md` が作られます。ヒアリングした基本情報と症状を埋めてください。

### 4. 調査

複数の仮説を立て、確認コストの低いものから検証します。検証の過程は都度セッションファイルの「調査ログ」に追記してください。後から同じ問題に当たった人が辿れることが目的です。

### 5. 解決後

根本原因・修正内容・テスト結果・再発防止策をセッションファイルに記入してから、`/log-improvement` で再発防止策を改善記録として残すよう案内してください。

## 注意事項

- 調査の各ステップを記録してください（結論だけ残すと類似問題の参考になりません）
- 緊急度が高い場合は暫定対応を優先し、根本原因の記録は復旧後に行ってください
- 症状ではなく根本原因を必ず記録してください
