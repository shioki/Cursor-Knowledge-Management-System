# Cursor Knowledge Management System

Cursor AIの`.cursor/rules`形式に対応した知識管理システムです。AI支援開発における一貫性、品質向上、そして効率的な知識蓄積を実現します。

## ✨ 主な特徴

- **🎯 .cursor/rules対応**: Cursor AI公式の`.cursor/rules`形式を採用
- **🔄 自動適用**: 手動設定不要の自動化されたルール適用
- **📚 体系的管理**: プロジェクト知識の構造化された管理
- **🚀 セットアップ**: 導入後の活用開始
- **👥 チーム対応**: 個人からチーム開発まで対応

## ⚠️ 重要: 必須更新ファイル

**GitHubからクローンした後、以下のファイルは必ず更新が必要です：**

#### 🔥 **知識管理ファイル（最重要）**
- [ ] `.cursor/knowledge.md` - 実際の技術判断を記録
- [ ] `.cursor/patterns.md` - プロジェクト固有のパターンを記録
- [ ] `.cursor/context.md` - プロジェクト背景・制約を記録

**⚠️ テンプレートのままでは自動参照の効果が得られません**

## 📁 プロジェクト構造

```
cursor-knowledge-management-system/
├── templates/.cursor/           # 🔥 テンプレートファイル（コピー用）
│   ├── knowledge.md            # 技術判断記録テンプレート
│   ├── patterns.md             # 設計パターンテンプレート
│   ├── context.md              # プロジェクト背景テンプレート
│   └── rules/                  # .cursor/rulesテンプレート
├── templates/.cursorignore      # Cursor無視ファイル設定テンプレート
├── docs/                       # ドキュメント
└── README.md                   # プロジェクト説明

# 導入後の実際のプロジェクト構造:
your-project/
├── .cursor/                    # ← templates/.cursor/ をここにコピー
│   ├── knowledge.md           # 実際のプロジェクト情報で更新
│   ├── patterns.md            # 実際のプロジェクト情報で更新
│   ├── context.md             # 実際のプロジェクト情報で更新
│   └── rules/                 # .cursor/rules（Cursorが認識）
├── .cursorignore              # ← templates/.cursorignore をここにコピー
├── src/                       # あなたのプロジェクトファイル
└── README.md                  # あなたのプロジェクト説明
```

## 📚 関連ドキュメント

### 基本ガイド
- [完全ガイド](docs/cursor-knowledge-management-system.md) - システムの詳細説明
- [クイックスタートガイド](docs/quick-start.md) - 詳細な導入手順
- [チーム導入ガイド](docs/team-implementation-guide.md) - チーム全体での活用

### テンプレート使用ガイド
- [テンプレート使用ガイド](docs/template-usage-guide.md) - 概要とナビゲーション
- [context.md ガイド](docs/template-context-guide.md) - プロジェクト情報の記載方法
- [patterns.md ガイド](docs/template-patterns-guide.md) - 共通パターンの記録方法
- [knowledge.md ガイド](docs/template-knowledge-guide.md) - 技術的知見の蓄積方法
- [debug-log.md ガイド](docs/template-debug-log-guide.md) - 問題解決の記録方法
- [improvements.md ガイド](docs/template-improvements-guide.md) - 改善活動の記録方法

### 開発情報
- [開発ログ](docs/development-log.md) - システム開発の記録

## 📄 ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照

---

**⚠️ 重要**: このシステムを効果的に活用するには、`.cursor/`内のファイルを実際のプロジェクト情報で更新することが必須です。