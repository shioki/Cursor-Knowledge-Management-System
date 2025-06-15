# Cursor AI 知識管理システム 完全ガイド

## 概要

このドキュメントは、Cursor AIのMDC（Model Context Protocol）形式に完全対応した知識管理システムの包括的なガイドです。従来のCURSOR.md形式から進化し、より効率的で持続可能な開発支援を実現します。

## ⚠️ **重要: GitHubクローン後の必須更新作業**

**このシステムを効果的に活用するには、GitHubからクローンした後、以下のファイルを実際のプロジェクト情報で更新することが必須です：**

### 📝 **必ず更新が必要なファイル**

#### プロジェクト基本情報
- [ ] `README.md` - プロジェクト名・概要・使用方法
- [ ] `package.json` - メタデータ（Node.jsの場合）

#### 🔥 **知識管理ファイル（最重要！）**
- [ ] `templates/.cursor/knowledge.md` - **実際の技術判断を記録**
- [ ] `templates/.cursor/patterns.md` - **プロジェクト固有のパターンを記録**
- [ ] `templates/.cursor/context.md` - **プロジェクト背景・制約を記録**
- [ ] `templates/.cursor/debug-log.md` - **実際のデバッグ履歴を記録**
- [ ] `templates/.cursor/improvements.md` - **実際の改善履歴を記録**

#### 個人・チーム設定
- [ ] `.cursor/rules/my-rules/` 配下 - 個人の開発スタイル
- [ ] `.cursor/rules/team-rules/` 配下 - チーム開発ルール（チーム導入時）

### 🔒 **基本的に変更不要なファイル**
- `.cursor/rules/core-rules/rule-generating-agent.mdc` - ルール生成ロジック
- `.cursor/rules/global-rules/` - グローバルルール
- `.cursor/rules/ts-rules/`, `.cursor/rules/py-rules/` など（必要に応じて調整）

**⚠️ テンプレートのままでは自動参照の効果が得られません！**

## 🚀 クイックスタート

### 1. リポジトリのクローン
```bash
git clone https://github.com/your-username/cursor-knowledge-management-system.git
cd cursor-knowledge-management-system
```

### 2. 必須ファイルの更新（10-30分）

#### 最小限の更新（10分）
```bash
# 1. README.md のプロジェクト名を変更
# 2. templates/.cursor/knowledge.md をプロジェクト用に書き換え
```

#### 推奨更新（20分）
```bash
# 上記 + templates/.cursor/context.md 更新
# 使用言語に応じたルール調整
```

#### フル活用（30分）
```bash
# 上記すべて + チーム開発ルール策定
# 全templatesファイルの実プロジェクト情報での更新
```

### 3. 実際の更新例

#### templates/.cursor/knowledge.md の更新
```markdown
# 技術的知見・設計パターン（あなたのプロジェクト名）

## 設計判断の記録

### 2025-06-XX - フレームワーク選択
#### 判断内容
React vs Vue.js の選択

#### 検討した選択肢
1. **React**
   - メリット: チームの習熟度が高い、エコシステムが豊富
   - デメリット: 学習コストが高い
   - 結果: 採用

2. **Vue.js**
   - メリット: 学習コストが低い
   - デメリット: チームの経験が少ない
   - 結果: 不採用

#### 理由
チームの既存スキルを活かし、開発速度を優先
```

## 🎯 MDC形式の特徴

### 4つのルールタイプ

| ルールタイプ | 設定 | 動作 | 使用例 |
|-------------|------|------|--------|
| **Always Rules** | `alwaysApply: true` | 常に適用 | チーム標準・コーディング規約 |
| **Auto Rules** | `globs: "pattern"` | ファイルマッチで自動適用 | TypeScript専用ルール |
| **Agent Rules** | `description: "詳細"` | AI判断で適用 | 複雑な条件判断 |
| **Manual Rules** | 全て空白 | 手動参照のみ | 特殊な状況用 |

### MDC設定例
```yaml
---
description: "TypeScript開発時の品質管理ルール"
globs: "**/*.{ts,tsx}"
alwaysApply: false
---

# TypeScript開発ルール
...
```

## 📁 プロジェクト構造

```
cursor-knowledge-management-system/
├── .cursor/
│   └── rules/                    # MDC形式ルール（基本的に変更不要）
│       ├── core-rules/          # システムルール
│       ├── global-rules/        # グローバルルール
│       ├── ts-rules/           # TypeScript固有ルール
│       ├── py-rules/           # Python固有ルール
│       ├── team-rules/         # チーム開発ルール（要更新）
│       └── my-rules/           # 個人設定（要更新）
├── templates/
│   └── .cursor/                 # 🔥 要更新: 実プロジェクト情報で埋める
│       ├── knowledge.md         # 技術判断記録
│       ├── patterns.md          # 設計パターン
│       ├── context.md           # プロジェクト背景
│       ├── debug-log.md         # デバッグ履歴
│       └── improvements.md      # 改善履歴
├── docs/                        # ドキュメント
│   ├── quick-start.md          # クイックスタートガイド
│   ├── team-implementation-guide.md # チーム導入ガイド
│   └── development-log.md      # 開発ログ
└── README.md                    # 要更新: プロジェクト情報
```

## 🔧 基本的な使用方法

### 1. 知識の記録
```markdown
# templates/.cursor/knowledge.md に記録
### 2025-06-XX - API設計
#### 判断内容
REST vs GraphQL の選択

#### 結果
REST API を採用（シンプルさを重視）

#### 理由
- チームの習熟度
- プロジェクトの複雑さ
- 開発期間の制約
```

### 2. パターンの蓄積
```markdown
# templates/.cursor/patterns.md に記録
## コンポーネント設計パターン
### Atomic Design適用
- Atoms: Button, Input, Label
- Molecules: SearchBox, FormField
- Organisms: Header, ProductList
```

### 3. 自動参照の活用
AIとの対話で以下のように参照：
```
@.cursor/knowledge.md @.cursor/patterns.md
「ユーザー認証機能を実装してください」
```

## 📊 効果測定指標

### 定量的効果
- **開発効率**: 成功率の向上
- **知識定着**: 自動参照による一貫性確保
- **投資回収**: 短期間での効果実感
- **バグ削減**: バグ発生率の削減
- **オンボーディング**: 新人教育時間の短縮

### 定性的効果
- 技術判断の一貫性向上
- チーム内知識共有の促進
- 開発品質の標準化
- 継続的改善文化の醸成

*注: 具体的な効果は各プロジェクト・チームの状況により異なります*

## 🎯 プロジェクト種別別カスタマイズ

### Web開発プロジェクト
```yaml
# .cursor/rules/web-rules.mdc
---
description: "Web開発専用ルール"
globs: "**/*.{js,ts,jsx,tsx,css,scss,html}"
alwaysApply: false
---

# Web開発ルール
- React/Vue.jsコンポーネント設計
- CSS-in-JS vs CSS Modules
- バンドル最適化
- SEO対応
```

### Python/データサイエンス
```yaml
# .cursor/rules/python-rules.mdc
---
description: "Python/データサイエンス専用ルール"
globs: "**/*.{py,ipynb,sql,r}"
alwaysApply: false
---

# Python開発ルール
- Jupyter Notebook管理
- データ前処理パターン
- モデル評価手法
- 可視化ベストプラクティス
```

### モバイル開発
```yaml
# .cursor/rules/mobile-rules.mdc
---
description: "モバイル開発専用ルール"
globs: "**/*.{swift,kt,dart,java}"
alwaysApply: false
---

# モバイル開発ルール
- プラットフォーム固有設計
- パフォーマンス最適化
- ユーザビリティ考慮事項
- ストア申請要件
```

## 🤝 チーム導入戦略

### 段階的導入アプローチ

#### フェーズ1: 個人導入（1週間）
- [ ] 基本ファイルの更新
- [ ] 個人的な知識記録開始
- [ ] 効果の実感・検証

#### フェーズ2: チーム展開（2-3週間）
- [ ] チームメンバーへの説明・研修
- [ ] チーム共通ルールの策定
- [ ] 定期的な知識共有プロセス確立

#### フェーズ3: 組織展開（1-2ヶ月）
- [ ] 他チームへの横展開
- [ ] 組織標準としての確立
- [ ] 継続的改善プロセスの構築

### 成功のための重要ポイント

1. **継続的な更新**: テンプレートを実際の情報で更新し続ける
2. **チーム文化**: 知識共有を評価する文化の醸成
3. **効果測定**: 定量的・定性的効果の継続的測定
4. **改善サイクル**: PDCAサイクルによる継続的改善

## 🔄 継続的改善のプロセス

### 月次レビュー
```markdown
## 月次効果測定項目

### システム活用状況
- [ ] 各ファイルの更新頻度
- [ ] MDCルールの適用状況
- [ ] チームメンバーの活用度

### 効果測定
- [ ] 開発効率の変化
- [ ] バグ発生率の変化
- [ ] 知識共有の効果

### 改善計画
- [ ] 課題の特定と優先順位付け
- [ ] 具体的な改善アクション
- [ ] 次月の目標設定
```

### 品質管理
```markdown
## 知識品質管理チェックリスト

### 記録時の品質確認
- [ ] 5W1Hが明確に記載されている
- [ ] 他のメンバーが理解できる内容
- [ ] 再現可能な手順が記載されている
- [ ] 関連する他の記録との整合性

### 定期的な品質レビュー

月次でのシステム全体の品質確認を実施します。

#### レビュー項目
- 知識の正確性・最新性
- パターンの有効性
- ルールの適用状況
- チーム全体での活用状況
```

## 🔧 トラブルシューティング

### よくある問題と解決策

**Q: ルールが適用されない**
A: `.cursor/rules/`ディレクトリの場所とファイル拡張子（`.mdc`）を確認

**Q: 自動適用が働かない**
A: `globs`パターンとファイルパスが一致しているか確認

**Q: パフォーマンスが悪い**
A: `alwaysApply: true`のルールを最小限に抑制

**Q: テンプレートファイルが更新されない**
A: `templates/.cursor/`内のファイルを実際のプロジェクト情報で更新

## 📚 関連ドキュメント

- [クイックスタートガイド](docs/quick-start.md) - 5分で始める導入手順
- [チーム実装ガイド](docs/team-implementation-guide.md) - チーム導入の詳細プロセス
- [開発ログ](docs/development-log.md) - システム開発の記録

## 🤝 コミュニティ・リソース

### 学習リソース
- [Cursor AI公式ドキュメント](https://cursor.sh/docs)
- [MDC形式ガイド](https://modelcontextprotocol.io/)
- オープンソースコミュニティでの知見共有

### 貢献方法
- **GitHub Issues**: バグ報告・機能要望
- **GitHub Discussions**: 使用方法・ベストプラクティス共有
- **プルリクエスト**: 改善提案・ドキュメント更新

プルリクエスト、イシュー、機能提案を歓迎します！

1. リポジトリをフォーク
2. 機能ブランチを作成
3. 変更をコミット
4. プルリクエストを作成

## 📄 ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照

---

**⚠️ 重要な注意事項**: このシステムを効果的に活用するには、`templates/.cursor/`内のファイルを実際のプロジェクト情報で更新することが必須です。テンプレートのままでは自動参照の効果が得られず、知識管理システムとしての価値を発揮できません。