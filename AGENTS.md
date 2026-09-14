# AGENTS.md

Cursor Knowledge Management System（CKMS）そのもののリポジトリです。ここで開発するのは、他のプロジェクトに配布される Agent Skills・subagent・hooks の集合です。

## このリポジトリの構造

配布物はすべてリポジトリ直下の非隠しディレクトリに置きます。Cursor Plugin のデフォルト探索、`gh skill install`、`apm install` のいずれもこの配置をそのまま読めます。

| ディレクトリ | 内容 |
|-------------|------|
| `skills/` | Agent Skills 13 種（唯一の正） |
| `agents/` | subagent 定義 |
| `hooks/` | `hooks.json` と hook スクリプト（Cursor 用）、`hooks/claude-code/` に Claude Code 用 |
| `.cursor-plugin/` | プラグインマニフェスト |
| `templates/` | `AGENTS.md` テンプレートと `.cursorignore` |
| `scripts/` | CI 検証・リリース用スクリプト |
| `docs/` | ドキュメント |
| `CLAUDE.md` | `@AGENTS.md` の import のみ。本文を複製しない |
| `.claude/skills` | `skills/` へのシンボリックリンク。Claude Code はこのパスしか探索しないため橋渡しする |

## 守ること

### 配布物を複製しない

`skills/` の内容を `templates/` などに複製しないでください。v5 では `templates/.agents/skills/` と `templates/.cursor/skills/` の二重管理により、7 つの `SKILL.md` すべてが drift しました。`npm run skills:check` がこの再発を検出します。

同じ理由で、`.claude/skills` は `skills/` のシンボリックリンクとして扱い、複製しないでください（`init.sh` の配布先でも同様。シンボリックリンクが張れない環境のみ、警告を出した上でコピーにフォールバックします）。

### スキルの規約

- ドメインスキル（自動選択）: `description` に「どんなときに使うか」を書く。エージェントはこれだけを見て読み込みを判断します
- アクションスキル（明示起動）: `disable-model-invocation: true` を必ず設定する
- `name` はフォルダ名と一致させ、kebab-case にする
- frontmatter の最上位キーは Agent Skills 仕様のものだけを使う（仕様外キーは無視されます）

### 知識層の規約

技術判断・パターン・改善記録は 1 概念 1 ファイルです。単一の大きなファイルに追記していく方式には戻さないでください。オンデマンド読み込みでトークンを節約するという設計の前提が崩れます。

利用者向けの配置（配布テンプレート）:

- 技術判断: `skills/knowledge-management/references/decisions/YYYY-MM-DD-スラッグ.md`
- パターン: `skills/pattern-library/references/patterns/スラッグ.md`
- 改善: `skills/improvement-tracking/references/improvements/YYYY-MM-DD-スラッグ.md`

**このリポジトリ自身の開発記録**は `skills/*/references/` に書かず、dogfooding 用の `.agents/skills/*/references/` に置きます（`.gitignore` 済み）。`skills/` 配下は配布物なので、CKMS 内部の ADR を混ぜると利用者のプロジェクトに混入します。手順は `docs/advanced/plugin-development.md` の dogfooding を参照。

各ディレクトリの `README.md` が索引です。ファイルを追加したら索引にも 1 行追加します。

### スクリプトの制約

hook スクリプトと知識管理スクリプトは、`jq` / `python` / `node` に依存させないでください。利用者の環境にあるとは限りません。POSIX シェルと `sed` / `awk` / `find` の範囲で書きます。

ユーザー入力を YAML frontmatter や Markdown 表へ埋め込むときは、必ず `_skill-base.sh` の `ckms_yaml_escape` / `ckms_table_escape`（または同等の処理）を通してください。`awk -v` はバックスラッシュを解釈するため、`\|` を含む行の受け渡しには `ENVIRON` を使います。

`*.sh` には実行権限を付けてコミットしてください。CI が検証します。

## 変更したら確認すること

```bash
npm run docs:check
```

`skills:check`（Agent Skills 仕様準拠・複製ガード）、`components:check`（hooks / subagents）、`plugin:check`（公式スキーマを ajv で検証）、`links:check`（リンク切れ）が順に走ります。

セットアップ経路に触れた場合は、実際に導入できることも確認してください。

```bash
mkdir -p /tmp/ckms-check
bash skills/project-setup/scripts/init.sh /tmp/ckms-check --yes
(cd /tmp/ckms-check && bash .agents/skills/project-setup/scripts/validate.sh)
```

## ドキュメントの版数

バージョンを上げるときは以下を揃えてください。ずれていると利用者が古い手順を実行します。

- `.cursor-plugin/plugin.json` の `version`
- `apm.yml` の `version`
- `README.md` の冒頭とフッター
- `CHANGELOG.md`
- `skills/project-setup/scripts/init.sh` / `init.ps1` / `validate.sh` の表示文字列

`scripts/release.sh` が `plugin.json` と `apm.yml` の不一致を検出しますが、それ以外は自動検証されません。

## このリポジトリで CKMS 自身を使う

開発時に自分のスキルを動かして確認する手順は `docs/advanced/plugin-development.md` の「dogfooding」を参照してください。
