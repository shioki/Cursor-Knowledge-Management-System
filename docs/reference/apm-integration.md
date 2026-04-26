# APM (Agent Package Manager) 連携

[Microsoft APM](https://github.com/microsoft/apm) は、AI エージェント向けの依存関係マネージャーです。npm や pip の `package.json` / `requirements.txt` のように、プロジェクトが必要とするスキル・コマンド・ルール・MCP を `apm.yml` で宣言し、`apm install` で一括取得できます。

本リポジトリは **APM パッケージとして公開可能** な構成になっており、他プロジェクトから `apm install` で取り込めます。

## APM のインストール

```bash
# Linux / macOS
curl -sSL https://aka.ms/apm-unix | sh

# Windows (PowerShell)
irm https://aka.ms/apm-windows | iex
```

詳細は [APM 公式リポジトリ](https://github.com/microsoft/apm) を参照。

## 本パッケージの利用例

### 1. パッケージ全体を取り込む

利用側プロジェクトの `apm.yml` に以下を追記します:

```yaml
name: your-project
version: 1.0.0
dependencies:
  apm:
    - shioki/Cursor-Knowledge-Management-System#v5.0.1
```

```bash
apm install
```

これにより、本パッケージの `templates/.agents/skills/` 配下 7 種のスキルと `templates/.cursor/commands/` 配下 7 種のコマンドが、利用側プロジェクトに導入されます。

### 2. 個別スキルだけを取り込む

必要なスキルだけを選択的にインストールすることもできます:

```yaml
dependencies:
  apm:
    - shioki/Cursor-Knowledge-Management-System/templates/.agents/skills/knowledge-management#v5.0.1
    - shioki/Cursor-Knowledge-Management-System/templates/.agents/skills/debug-workflow#v5.0.1
```

### 3. タグ / コミット SHA での固定

再現性確保のために、特定のタグまたは SHA に固定できます:

```yaml
dependencies:
  apm:
    # タグ指定
    - shioki/Cursor-Knowledge-Management-System#v5.0.1
    # SHA 指定（最も厳密）
    - shioki/Cursor-Knowledge-Management-System#abc123def
```

## セキュリティスキャン

APM は標準で隠し Unicode 検出や汚染パッケージの検出を行います。本パッケージを install する前に `apm audit` を実行することを推奨します:

```bash
apm audit
```

## 本パッケージを APM 公開する際の運用

### リリースフロー

1. `apm.yml` の `version` を更新
2. `[.cursor-plugin/plugin.json](../../.cursor-plugin/plugin.json)` の `version` を揃える
3. `CHANGELOG.md` にエントリを追加
4. `npm run release -- v5.0.1` でタグと GitHub Release を作成（immutable release 推奨）

### immutable release の有効化

GitHub リポジトリの **Settings → Rules → Releases → Require immutable** を有効化すると、公開後のリリース内容を改竄できなくなり、APM / gh skill 両方での供給網保全に寄与します。

## 関連ドキュメント

- [APM – Agent Package Manager](https://github.com/microsoft/apm)
- [APM Getting Started](https://microsoft.github.io/apm/)
- [APM ドキュメント（Getting Started ・ apm.yml 例）](https://microsoft.github.io/apm/)
