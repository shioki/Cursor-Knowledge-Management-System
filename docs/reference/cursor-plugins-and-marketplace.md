# Cursor のプラグイン・マーケットプレイス

Cursor はプラグインによって拡張でき、エージェントが外部ツールに接続したり新しい知識を学習したりできるようになっています。このドキュメントでは、プラグインの構成要素と、本システム（Cursor Knowledge Management System）がどの部分をカバーするかを整理します。

## プラグインの構成要素

[Cursor のブログ「プラグインで Cursor を拡張する」](https://cursor.com/ja/blog/marketplace) と [Cursor Plugins 公式ドキュメント](https://cursor.com/ja/docs/plugins) によると、プラグインは次のプリミティブのいずれかまたは複数を組み合わせたものです。

| 要素 | 説明 |
|------|------|
| **Skills** | エージェントが見つけて実行できる、ドメイン固有のプロンプトやコード |
| **Subagents** | Cursor がタスクを並列に完了できるようにする専用エージェント |
| **MCP servers** | Cursor を外部ツールやデータソースに接続するサービス |
| **Hooks** | エージェントの挙動を観察・制御できるカスタムスクリプト |
| **Rules / AGENTS.md** | コーディング規約や設定・好みを遵守させるためのシステムレベルの指示 |
| **Commands** | ユーザー起点のスラッシュコマンドで定型ワークフローを即座に起動 |

## Cursor 3.x で変わったこと

- **`.agents/skills/` 公式ディレクトリ**: プロジェクトレベル、ユーザーグローバルの両方で標準化（従来の `.cursor/skills/` / `.claude/skills/` は互換として維持）
- **`AGENTS.md` のネスト対応**: サブディレクトリに `AGENTS.md` を配置して、そのサブツリーでのみ適用される指示を与えられる
- **Cursor Plugin マニフェスト**: `.cursor-plugin/plugin.json` により Skills / Subagents / MCP / Hooks / Rules / Commands をバンドル配布可能

本システムも v5.0.0 からこれらに対応しています。詳細は [Cursor Plugin 開発ガイド](../advanced/plugin-development.md) を参照してください。

## 本システムがカバーするもの

Cursor Knowledge Management System は、主に次の要素を提供します。

- **Plugin マニフェスト**: [.cursor-plugin/plugin.json](../../.cursor-plugin/plugin.json)（v5.0.0）で Marketplace 配布に対応
- **Skills（7 つ）**: プロジェクト背景、チーム標準、知識管理、パターンライブラリ、デバッグワークフロー、改善追跡、プロジェクトセットアップ。`.agents/skills/` に配置され、Cursor Settings > Rules の「Agent Decides」で参照されます
- **Commands（7 つ）**: `/record-decision`、`/add-pattern`、`/start-debug`、`/log-improvement`、`/review-knowledge`、`/update-context`、`/migrate-from-rules`。`.cursor/commands/` に配置され、チャットで `/` から起動します
- **AGENTS.md テンプレート**: ルート用・ネスト用の両方を同梱（[詳細](../getting-started/agents-md-guide.md)）

本テンプレートは「スキル＋コマンド＋軽量 Rules」による知識管理に特化しており、必要に応じて MCP や他のプラグインと組み合わせて利用できます。

## 本システムで未カバーだが関連するもの

- **MCP**: 日時処理など、エージェントが外部ツールと連携する場合は MCP サーバを利用できます。設定方法は [MCP サーバ日時処理設定ガイド](mcp-datetime-setup.md) を参照してください
- **Subagents・Hooks**: 本テンプレートでは提供していませんが、[Cursor Marketplace](https://cursor.com/ja/blog/marketplace) で提供される他プラグインと組み合わせることで、並列タスク実行や挙動のカスタマイズを補完できます

## Cursor Marketplace でできること

- **プラグインを探してインストールする**: 事前構築されたプラグイン（AWS、Figma、Linear、Stripe など）を Cursor に追加できます
- **独自プラグインを作成して共有する**: Skills、Subagents、MCP、Hooks、Rules を組み合わせたプラグインを投稿し、コミュニティと共有できます

本システムを Marketplace に提出する手順は [Marketplace 提出手順](marketplace-submission.md) を参照してください。

## 配布経路の比較

| 経路 | 対象範囲 | 利用タイミング | 本システムでの対応 |
|------|---------|---------------|-------------------|
| **手動 init.sh** | プロジェクト単位、一括 | 即時、手元リポジトリからコピー | ✅ デフォルト |
| **Cursor Marketplace** | プラグイン単位、Cursor GUI | ユーザーが Cursor から選択 | ✅ [plugin.json](../../.cursor-plugin/plugin.json) 同梱 |
| **gh skill install** | スキル単位、CLI | 個別スキルをピンポイント導入 | ✅ ([詳細](gh-skill-integration.md)) |
| **apm install** | パッケージ単位、依存管理 | 利用側の apm.yml に宣言 | ✅ ([詳細](apm-integration.md)) |

詳細は [Cursor のブログ（プラグインで Cursor を拡張する）](https://cursor.com/ja/blog/marketplace) および Cursor の公式ドキュメントを参照してください。
