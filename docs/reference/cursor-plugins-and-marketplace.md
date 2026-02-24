# Cursor のプラグイン・マーケットプレイス

Cursor はプラグインによって拡張でき、エージェントが外部ツールに接続したり新しい知識を学習したりできるようになっています。このドキュメントでは、プラグインの構成要素と、本システム（Cursor Knowledge Management System）がどの部分をカバーするかを整理します。

## プラグインの構成要素

[Cursor のブログ「プラグインで Cursor を拡張する」](https://cursor.com/ja/blog/marketplace) によると、プラグインは次のプリミティブのいずれかまたは複数を組み合わせたものです。

| 要素 | 説明 |
|------|------|
| **Skills** | エージェントが見つけて実行できる、ドメイン固有のプロンプトやコード |
| **Subagents** | Cursor がタスクを並列に完了できるようにする専用エージェント |
| **MCP servers** | Cursor を外部ツールやデータソースに接続するサービス |
| **Hooks** | エージェントの挙動を観察・制御できるカスタムスクリプト |
| **Rules** | コーディング規約や設定・好みを遵守させるためのシステムレベルの指示 |

## 本システムがカバーするもの

Cursor Knowledge Management System は、主に次の要素を提供します。

- **Skills（7 つ）**: プロジェクト背景、チーム標準、知識管理、パターンライブラリ、デバッグワークフロー、改善追跡、プロジェクトセットアップ。これらは `.cursor/skills/` に配置され、Cursor Settings > Rules の「Agent Decides」で参照されます。
- **Commands（7 つ）**: `/record-decision`、`/add-pattern`、`/start-debug`、`/log-improvement`、`/review-knowledge`、`/update-context`、`/migrate-from-rules`。`.cursor/commands/` に配置され、チャットで `/` から起動します。

本テンプレートは「スキル＋コマンド」による知識管理に特化しており、必要に応じて MCP や他のプラグインと組み合わせて利用できます。

## 本システムで未カバーだが関連するもの

- **MCP**: 日時処理など、エージェントが外部ツールと連携する場合は MCP サーバを利用できます。設定方法は [MCP サーバ日時処理設定ガイド](mcp-datetime-setup.md) を参照してください。
- **Subagents・Hooks**: 本テンプレートでは提供していませんが、[Cursor Marketplace](https://cursor.com/ja/blog/marketplace) で提供される他プラグインと組み合わせることで、並列タスク実行や挙動のカスタマイズを補完できます。

## Cursor Marketplace でできること

- **プラグインを探してインストールする**: 事前構築されたプラグイン（AWS、Figma、Linear、Stripe など）を Cursor に追加できます。
- **独自プラグインを作成して共有する**: Skills、Subagents、MCP、Hooks、Rules を組み合わせたプラグインを投稿し、コミュニティと共有できます。

詳細は [Cursor のブログ（プラグインで Cursor を拡張する）](https://cursor.com/ja/blog/marketplace) および Cursor の公式ドキュメントを参照してください。
