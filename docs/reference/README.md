# Reference

技術的な詳細、リファレンス情報、トラブルシューティングを提供します。

## 📋 セクション概要

このセクションでは、システムの技術的な詳細、開発履歴、設定方法などのリファレンス情報を提供します。

## 📖 リファレンス資料

### 1. [完全ガイド](../cursor-knowledge-management-system.md)
**システムの詳細説明**
- システムの目的と価値
- 設計思想とアーキテクチャ
- 知識管理の方法論
- 効果測定と改善

### 2. [開発ログ](development-log.md)
**システム開発の記録**
- 開発プロセスの詳細
- 技術的決定の履歴
- 改善の経緯
- 学習記録と教訓

### 3. [MCP日時設定ガイド](mcp-datetime-setup.md)
**MCPサーバの設定方法**
- 推奨MCPサーバ
- 設定手順
- トラブルシューティング
- パフォーマンス最適化

## 🔧 技術仕様

### システム要件
- **Cursor AI**: 最新版推奨
- **Node.js**: 18.x以上（MCPサーバ使用時）
- **Git**: 2.0以上

### 対応形式
- **.cursor/rules**: MDC形式（Markdown with Configuration）
- **Markdown**: 標準的なMarkdown記法
- **YAML**: 設定ファイル用

### ファイル構造
```
.cursor/
├── knowledge.md              # 技術判断・設計決定の記録
├── patterns.md               # 共通パターン・テンプレート
├── context.md                # プロジェクト背景・制約
├── debug-log.md              # デバッグ履歴・問題解決記録
├── improvements.md           # 改善履歴・最適化記録
└── rules/                    # .cursor/rules設定
    ├── knowledge-management.mdc
    ├── debug-workflow.mdc
    ├── patterns-library.mdc
    └── team-standards.mdc
```

## 🆘 トラブルシューティング

### よくある問題

#### ルールが適用されない
**原因**: `.cursor/rules/`ディレクトリの場所やファイル拡張子の問題
**解決策**: 
- ファイルが`.mdc`拡張子であることを確認
- `.cursor/rules/`ディレクトリが正しい場所にあることを確認
- Cursor AIを再起動

#### 自動参照が働かない
**原因**: ファイルが実際のプロジェクト情報で更新されていない
**解決策**:
- テンプレートファイルを実際のプロジェクト情報で更新
- `.cursor/rules/`ファイルの設定を確認

#### コピーコマンドが失敗する
**原因**: パスや権限の問題
**解決策**:
- パスが正しいことを確認
- 実行権限があることを確認
- 管理者権限で実行

### デバッグ手順

1. **ログの確認**
   - Cursor AIのログを確認
   - システムログを確認

2. **設定の検証**
   - ファイル構造の確認
   - 設定ファイルの構文チェック

3. **段階的なテスト**
   - 最小限の設定でテスト
   - 段階的に機能を追加

## ✅ リンク・ルールの自動チェック（推奨）

- **Markdownリンクチェック**: `npx markdown-link-check docs/**/*.md`  
  - CI では `--quiet --config .mlc.json` などでノイズ削減を推奨
- **.mdc frontmatter検証**: 必須キー `description`, `globs`, `alwaysApply` の有無を簡易スクリプトで確認  
  - 例（Node）: `node scripts/check-mdc-frontmatter.mjs` を用意し、`.cursor/rules/*.mdc` を走査
- **定期実行**: 週次のドキュメント更新時・リリース前に実行して参照切れを防止

## 📊 パフォーマンス

### 推奨設定
- **ファイルサイズ**: 各ファイル1MB以下
- **更新頻度**: 日次以下
- **バックアップ**: 週次

### 最適化のヒント
- 不要な情報の定期的な削除
- ファイルの分割（必要に応じて）
- 効率的な検索のためのタグ付け

## 🔄 更新履歴

### バージョン管理
- **メジャーバージョン**: 大きな機能追加や変更
- **マイナーバージョン**: 機能改善や追加
- **パッチバージョン**: バグ修正

### 変更履歴
詳細な変更履歴は [開発ログ](development-log.md) を参照してください。

## 📚 関連リソース

### 公式ドキュメント
- [Cursor AI Documentation](https://cursor.sh/docs)
- [GitHub Documentation](https://docs.github.com)

### コミュニティ
- [GitHub Discussions](https://github.com/shioki/Cursor-Knowledge-Management-System/discussions)
- [Issues](https://github.com/shioki/Cursor-Knowledge-Management-System/issues)

## 🔄 関連セクション

### 🚀 [Getting Started](../getting-started/README.md)
基本的な導入と設定

### 📋 [Templates](../templates/README.md)
テンプレートファイルの使用方法

### 🏢 [Advanced](../advanced/README.md)
高度な使用方法とチーム導入

---

**💡 ヒント**: 問題が発生した場合は、まずこのセクションのトラブルシューティングを確認してください。

**📅 最終更新**: 2025-10-11
