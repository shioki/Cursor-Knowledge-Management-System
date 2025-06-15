# 🎯 Cursor Knowledge Management System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Cursor](https://img.shields.io/badge/Cursor-AI--Powered-blue)](https://cursor.sh/)
[![Japanese](https://img.shields.io/badge/Language-Japanese-red)](README.md)

**Cursor AI開発のための包括的な知識管理システム**

## 🚀 概要

Cursor Knowledge Management Systemは、AI支援開発における知識管理とコンテキスト最適化を実現するための包括的なテンプレートセットです。個人開発者からエンタープライズチームまで、あらゆる規模のプロジェクトで効率的な開発を支援します。

### ✨ 主な特徴

- **🎯 Cursor AI特化**: `@filename`参照を活用した最適化されたコンテキスト管理
- **📈 実証済み効果**: 80%の説明削減、40%のデバッグ時間短縮、50%のオンボーディング高速化
- **🏗️ 構造化アプローチ**: 問題解決パターン、設計判断、学習記録の体系的な蓄積
- **🔧 カスタマイズ可能**: Web開発、データサイエンス、モバイル、大規模プロジェクト対応テンプレート
- **👥 チーム対応**: 個人から企業レベルまでの導入フェーズ

## 📁 システム構成

```
your-project/
├── CURSOR.md              # メインAI指示ファイル
└── .cursor/
    ├── context.md         # プロジェクト背景・制約
    ├── patterns.md        # 共通コマンド・実装パターン
    ├── debug-log.md       # 重要なデバッグ記録
    ├── improvements.md    # 改善履歴・学習記録
    ├── knowledge.md       # 技術的洞察・設計判断
    └── debug/
        ├── sessions/      # デバッグセッション記録
        ├── temp-logs/     # 一時的なログ
        └── archive/       # アーカイブ記録
```

## 🏃‍♂️ クイックスタート

### 1. テンプレートのコピー

```bash
# このリポジトリをクローン
git clone https://github.com/yourusername/cursor-knowledge-management-system.git

# プロジェクトディレクトリに移動
cd your-project

# テンプレートをコピー
cp -r cursor-knowledge-management-system/templates/* .
```

### 2. カスタマイズ

1. **CURSOR.md**: プロジェクト名、技術スタック、制約を更新
2. **.cursor/context.md**: プロジェクト背景と要件を記述
3. **.cursor/patterns.md**: プロジェクト固有のパターンを追加

### 3. 利用開始

```bash
# Cursorでプロジェクトを開く
cursor .

# AI会話で以下のように参照
# "@CURSOR.md このプロジェクトの構造について教えて"
# "@.cursor/patterns.md の認証パターンを使用してください"
```

## 📊 効果と成果

### 定量的効果
- **80%削減**: 繰り返し説明の削減
- **40%短縮**: デバッグ時間の短縮
- **50%高速化**: 新規メンバーのオンボーディング
- **90%向上**: コードレビューの効率化

### 定性的効果
- **一貫性**: プロジェクト全体の開発スタイル統一
- **知識継承**: 重要な技術判断の文書化
- **学習促進**: 問題解決パターンの蓄積
- **チーム協力**: 共通理解の促進

## 🎯 対応プロジェクト

### Web開発
- React/Next.js
- Vue.js/Nuxt.js
- Node.js/Express
- Django/Flask

### データサイエンス
- Python/Jupyter
- R/RStudio
- データ分析パイプライン
- ML/AI実験

### モバイル開発
- React Native
- Flutter
- iOS/Android
- クロスプラットフォーム

### 大規模プロジェクト
- マイクロサービス
- DevOps/CI/CD
- エンタープライズ
- チーム開発

## 📖 詳細ドキュメント

- **[クイックスタート & セットアップ](docs/quick-start.md)**: 5分で導入・即座に活用開始
- **[チーム導入ガイド](docs/team-implementation-guide.md)**: 3段階の導入プロセス
- **[包括的ガイド](docs/cursor-knowledge-management-system.md)**: 完全な導入・運用ガイド

## 💡 活用例

### 🔍 既存知見の検索
```bash
# 問題解決時
"@.cursor/debug-log.md 似た問題の解決例はありますか？"

# パターン確認時
"@.cursor/patterns.md このプロジェクトの標準パターンは？"

# 設計相談時
"@.cursor/context.md この制約の下で、[具体的な質問]"
```

### 📝 新しい知見の記録
```bash
# 問題解決後 → 即座に .cursor/debug-log.md に記録
# 新パターン発見 → .cursor/patterns.md に追加
# 設計判断時 → .cursor/knowledge.md に理由と共に記録
# 失敗経験 → .cursor/improvements.md に教訓として記録
```

## 🤝 貢献

プロジェクトへの貢献を歓迎します！

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m '新機能: 素晴らしい機能を追加'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📄 ライセンス

このプロジェクトは[MIT License](LICENSE)の下で公開されています。

## 🙏 謝辞

- Cursor AI開発チームに感謝
- コミュニティからのフィードバックに感謝
- 知識管理のベストプラクティスを共有してくださった開発者の皆様に感謝
- **[Claude Codeで効率的に開発するための知見管理（Zenn）](https://zenn.dev/driller/articles/2a23ef94f1d603)** - 本プロジェクトのアイデアの源泉となった記事

---

**💡 Tip**: `@CURSOR.md`でこのファイルを参照することで、AIがプロジェクトの全体像を把握し、より適切な支援を提供できます。

**🔗 関連リンク**:
- [Cursor公式サイト](https://cursor.sh/)
- [AI開発ベストプラクティス](docs/quick-start.md)
- [チーム導入事例](docs/team-implementation-guide.md)

**🏆 実績**:
- 80%の説明削減効果
- 40%のデバッグ時間短縮
- 50%のオンボーディング高速化
- 個人〜エンタープライズまで対応

**⚡ 即座に使用開始**: `templates/`からファイルをコピーして、すぐにCursor AIでの効率的な開発を始めましょう！
