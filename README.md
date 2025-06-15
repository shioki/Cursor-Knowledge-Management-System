# Cursor Knowledge Management System

Cursor AIのMDC（Model Context Protocol）形式に対応した知識管理システムです。AI支援開発における一貫性、品質向上、そして効率的な知識蓄積を実現します。

## ✨ 主な特徴

- **🎯 MDC完全対応**: Cursor AI公式の`.cursor/rules`形式を採用
- **🔄 自動適用**: 手動設定不要の自動化されたルール適用
- **📚 体系的管理**: プロジェクト知識の構造化された管理
- **🚀 セットアップ**: 導入後の活用開始
- **👥 チーム対応**: 個人からチーム開発まで対応

## 🚀 クイックスタート

### 1. リポジトリのクローン
```bash
git clone https://github.com/your-username/cursor-knowledge-management-system.git
cd cursor-knowledge-management-system
```

### 2. **⚠️ 重要: 必須更新ファイル**

**GitHubからクローンした後、以下のファイルは必ず更新が必要です：**

#### 🔥 **知識管理ファイル（最重要）**
- [ ] `templates/.cursor/knowledge.md` - 実際の技術判断を記録
- [ ] `templates/.cursor/patterns.md` - プロジェクト固有のパターンを記録
- [ ] `templates/.cursor/context.md` - プロジェクト背景・制約を記録

#### 📝 **プロジェクト基本情報**
- [ ] `README.md` - プロジェクト名・概要を更新
- [ ] `package.json` - メタデータ（Node.jsの場合）

#### 🔒 **基本的に変更不要**
- `.cursor/rules/` 配下のシステムファイル

**⚠️ テンプレートのままでは自動参照の効果が得られません**

詳細な手順は [クイックスタートガイド](docs/quick-start.md) を参照してください。

## 📁 プロジェクト構造

```
cursor-knowledge-management-system/
├── .cursor/rules/               # MDC形式ルール（基本的に変更不要）
├── templates/.cursor/           # 🔥 要更新: 実プロジェクト情報で埋める
│   ├── knowledge.md            # 技術判断記録
│   ├── patterns.md             # 設計パターン
│   └── context.md              # プロジェクト背景
├── docs/                       # ドキュメント
└── README.md                   # 要更新
```

## 🎯 MDC形式の特徴

MDC形式では、4つのルールタイプで柔軟な制御が可能です：

| ルールタイプ | 設定 | 動作 |
|-------------|------|------|
| **Always** | `alwaysApply: true` | 常に適用 |
| **Auto** | `globs: "pattern"` | ファイルマッチで自動適用 |
| **Agent** | `description: "詳細"` | AI判断で適用 |
| **Manual** | 全て空白 | 手動参照のみ |

## 🔧 基本的な使用方法

### 知識の記録
```markdown
# templates/.cursor/knowledge.md に記録
### 2025-06-XX - フレームワーク選択
#### 判断内容
React vs Vue.js の選択
#### 結果
React を採用（チームの習熟度を考慮）
```

### 自動参照
AIとの対話で自動的に参照されます：
```
@.cursor/knowledge.md @.cursor/patterns.md
「ユーザー認証機能を実装してください」
```

## 📚 関連ドキュメント

- [クイックスタートガイド](docs/quick-start.md) - 詳細な導入手順
- [チーム導入ガイド](docs/team-implementation-guide.md) - チーム全体での活用
- [開発ログ](docs/development-log.md) - システム開発の記録

## 📄 ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照

---

**⚠️ 重要**: このシステムを効果的に活用するには、`templates/.cursor/`内のファイルを実際のプロジェクト情報で更新することが必須です。
