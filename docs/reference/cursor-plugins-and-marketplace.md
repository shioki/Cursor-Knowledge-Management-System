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

## 本システムが提供するコンポーネント

v6.1.1 時点で、本プラグインは次のコンポーネントを同梱しています。

| 要素 | 提供 | 実体 |
|------|------|------|
| **Skills** | 13 種 | リポジトリ直下の `skills/`。ドメインスキル 7 種とアクションスキル 6 種 |
| **Subagents** | 1 件 | [`agents/knowledge-curator.md`](../../agents/knowledge-curator.md)。知識ベースの棚卸しを行う読み取り専用エージェント（Cursor のみ） |
| **Hooks** | 3 イベント × 2 系統 | Cursor は [`hooks/hooks.json`](../../hooks/README.md)（`sessionStart` / `afterFileEdit` / `stop`）、Claude Code は `hooks/claude-code/` + `.claude/settings.json`（`SessionStart` / `PostToolUse` / `Stop`） |
| **Rules / AGENTS.md** | テンプレート同梱 | `templates/AGENTS.md.template` と `templates/AGENTS.md.nested-example.md`（[詳細](../getting-started/agents-md-guide.md)） |
| **Commands** | 提供しない | v5 までの 7 コマンドはアクションスキルへ統合されました（後述） |
| **MCP servers** | 提供しない | 日時処理などで必要な場合は [MCP サーバ日時処理設定ガイド](mcp-datetime-setup.md) を参照して個別に設定してください |

### Skills

ドメインスキル 7 種（`project-context`、`team-standards`、`knowledge-management`、`pattern-library`、`debug-workflow`、`improvement-tracking`、`project-setup`）は、エージェントが `description` を読んで必要と判断したときにだけ読み込まれます。

アクションスキル 6 種（`record-decision`、`add-pattern`、`start-debug`、`log-improvement`、`review-knowledge`、`update-context`）は `disable-model-invocation: true` を設定しており、ユーザーが `/record-decision` のように明示的に呼び出したときだけ起動します。v5 までは `.cursor/commands/` の Custom Commands として提供していた機能ですが、Commands は Cursor 固有の仕組みで Claude Code や Codex では使えませんでした。スキルに統合したことで、呼び出し方を変えないまま 3 つのエージェントで共用できるようになっています。詳細は [アクションスキルガイド](../templates/action-skills-guide.md) を参照してください。

なお `/migrate-from-rules` は v6 で廃止しました。Cursor に組み込みの `/migrate-to-skills` と役割が重複するためです。

### Subagents と Hooks

Subagents と Hooks は v5 では未提供でしたが、v6 で追加しました。使い方はそれぞれ [Subagents ガイド](../advanced/subagents-guide.md)、[Hooks ガイド](../advanced/hooks-guide.md) を参照してください。

hooks はエージェントのライフサイクルに介入する仕組みである以上、常時オンが望ましいとは限りません。`sessionStart`（知識の索引を注入）と `afterFileEdit`（編集ファイルをログに追記）は副作用が小さいため既定で有効ですが、`stop`（記録漏れの提案）は `followup_message` によって 1 ターンを追加消費するため、設定ファイルで明示的に有効化しない限り何もせずに終了します。

## plugin.json の構造

[.cursor-plugin/plugin.json](../../.cursor-plugin/plugin.json) は、Cursor 公式のプラグインスキーマに準拠したメタデータだけを持ちます。

```json
{
  "$schema": "https://cursor.com/schemas/cursor-plugin/plugin.json",
  "name": "cursor-knowledge-management-system",
  "displayName": "Cursor Knowledge Management System",
  "description": "...",
  "version": "6.1.1",
  "author": { "name": "shioki" },
  "license": "MIT",
  "homepage": "https://github.com/shioki/Cursor-Knowledge-Management-System",
  "repository": "https://github.com/shioki/Cursor-Knowledge-Management-System",
  "category": "productivity",
  "keywords": ["knowledge-management", "skills", "..."]
}
```

コンポーネントの場所を書いていないのは意図的です。マニフェストで明示しない場合、Cursor はプラグインルート直下の `skills/`、`agents/`、`commands/`、`rules/`、`hooks/hooks.json` を探索します。本リポジトリはこの既定の配置に合わせてあるため、パスを列挙する必要がありません。

v5 のマニフェストは `paths.skills` / `paths.commands` / `compatibility` といった独自キーを持ち、`repository` をオブジェクトで書いていました。公式スキーマは `additionalProperties: false` のため、これらは Cursor 側で拒否されます。v6 ではスキーマを [`schemas/cursor-plugin.schema.json`](../../schemas/cursor-plugin.schema.json) にベンダリングし、`npm run plugin:check` が ajv で厳密に検証します。同じ検証で、スキーマは通るのにコンポーネントが 1 件も見つからない状態も検出します。

## Cursor Marketplace でできること

- **プラグインを探してインストールする**: 事前構築されたプラグイン（AWS、Figma、Linear、Stripe など）を Cursor に追加できます
- **独自プラグインを作成して共有する**: Skills、Subagents、MCP、Hooks、Rules を組み合わせたプラグインを投稿し、コミュニティと共有できます

本システムを Marketplace に提出する手順は [Marketplace 提出手順](marketplace-submission.md) を参照してください。ローカルでの動作確認は [Cursor Plugin 開発ガイド](../advanced/plugin-development.md) にまとめています。

## 配布経路の比較

v6 でリポジトリ直下の非隠しディレクトリに配布物を集約したのは、この 4 経路が同じ配置をそのまま読めるようにするためです。とくに `gh skill install` は `--allow-hidden-dirs` を付けない限り隠しディレクトリ配下のスキルを検出しないため、v5 の `templates/.agents/skills/` は不利な配置でした。

| 経路 | 対象範囲 | 利用タイミング | 参照元 |
|------|---------|---------------|-------|
| **init.sh** | プロジェクト単位、一括 | 即時、手元リポジトリからコピー | `skills/project-setup/scripts/init.sh` |
| **Cursor Marketplace** | プラグイン単位、Cursor GUI | ユーザーが Cursor から選択 | [plugin.json](../../.cursor-plugin/plugin.json) のデフォルト探索 |
| **gh skill install** | スキル単位、CLI | 個別スキルをピンポイント導入 | ルートの `skills/`（[詳細](gh-skill-integration.md)） |
| **apm install** | パッケージ単位、依存管理 | 利用側の apm.yml に宣言 | [apm.yml](../../apm.yml) の `paths`（[詳細](apm-integration.md)） |

詳細は [Cursor のブログ（プラグインで Cursor を拡張する）](https://cursor.com/ja/blog/marketplace) および Cursor の公式ドキュメントを参照してください。
