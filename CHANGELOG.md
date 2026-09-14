# Changelog

このプロジェクトの重要な変更履歴を記録します。

## [Unreleased]

### Added

- **Claude Code ネイティブ対応**: `.agents/skills` を Claude Code が標準では探索しない問題を修正するため、`init.sh` / `init.ps1` が `.claude/skills` へのシンボリックリンク（またはフォールバックのコピー）を自動作成するようにした（`--no-claude-bridge` で無効化可）
- **CLAUDE.md の自動生成**: `--with-agents-md` 指定時、`@AGENTS.md` を import するだけの `CLAUDE.md` も作成するようにした（Claude Code は AGENTS.md を自動では読まないため）
- **Claude Code 版 hooks**: `hooks/claude-code/`（`session-start.sh` / `post-tool-use-log-activity.sh` / `stop-suggest-record.sh`）と `templates/.claude/settings.json.template` を追加。Cursor 版と同じ挙動を `.claude/settings.json` のスキーマ（`SessionStart` / `PostToolUse` / `Stop`）で提供する
- **知識索引ロジックの共通化**: `hooks/_hook-lib.sh` に `ckms_build_knowledge_index` を追加し、Cursor 版・Claude Code 版の sessionStart hook が共通ロジックを使うようにした

### Changed

- **並行利用ガイド**: Cursor と Claude Code で調査と実装を分けるときの引き継ぎ形式（再現・対象・方針・テスト・完了報告）を追記

### Fixed

- **CKMS 自身の Claude Code 対応**: リポジトリ直下に `CLAUDE.md`（`@AGENTS.md` を import）と `.claude/skills`（`skills/` へのシンボリックリンク）を追加し、このリポジトリ自体を Claude Code から開いたときに AGENTS.md とスキルが読み込まれるようにした
- **ドキュメントの是正**: 「`.agents/skills/` に置けば Claude Code からも自動で読み込まれる」という不正確な説明を、実際の橋渡しの仕組み（シンボリックリンク、CLAUDE.md import）に基づく説明へ修正（README、各種ガイド、`apm.yml`、`.cursor-plugin/plugin.json`、`apm-integration.md`、`gh-skill-integration.md`）
- **記録スクリプトのタイトルエスケープ**: `|` / `:` / `"` / 改行を含むタイトルで YAML frontmatter と索引 `README.md` の表が壊れていた。`_skill-base.sh` に `ckms_yaml_escape` / `ckms_table_escape` を追加し、`add-entry.sh` / `add-pattern.sh` / `add-improvement.sh` と `ckms_index_upsert` で適用する
- **スラッグ化の改行混入**: タイトル内の改行が `sed` の行分割でファイル名に残る問題を、`ckms_slugify` で改行を先に畳むことで修正
- **`ckms_read_title`**: ダブルクォートで囲まれた `title` の `\"` / `\\` を復元するよう更新
- **CI**: setup-smoke-test に特殊文字タイトルの回帰チェックを追加
- **Windows での symlink checkout 破損**: `hooks/claude-code/_hook-lib.sh` を symlink で実装していたため、git の symlink サポートが無効な Windows checkout だと壊れたプレースホルダーファイルになり hooks が静かに壊れていた。symlink をやめ、`hooks/_hook-lib.sh` の実体コピー + `hooks/claude-code/` のディレクトリ構造をそのまま配置する方式に変更（`.claude/hooks/_hook-lib.sh` + `.claude/hooks/claude-code/*.sh`）
- **索引 README 更新のレースコンディション**: `ckms_index_upsert`（`add-entry.sh` 等が使用）が read-modify-write にロックを取っておらず、Cursor と Claude Code の並行利用で同時に索引を更新すると記録が失われることがあった（40件中2件の欠損を実証）。`ckms_with_lock`（mkdir ベースの排他制御）を追加して修正
- **活動ログのトリム時レースコンディション**: `log-activity.sh` / `post-tool-use-log-activity.sh` のログトリム処理が固定名の一時ファイルを使っており、並行実行で破損しうる状態だった。共通関数 `ckms_append_and_trim_log`（ロック + PID 付き一時ファイル）に統一
- **`search-sessions.sh` のオプション誤解釈**: `-v` のように `-` で始まるキーワードが `grep` のオプションとして解釈され、無言で検索が失敗していた。`grep --` でオプション終端を明示
- **`release.sh` のリリース対象コミットの不定性**: `gh release create` に `--target` を渡していなかったため、タグ未作成時は GitHub 上のデフォルトブランチの最新状態からタグが作られ、ローカルで検証した内容と一致しない恐れがあった。作業ツリーのクリーンさ・upstream との一致を確認し、`--target` に検証済みコミットを明示。実行前の確認プロンプトも追加
- **`init.ps1` の機能不足**: `init.sh` にあった v4.x → v6 移行検出、実行権限の付与（Windows の `Copy-Item` は git の実行ビットを引き継がない）が `init.ps1` に無かった。両方とも追加（実行権限は Git Bash 経由の `chmod`）
- **Windows 実行系が CI で未検証**: `setup-smoke-test` は `ubuntu-latest` 固定で `init.ps1` を一度も実行しておらず、上記のような Windows 固有のバグが検知できない構造だった。`windows-latest` 上で `init.ps1` を実行し、hooks を直接起動して検証する `windows-setup-smoke-test` ジョブを追加
- **hooks のパス処理のバックスラッシュ非対応**: `log-activity.sh` / `post-tool-use-log-activity.sh` が `file_path` を `/` 区切り前提で処理しており、Windows ネイティブなバックスラッシュ区切りパスが渡った場合に自己編集の除外・相対パス化が効かない可能性があった。防御的にバックスラッシュを `/` へ正規化する処理を追加
- **`windows-setup-smoke-test` の working-directory**: Git Bash 形式の `/c/ckms-target` を指定していたため、Windows ランナーがプロセス起動時にディレクトリ不正で失敗した。`C:\ckms-target` に変更
- **スキーマ取得 URL**: `github.com/cursor/plugins/blob/HEAD/...` が 404 になり、`blob/main` も Windows の `links:check` で dead になるため、公式 `$id`（`https://cursor.com/schemas/cursor-plugin/plugin.json`）とリポジトリトップへ差し替え
- **OKF 仕様リンク**: GitHub の blob URL が `links:check` で不安定なため、[open-knowledge-format](https://github.com/GoogleCloudPlatform/open-knowledge-format) リポジトリトップへ変更

## [6.0.0] - 2026-08-01

### 🎉 Major Release - Agent Skills への統一と記録の習慣化

#### 💥 Breaking Changes

- **配布物の配置**: `templates/.agents/skills/` → ルート直下の [`skills/`](skills/) に移動。`init.sh` のパスは `skills/project-setup/scripts/init.sh` に変わりました
- **カスタムコマンドの廃止**: `templates/.cursor/commands/` の 7 コマンドを削除し、6 つのアクションスキル（`disable-model-invocation: true`）に統合。`/record-decision` などの呼び出し方は変わりません
- **`/migrate-from-rules` の廃止**: Cursor 組み込みの `/migrate-to-skills` と役割が重複するため削除。`migrate-from-rules.sh` も同時に削除しました
- **`templates/.cursor/skills/` の削除**: `templates/.agents/skills/` との二重管理で 7 つの SKILL.md すべてが drift していたため削除
- **知識の保存形式**: 単一の `*_TEMPLATE.md` への追記から、1 概念 1 ファイル + `README.md` 索引に変更。既存の `*_TEMPLATE.md` はレガシーファイルとして読み取り可能なまま残ります
- **`plugin.json` のスキーマ準拠**: 公式スキーマに存在しない `paths` / `compatibility` を削除し、`repository` を文字列に修正。v5 の `plugin.json` はスキーマ違反によりコンポーネントが検出されない状態でした
- **`npm run commands:check` の廃止**: `npm run components:check` に置き換え

#### ✨ Added

- **hooks 3 種**: [`hooks/`](hooks/) を新設
  - `sessionStart` — 蓄積済み知識の索引を初期コンテキストへ注入
  - `afterFileEdit` — 編集ファイルを `knowledge-activity.log` に追記
  - `stop` — 記録漏れがありそうなときに記録を促す（既定で無効、`loop_limit: 1`）
  - 依存は POSIX シェルと `sed` / `awk` / `find` のみ。`jq` / `python` / `node` は不要
- **knowledge-curator subagent**: [`agents/knowledge-curator.md`](agents/knowledge-curator.md)（`readonly: true`）を追加。`/review-knowledge` から委譲し、知識ベースの全走査を別コンテキストに隔離します
- **アクションスキル 6 種**: `record-decision` / `add-pattern` / `start-debug` / `log-improvement` / `review-knowledge` / `update-context`
- **`init.sh` / `init.ps1` の新オプション**: `--yes`（非対話）、`--no-hooks`、`--no-agents`。`init.ps1` に上書き確認を追加し bash 版と挙動を揃えました
- **`team-standards` の `paths`**: ソースコードを扱っているときだけ読み込まれるようスコープを設定
- **リポジトリ自身の dogfooding**: ルートに [`AGENTS.md`](AGENTS.md) と `.cursor/hooks.json` を追加
- **新規ドキュメント**:
  - [docs/advanced/hooks-guide.md](docs/advanced/hooks-guide.md)
  - [docs/advanced/subagents-guide.md](docs/advanced/subagents-guide.md)
  - [docs/templates/action-skills-guide.md](docs/templates/action-skills-guide.md)
  - [docs/getting-started/migration-from-v5.md](docs/getting-started/migration-from-v5.md)

#### 🔄 Changed

- **`check-skill-structure.mjs`**: YAML パーサによる厳密な frontmatter 検証に置き換え。`name` の長さと kebab-case、`description` の長さ、未知キー、`paths` / `disable-model-invocation` の型を Agent Skills 仕様に沿って検証し、`templates/` への複製も検出します
- **`check-plugin-manifest.mjs`**: ajv と公式スキーマ（[`schemas/`](schemas/) にベンダリング）による検証に置き換え
- **`check-links.mjs`**: 対象に `skills/` / `agents/` / `hooks/` / `templates/` を追加
- **CI**: `gh skill publish --dry-run` ジョブと、`init.sh` / `validate.sh` / 記録スクリプト / hooks を通しで実行するスモークテストジョブを追加
- **`release.sh`**: `npm` が見つからない場合に `docs:check` をスキップせず失敗させるよう変更
- **`validate.sh`**: v6 構造の検証に対応し、`.cursor/commands/` の残存を警告
- **`gh skill install`**: `skills/` が非隠しディレクトリになったため `--allow-hidden-dirs` が不要になりました

#### 🐛 Fixed

- **日本語タイトルでファイル名が壊れる問題**: `create-session.sh` などでスラッグが空になり、`2026-07-28-.md` のようなファイルが生成されていました。スラッグ化を共通関数に集約し、変換結果が空の場合はタイムスタンプにフォールバックします
- **frontmatter の `description`**: HTML コメントを値にしていた箇所を、空文字列 + 行コメントに修正

### 📋 v5.x からの移行

`init.sh` を再実行すると、スキルの更新と hooks / subagent の配置が行われます。`.cursor/commands/` は手動で削除してください（`validate.sh` が警告します）。詳細は [v5 からの移行ガイド](docs/getting-started/migration-from-v5.md) を参照してください。

## [5.0.1] - 2026-04-26

### Changed

- **メタデータ**: [`.cursor-plugin/plugin.json`](.cursor-plugin/plugin.json) と [`apm.yml`](apm.yml) の説明文を、README 相当の内容（Cursor 3.x / Claude Code / Codex、`.agents/skills`、4 配布経路）に揃え、`plugin.json` の `keywords` を拡充
- **README**: 冒頭に Codex 共用の一文と [README.en.md](README.en.md) への案内。貢献案内を [CONTRIBUTING.md](CONTRIBUTING.md) へ
- **開発ログ**: [docs/reference/development-log.md](docs/reference/development-log.md) に v4/v5 要約、正典（CHANGELOG / README）の明記、ディレクトリ図を `.agents/skills` 基準に更新
- **CI**: [`.github/dependabot.yml`](.github/dependabot.yml)（npm 週次）、[`.github/workflows/docs-check.yml`](.github/workflows/docs-check.yml) に `schedule`（週次）と `windows-latest` マトリクス
- **リンク検証**: [scripts/check-links.mjs](scripts/check-links.mjs) の対象に `README.en.md` / `CONTRIBUTING.md` を追加
- **ドキュメント**: [README.en.md](README.en.md)（英語クイックスタート）、[CONTRIBUTING.md](CONTRIBUTING.md)（PR 前 `docs:check` と版数同期手順）を新規追加

## [5.0.0] - 2026-04-18

### 🎉 Major Release - Cursor Plugin 化と配布経路の多様化

#### 💥 Breaking Changes
- **正規スキルディレクトリ変更**: `templates/.claude/skills/` → `templates/.agents/skills/` に移動（Cursor 3.x / Claude Code / Codex 公式互換の `.agents/skills/` 規約に準拠）
- **init デフォルト出力**: スキルのコピー先が `target/.claude/skills` から `target/.agents/skills` に変更
- **デバッグセッション既定パス**: `.claude/debug-sessions` → `.agents/debug-sessions` に変更（`.agents` > `.claude` > `.cursor` の順で自動検出）
- **`templates/.cursor/skills/`**: 非推奨化し `DEPRECATED.md` を追加。`init.sh` の転送先は `.agents/skills/` に更新
- **互換性**: `.claude/skills/` / `.cursor/skills/` は引き続きフォールバックとして動作。ただし新規プロジェクトでは `.agents/skills/` を推奨

#### ✨ Added
- **Cursor Plugin マニフェスト**: [.cursor-plugin/plugin.json](.cursor-plugin/plugin.json) を新規追加。Cursor Marketplace 配布に対応
- **Microsoft APM 対応**: [apm.yml](apm.yml) を追加。`apm install shioki/Cursor-Knowledge-Management-System#v5.0.0` で取り込み可能
- **gh skill 対応**: 全 SKILL.md に `license: MIT` と `metadata.tags` を追加し、`gh skill install` / `gh skill publish` に対応
- **AGENTS.md テンプレート**: `templates/AGENTS.md.template`（ルート用）と `templates/AGENTS.md.nested-example.md`（サブディレクトリ用）を同梱
- **init.sh `--legacy-claude` / `--with-agents-md`**: v4 互換配置と AGENTS.md 同梱オプションを新設
- **自動移行提案**: init.sh デフォルト実行時、`.claude/skills` 検出で `.agents/skills` への移動を対話提案
- **新規ドキュメント**:
  - [docs/advanced/plugin-development.md](docs/advanced/plugin-development.md) - Cursor Plugin ローカルテスト手順
  - [docs/reference/marketplace-submission.md](docs/reference/marketplace-submission.md) - Marketplace 提出手順
  - [docs/reference/gh-skill-integration.md](docs/reference/gh-skill-integration.md) - gh skill 連携
  - [docs/reference/apm-integration.md](docs/reference/apm-integration.md) - APM 連携
  - [docs/getting-started/agents-md-guide.md](docs/getting-started/agents-md-guide.md) - AGENTS.md 運用ガイド
- **プラグインマニフェスト検証**: `scripts/check-plugin-manifest.mjs` を新設。`.cursor-plugin/plugin.json` と `apm.yml` のスキーマを検証
- **`npm run plugin:check`**: `docs:check` に組み込み
- **`npm run skill:publish`**: `gh skill publish` を呼び出すラッパーを新設
- **release.sh immutable release 対応**: バージョン整合性チェック、`gh skill publish` 連携、immutable release アナウンスを追加

#### 🔄 Changed
- **`_skill-base.sh`**: 検出順を `.agents` → `.claude` → `.cursor` に変更
- **全 SKILL.md のパス表記**: `.claude/skills/...` → `.agents/skills/...` に更新（後方互換の注記付き）
- **compatibility フィールド**: `Cursor, Claude Code` → `Cursor 3.x, Claude Code, Codex` に更新
- **validate.sh**: `.agents/skills` を優先検出。`license` フィールドの存在を optional チェック
- **migrate-from-rules.sh**: `--legacy-claude` / `--cursor-only` オプションを新設
- **`/migrate-from-rules` コマンド**: Cursor 組み込み `/migrate-to-skills` との使い分けセクションを追記
- **check-skill-structure.mjs**: 走査対象を `templates/.agents/skills/` に変更、`license` / `metadata` を optional warning でチェック
- **README / CHANGELOG**: v5.0.0 の配布経路 4 種と新機能を反映

### 📋 v4.x からの移行
- **自動移行**: `init.sh /path/to/project` 実行時、`.claude/skills` 検出で `.agents/skills` への移動提案が表示されます
- **手動移行**: `mv .claude/skills .agents/skills && [ -d .claude/debug-sessions ] && mv .claude/debug-sessions .agents/debug-sessions`
- **v4 互換を維持したい場合**: `init.sh /path/to/project --legacy-claude` を使用

詳細は [RELEASE_NOTES_v5.0.0.md](RELEASE_NOTES_v5.0.0.md) を参照してください。

## [4.0.0] - 2026-03-05

### 🎉 Major Release - Cursor + Claude Code 共用化

#### 💥 Breaking Changes
- **テンプレート配置**: スキルのソースが `templates/.cursor/skills/` から `templates/.claude/skills/` に変更
- **init デフォルト出力**: スキルのコピー先が `target/.cursor/skills` から `target/.claude/skills` に変更
- **デバッグセッション**: 保存先が `.cursor/debug-sessions` から `.claude/debug-sessions` に変更（後方互換のためパス検出あり）

#### ✨ Added
- **Cursor + Claude Code 並行利用**: `.claude/skills` を共有配置とし、両ツールで同一スキルを参照可能
- **`--cursor-only` オプション**: init 時に `.cursor/skills` に配置する Cursor 専用モード
- **パス検出ロジック**: `_skill-base.sh` により `.claude/skills` と `.cursor/skills` を自動検出
- **並行利用ガイド**: `docs/getting-started/parallel-use-cursor-claude.md` を新規追加
- **v3→v4 移行ガイド**: `docs/getting-started/migration-from-v3.md` を新規追加
- **compatibility フィールド**: 全 7 スキルに `compatibility: Cursor, Claude Code` を追加

#### 🔄 Changed
- **migrate-from-rules.sh**: 移行先を `.claude/skills` に変更、v4.0.0 対応
- **validate.sh**: `.claude/skills` と `.cursor/skills` の両方を検証対象に
- **scripts/check-skill-structure.mjs**: チェック対象を `templates/.claude/skills` に変更
- **全スクリプト**: パス検出により `.claude` 優先、`.cursor` フォールバック
- **.cursorignore**: `.claude/debug-sessions/personal-*` 等を追加
- **ドキュメント**: README、quick-start、skills-guide、commands-guide 等を `.claude/` ベースに全面更新

### 📋 v3.x からの移行
- パス検出により `.cursor/skills` のままでも継続動作
- `.claude/` への移行は任意。詳細は [migration-from-v3.md](docs/getting-started/migration-from-v3.md) を参照

## [3.1.0] - 2026-02-25

### ✨ Added
- **Cursor Marketplace 対応**: プラグイン構成（Skills / Subagents / MCP / Hooks / Rules）と本システムの対応を解説する `docs/reference/cursor-plugins-and-marketplace.md` を新規追加
- **Windows 用 init.ps1**: `templates/.cursor/skills/project-setup/scripts/init.ps1` を追加（PowerShell で skills / commands / .cursorignore を一括コピー）
- README に Cursor プラグイン・マーケットプレイスへの言及を追加
- custom-skills.md にマーケットプレイスでプラグインとして共有する場合の一文を追加

### 🔄 Changed
- **コマンド数表記の統一**: 「6 つのコマンド」を「7 つのコマンド」に統一（`/migrate-from-rules` を含む）
- **Windows 対応の明文化**: システム要件・クイックスタート・品質チェック・リリース手順に Windows（PowerShell / Git Bash / WSL）の案内を追加
- **quick-start.md**: セットアップを Mac/Linux と Windows で整理、チェックリスト・トラブルシューティングを更新、init.ps1 の使い方セクションを追加
- **project-setup/SKILL.md**: init.sh / validate.sh の Windows での実行方法（Copy-Item、Git Bash、init.ps1）を追記
- **github-release.md**: Windows でリリースする場合の Git Bash / WSL 案内を追加

## [3.0.0] - 2026-02-07

### 🎉 Major Release - Agent Skills + Commands への全面移行

#### 💥 Breaking Changes
- `.cursor/rules/` ディレクトリを完全廃止
- `.cursor/knowledge.md`, `.cursor/patterns.md`, `.cursor/context.md`, `.cursor/debug-log.md`, `.cursor/improvements.md` を廃止（スキルの references/ に移行）
- `.cursor/mcp.json` をテンプレートから削除
- `npm run mdc:check` を廃止（`npm run skills:check` + `npm run commands:check` に置き換え）

#### ✨ Added
- **エージェントスキル（Agent Skills）**: Cursor AI 公式の Agent Skills 標準仕様を全面採用
  - `project-context` - プロジェクト背景・制約の提供
  - `team-standards` - チーム開発標準の提供
  - `knowledge-management` - 技術判断の記録・参照（scripts/ 付き）
  - `pattern-library` - 実装パターンの管理（scripts/ 付き）
  - `debug-workflow` - デバッグワークフロー支援（scripts/ 付き）
  - `improvement-tracking` - 改善活動の追跡（scripts/ 付き）
  - `project-setup` - 新規プロジェクトへの導入支援（scripts/ 付き）
- **カスタムコマンド（Commands）**: `/` で即座に起動するワークフロー
  - `/record-decision` - 技術判断の記録
  - `/add-pattern` - 実装パターンの登録
  - `/start-debug` - デバッグセッション開始
  - `/log-improvement` - 改善内容の記録
  - `/review-knowledge` - 知識ベースの定期レビュー
  - `/update-context` - プロジェクトコンテキスト更新
  - `/migrate-from-rules` - v2.x からの対話型移行支援
- **自動化スクリプト**: シェルスクリプトによる記録作成・検索の自動化
- **構造検証スクリプト**: `check-skill-structure.mjs`, `check-command-structure.mjs`
- **マイグレーション支援**:
  - `docs/getting-started/migration-from-rules.md` - 移行ガイド（3 つの移行方法を解説）
  - `scripts/migrate-from-rules.sh` - 自動移行スクリプト（バックアップ・転記・削除）
  - `/migrate-from-rules` コマンド - 対話型移行ワークフロー
- **新規ドキュメント**:
  - `docs/getting-started/skills-and-commands.md` - スキルとコマンドの概要
  - `docs/templates/skills-guide.md` - 7 つのスキルの詳細ガイド
  - `docs/templates/commands-guide.md` - 6 つのコマンドの詳細ガイド
  - `docs/advanced/custom-skills.md` - カスタムスキル・コマンド作成ガイド

#### 🗑️ Removed
- `templates/.cursor/rules/` ディレクトリ全体（7 つの .mdc ファイル）
- `templates/.cursor/knowledge.md`, `patterns.md`, `context.md`, `debug-log.md`, `improvements.md`
- `templates/.cursor/mcp.json`
- `scripts/check-mdc-frontmatter.mjs`
- `docs/templates/` 配下の旧個別ガイド 6 ファイル（skills-guide.md と commands-guide.md に統合）

#### 🔄 Changed
- **README.md**: スキル + コマンドベースに全面書き換え
- **docs/getting-started/quick-start.md**: スキル + コマンドのセットアップ手順に更新
- **docs/cursor-knowledge-management-system.md**: 3 層アーキテクチャの解説に刷新
- **docs/advanced/team-implementation.md**: チームコマンドとの連携方法を追加
- **package.json**: `mdc:check` → `skills:check` + `commands:check` に変更
- **templates/.cursorignore**: スキルベースのパスに更新

### 🎯 Impact
- **アーキテクチャ**: 「コマンド → スキル → データ」の 3 層構造
- **自動化**: スクリプトによる記録作成・検索の効率化
- **標準準拠**: Agent Skills 標準仕様（agentskills.io）に準拠
- **ユーザビリティ**: `/` コマンドによる直感的なワークフロー起動

### 📋 v2.x からの移行
1. 旧 `.cursor/rules/` ディレクトリを削除
2. 新 `templates/.cursor/skills/` と `templates/.cursor/commands/` をコピー
3. 旧データファイルの内容を各スキルの `references/` テンプレートに転記

## [2.0.0] - 2025-10-11

### 🎉 Major Release - ドキュメント構造の大幅改善

#### ✨ Added
- **新しいドキュメント構造**: 論理的な4つのセクションに再編成
  - `docs/getting-started/` - 導入ガイド
  - `docs/templates/` - テンプレート使用ガイド
  - `docs/advanced/` - 高度な使用方法
  - `docs/reference/` - 技術リファレンス
- **統合ナビゲーションシステム**: 各セクションのREADME.mdと相互参照リンク
- **視覚的改善**: Mermaid図によるシステム構成とフローの可視化
- **テンプレートファイルの説明強化**: 各テンプレートに詳細な概要セクションを追加

#### 🔄 Changed
- **README.md**: 新しい構造に合わせた大幅な改善とナビゲーション強化
- **ファイル名の統一**: より分かりやすい命名規則への変更
- **ドキュメントの整理**: 重複情報の排除と一元化

#### 🗑️ Removed
- **重複ファイル**: 古い構造のファイルを削除
- **情報の重複**: 複数箇所に散らばっていた情報を整理

#### 📚 Documentation
- **包括的なナビゲーション**: 各セクションの詳細な説明と学習パス
- **視覚的ガイド**: フローチャートとシステム構成図の追加
- **改善されたユーザビリティ**: 目的別の情報アクセス向上

### 🎯 Impact
- **ユーザビリティ**: 情報検索時間の大幅短縮
- **保守性**: ドキュメント管理の効率化
- **拡張性**: 将来の機能追加への対応力向上

## [2.0.1] - 2025-12-07

### 🔧 Changed
- READMEに品質チェック手順（リンクチェック、.mdc frontmatter確認）を追加
- `.cursor/rules` テンプレート構成を最新版に更新（project-context/debug-support/improvement-tracking追加）

### 🐛 Fixed
- Getting Started 内の死リンクを修正

### 📚 Documentation
- ルール構成とメンテナンス手順の記述を最新化

## [1.0.0] - 2025-06-15

### 🎉 Initial Release

#### ✨ Added
- **Cursor AI知識管理システム**: `.cursor/rules`形式対応の知識管理フレームワーク
- **5つのテンプレートファイル**: 
  - `knowledge.md` - 技術判断記録
  - `patterns.md` - 実装パターン
  - `context.md` - プロジェクト背景
  - `debug-log.md` - デバッグログ
  - `improvements.md` - 改善記録
- **4つのMDCルールファイル**: 自動適用機能付き
- **包括的なドキュメント**: 導入から高度な使用方法まで
- **チーム導入ガイド**: 組織での活用方法

#### 🔧 Technical Features
- **MDC形式対応**: Cursor AI公式の`.cursor/rules`形式採用
- **自動参照機能**: 条件付き自動適用による効率化
- **テンプレートシステム**: 再利用可能な知識管理構造
- **安全性重視**: HTMLコメント問題の解決

#### 📖 Documentation
- **完全ガイド**: システムの詳細説明
- **クイックスタート**: 5分で始める導入手順
- **テンプレート使用ガイド**: 各ファイルの詳細な使用方法
- **チーム導入ガイド**: 組織での展開方法
- **開発ログ**: システム開発の背景と経緯

---

## 📋 バージョン管理方針

### セマンティックバージョニング
- **メジャーバージョン (X.0.0)**: 破壊的変更、大きな機能追加
- **マイナーバージョン (0.X.0)**: 新機能追加、後方互換性あり
- **パッチバージョン (0.0.X)**: バグ修正、小さな改善

### リリースノート
- **Added**: 新機能
- **Changed**: 既存機能の変更
- **Deprecated**: 非推奨機能
- **Removed**: 削除された機能
- **Fixed**: バグ修正
- **Security**: セキュリティ関連の修正

### 今後の予定
- **v3.1.0**: 多言語対応（英語版ドキュメント）
- **v3.2.0**: 追加スキル・コマンドの拡充
- **v4.0.0**: チームコマンド連携の強化
