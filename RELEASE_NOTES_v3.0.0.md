## 🎉 概要
Cursor AI の最新機能である「Agent Skills」と「Custom Commands」へ全面的に移行したメジャーアップデートです。
従来の `.cursor/rules` (MDC) 方式から、より効率的で自動化に適した 3層構造（Commands -> Skills -> Data Layer）へ進化しました。

## ✨ 主な変更点
- **Agent Skills への完全移行**: 7つのコアスキルを導入し、エージェントが文脈に応じて必要な知識のみを選択的にロードする仕組みを構築
- **Custom Commands 搭載**: `/record-decision` や `/migrate-from-rules` など、ユーザーが即座に起動できる 7つのワークフローを追加
- **トークンとコストの削減**: `references/` によるオンデマンド読込により、リクエストごとのベースラインを 60-80% 削減
- **移行支援ツールの提供**: v2.x からスムーズに移行するためのガイド、自動スクリプト、および対話型コマンドを同梱
- **新デザインの README**: 概要インフォグラフィックを追加し、システムの全体像を可視化

## 💥 破壊的変更
- `.cursor/rules/` ディレクトリを廃止しました。
- 従来の monolithic な知識ファイル（knowledge.md 等）を廃止し、スキルごとの `references/` ディレクトリへ再配置しました。

詳細は [v2.x からの移行ガイド](https://github.com/shioki/Cursor-Knowledge-Management-System/blob/main/docs/getting-started/migration-from-rules.md) を参照してください。
