# テンプレートファイル使用ガイド

このガイドでは、`templates/.cursor/` 内のテンプレートファイルの使用方法を説明します。

## 📋 概要

### テンプレートファイル一覧
- `knowledge.md` - 技術的知見・設計パターン
- `patterns.md` - 共通パターン・テンプレート  
- `context.md` - プロジェクト概要・コンテキスト
- `debug-log.md` - デバッグ・問題解決ログ
- `improvements.md` - 改善提案・最適化記録

### 基本的な使用手順
1. **コピー**: テンプレートファイルをプロジェクトの `.cursor/` ディレクトリにコピー
2. **記載**: 各セクションに実際のプロジェクト情報を記載
3. **連携**: `.cursor/rules/` ファイルと連携して自動参照を活用

---

## 📚 詳細ガイド

各テンプレートファイルの詳細な使用方法と記載例は、以下の専用ガイドをご参照ください：

### [📚 knowledge.md 使用ガイド](./template-knowledge-guide.md)
- 設計判断の記録方法
- 技術パターン集の作成
- ADR (Architecture Decision Record) の書き方
- .cursor/rules との連携方法

### [🔧 patterns.md 使用ガイド](./template-patterns-guide.md)
- .cursor/rules活用パターン
- 環境別コマンド集
- 実装テンプレートの作成
- チーム標準の定義

### [🌐 context.md 使用ガイド](./template-context-guide.md)
- プロジェクト基本情報の記載
- 技術スタックの整理
- アーキテクチャ概要の作成
- チーム構成の記録

### [🐛 debug-log.md 使用ガイド](./template-debug-log-guide.md)
- 問題・エラーログの記録
- パフォーマンス問題の分析
- 解決手順の文書化
- 予防策の記録

### [📈 improvements.md 使用ガイド](./template-improvements-guide.md)
- 改善提案の記録
- 実装済み改善の文書化
- 効果測定の方法
- 継続的改善のプロセス

---

## 🔄 継続的な活用のベストプラクティス

### 1. 定期的な更新
- **週次**: 新しい問題・解決策の追加
- **月次**: 内容の整理・統合
- **四半期**: 全体的な見直し・改善

### 2. チーム共有
- 新しい知見の共有会
- 問題解決事例の発表
- ベストプラクティスの更新

### 3. .cursor/rules との連携
- 適切なルール設定
- 自動参照の活用
- 効果的なタグ付け

### 4. 品質管理
- 情報の正確性確認
- 古い情報の削除・更新
- 一貫性のあるフォーマット維持

---

## 🚀 クイックスタート

初めて使用する場合は、以下の順序で進めることをお勧めします：

1. **[context.md ガイド](./template-context-guide.md)** でプロジェクト基本情報を整理
2. **[patterns.md ガイド](./template-patterns-guide.md)** で開発パターンを定義
3. **[knowledge.md ガイド](./template-knowledge-guide.md)** で技術的知見を蓄積
4. **[debug-log.md ガイド](./template-debug-log-guide.md)** で問題解決を記録
5. **[improvements.md ガイド](./template-improvements-guide.md)** で継続的改善を実施

---

このガイドを参考に、プロジェクトに適した知識管理システムを構築してください。 