# APM (Agent Package Manager) 連携

[Microsoft APM](https://github.com/microsoft/apm) は、AI エージェント向けの依存関係マネージャーです。npm や pip の `package.json` / `requirements.txt` のように、プロジェクトが必要とするスキル・subagent・hooks・MCP を `apm.yml` で宣言し、`apm install` で一括取得できます。

本リポジトリは **APM パッケージとして公開可能** な構成になっており、他プロジェクトから `apm install` で取り込めます。

## APM のインストール

```bash
# Linux / macOS
curl -sSL https://aka.ms/apm-unix | sh

# Windows (PowerShell)
irm https://aka.ms/apm-windows | iex
```

詳細は [APM 公式リポジトリ](https://github.com/microsoft/apm) を参照。

## 本パッケージが提供するもの

[apm.yml](../../apm.yml) の `paths` は、リポジトリ直下の 3 つのディレクトリを指しています。

```yaml
name: cursor-knowledge-management-system
version: 6.0.0
paths:
  skills: skills
  agents: agents
  hooks: hooks
```

v5 では `commands` も宣言していましたが、7 つのスラッシュコマンドのうち 6 つは v6 でアクションスキルへ統合され、残る `/migrate-from-rules` は廃止されました。そのため commands のエントリは無くなり、代わりに subagent と hooks が加わっています。

パスがすべて非隠しディレクトリなのは意図的です。Cursor Plugin のデフォルト探索、`gh skill` の探索（`--allow-hidden-dirs` 不要）、APM の三者が同じ配置をそのまま読めるようにしてあります。

## 本パッケージの利用例

### 1. パッケージ全体を取り込む

利用側プロジェクトの `apm.yml` に以下を追記します:

```yaml
name: your-project
version: 1.0.0
dependencies:
  apm:
    - shioki/Cursor-Knowledge-Management-System#v6.0.0
```

```bash
apm install
```

これにより、13 種のスキル、知識キュレーター subagent、記録支援 hooks が利用側プロジェクトに導入されます。

### 2. 個別スキルだけを取り込む

必要なスキルだけを選択的にインストールすることもできます:

```yaml
dependencies:
  apm:
    - shioki/Cursor-Knowledge-Management-System/skills/knowledge-management#v6.0.0
    - shioki/Cursor-Knowledge-Management-System/skills/debug-workflow#v6.0.0
```

`/record-decision` などのアクションスキルも同じ書き方で個別に取り込めます（`skills/record-decision` など）。記録先ディレクトリを共有するため、対応するドメインスキルと合わせて指定してください。

### 3. タグ / コミット SHA での固定

再現性確保のために、特定のタグまたは SHA に固定できます:

```yaml
dependencies:
  apm:
    # タグ指定
    - shioki/Cursor-Knowledge-Management-System#v6.0.0
    # SHA 指定（最も厳密）
    - shioki/Cursor-Knowledge-Management-System#abc123def
```

## セキュリティスキャン

APM は標準で隠し Unicode 検出や汚染パッケージの検出を行います。本パッケージを install する前に `apm audit` を実行することを推奨します:

```bash
apm audit
```

hooks を同梱している以上、導入側は実行されるスクリプトの中身を確認できたほうが安全です。本パッケージの hook スクリプトは `jq` / `python` / `node` に依存せず、POSIX シェルと `sed` / `awk` / `find` だけで書かれているため、短時間で読み通せます。既定の挙動と無効化の方法は [hooks/README.md](../../hooks/README.md) にまとめています。

## 本パッケージを APM 公開する際の運用

### リリースフロー

1. `apm.yml` の `version` を更新
2. [`.cursor-plugin/plugin.json`](../../.cursor-plugin/plugin.json) の `version` を揃える
3. `CHANGELOG.md` にエントリを追加
4. `npm run docs:check` で構造とリンクを検証
5. `npm run release -- v6.0.0` でタグと GitHub Release を作成（immutable release 推奨）

両マニフェストのバージョン不一致は `npm run plugin:check` と `scripts/release.sh` の双方が検出するため、片方だけ上げた状態でリリースすることはできません。

### immutable release の有効化

GitHub リポジトリの **Settings → General → Releases → Enable release immutability** を有効化すると、公開後のリリース内容を改竄できなくなり、APM / gh skill 両方での供給網保全に寄与します。

## 関連ドキュメント

- [APM – Agent Package Manager](https://github.com/microsoft/apm)
- [APM Getting Started](https://microsoft.github.io/apm/)
- [gh skill 連携](gh-skill-integration.md)
