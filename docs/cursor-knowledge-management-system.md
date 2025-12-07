# Cursor AI 知識管理システム 完全ガイド

## 概要

Cursor AI 知識管理システムは、AI支援開発における知識の蓄積・活用・共有を効率化するためのフレームワークです。`.cursor/rules`形式を活用し、プロジェクト固有の知見を体系的に管理します。

## 🎯 システムの目的と価値

### 解決する課題
- **属人化**: 個人の知見がチーム全体で共有されない
- **重複作業**: 同じ問題を何度も調査・解決
- **知識の散逸**: プロジェクト終了後に知見が失われる
- **品質のばらつき**: 開発者によるコード品質の差

### 提供する価値
- **知識の体系化**: 技術判断・設計パターンの構造化された管理
- **自動参照**: AI支援による適切な知識の自動適用
- **継続的改善**: 失敗・成功事例の蓄積による品質向上
- **チーム標準化**: 一貫した開発プロセスの確立

## 🏗️ システム設計思想

### .cursor/rules形式採用の理由
- **公式サポート**: Cursor AI公式の`.cursor/rules`形式
- **柔軟な制御**: 条件付き自動適用による効率化
- **拡張性**: 将来の機能追加への対応力
- **保守性**: 構造化された設定による管理容易性

### 4つのルールタイプ

| ルールタイプ | 設定 | 動作 | 使用例 |
|-------------|------|------|--------|
| **Always Rules** | `alwaysApply: true` | 常に適用 | チーム標準・コーディング規約 |
| **Auto Rules** | `globs: "pattern"` | ファイルマッチで自動適用 | TypeScript専用ルール |
| **Agent Rules** | `description: "詳細"` | AI判断で適用 | 複雑な条件判断 |
| **Manual Rules** | 全て空白 | 手動参照のみ | 特殊な状況用 |

### .cursor/rules設定例
```yaml
---
description: "TypeScript開発時の品質管理ルール"
globs: "**/*.{ts,tsx}"
alwaysApply: false
---

# TypeScript開発ルール
- 型安全性の確保
- ESLint/Prettier準拠
- テストカバレッジの維持
```

## 📁 システム構成

### 基本構造
```
.cursor/
├── knowledge.md              # 技術判断・設計決定の記録
├── patterns.md               # 共通パターン・テンプレート
├── context.md                # プロジェクト背景・制約
├── debug-log.md              # デバッグ履歴・問題解決記録
├── improvements.md           # 改善履歴・最適化記録
└── rules/                    # .cursor/rules設定
    ├── knowledge-management.mdc
    ├── project-context.mdc
    ├── debug-workflow.mdc
    ├── debug-support.mdc
    ├── improvement-tracking.mdc
    ├── patterns-library.mdc
    └── team-standards.mdc
```

### 実際のプロジェクトでの配置
```
your-project/
├── .cursor/             # ← templates/.cursor/ をコピー
│   ├── knowledge.md    # 実際のプロジェクト情報で更新
│   ├── patterns.md     # 実際のプロジェクト情報で更新
│   ├── context.md      # 実際のプロジェクト情報で更新
│   └── rules/          # .cursor/rules（Cursorが認識）
├── .cursorignore       # ← templates/.cursorignore をコピー
└── src/                # プロジェクトファイル
```

## 🔧 知識管理の方法論

### 技術判断の記録方法
```markdown
### YYYY-MM-DD - 判断タイトル
#### 判断内容
具体的な選択内容

#### 検討した選択肢
1. **選択肢A**
   - メリット: 
   - デメリット: 
   - 結果: 採用/不採用

#### 理由
判断の根拠と背景
```

### 設計パターンの蓄積
```markdown
## パターン名
### 適用場面
どのような状況で使用するか

### 実装例
```typescript
// 具体的なコード例
```

### 注意点
使用時の注意事項
```

### デバッグ履歴の活用
```markdown
### YYYY-MM-DD - 問題タイトル
#### 現象
発生した問題の詳細

#### 原因
根本原因の分析

#### 解決方法
実際の解決手順

#### 予防策
再発防止のための対策
```

## 📊 効果測定と改善

### 定量的指標
- **開発効率**: タスク完了時間の短縮
- **品質向上**: バグ発生率の削減
- **知識定着**: 同じ問題の再発生率
- **チーム成長**: 新人のオンボーディング時間

### 定性的効果
- 技術判断の一貫性向上
- チーム内知識共有の促進
- 開発品質の標準化
- 継続的改善文化の醸成

*注: 具体的な効果は各プロジェクト・チームの状況により異なります*

## 🎯 プロジェクト種別別カスタマイズ

### Web開発プロジェクト
- フロントエンド/バックエンド分離
- API設計パターンの重視
- パフォーマンス最適化の記録

### モバイルアプリ開発
- プラットフォーム固有の制約
- UI/UXパターンの蓄積
- デバイス対応の記録

### データ分析プロジェクト
- データ処理パイプラインの設計
- 分析手法の選択理由
- パフォーマンス最適化の記録

## 🔄 継続的改善のサイクル

1. **記録**: 日々の技術判断・パターンの蓄積
2. **分析**: 定期的な振り返りと効果測定
3. **改善**: システム・プロセスの最適化
4. **共有**: チーム全体での知見の展開

## ✅ 品質チェック（推奨）

- **リンクチェック**: `npx markdown-link-check README.md CHANGELOG.md docs/**/*.md`
- **.mdc frontmatter検証**: `description/globs/alwaysApply` の有無をスクリプトで確認
- **実行タイミング**: 週次レビューやリリース前に実施

## 📚 関連リソース

### 基本ガイド
- [クイックスタートガイド](getting-started/quick-start.md) - 実際の導入手順
- [チーム導入ガイド](advanced/team-implementation.md) - チーム全体での活用

### テンプレート使用ガイド
- [テンプレート使用ガイド](templates/overview.md) - 概要とナビゲーション
- [context.md ガイド](templates/context-guide.md) - プロジェクト情報の記載方法
- [patterns.md ガイド](templates/patterns-guide.md) - 共通パターンの記録方法
- [knowledge.md ガイド](templates/knowledge-guide.md) - 技術的知見の蓄積方法
- [debug-log.md ガイド](templates/debug-guide.md) - 問題解決の記録方法
- [improvements.md ガイド](templates/improvements-guide.md) - 改善活動の記録方法

### 開発情報
- [開発ログ](reference/development-log.md) - システム開発の記録

---

**導入・活用方法の詳細は各専用ガイドを参照してください。**