# Changelog

このプロジェクトの重要な変更履歴を記録します。

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
