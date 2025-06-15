# クイックスタートガイド

## 🚀 Cursor知識管理システムの導入手順

このガイドでは、Cursor AI知識管理システムの詳細な導入手順を説明します。

### ステップ1: リポジトリのクローン
```bash
git clone https://github.com/your-username/cursor-knowledge-management-system.git
cd cursor-knowledge-management-system
```

## 📋 必須更新ファイルの詳細

### 🔥 **知識管理ファイル（最重要）**

#### templates/.cursor/knowledge.md
**目的**: 技術判断・設計決定の記録
**更新例**:
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

#### templates/.cursor/patterns.md
**目的**: 設計パターン・実装テンプレートの記録
**更新例**:
```markdown
# 設計パターン・実装テンプレート（あなたのプロジェクト名）

## コンポーネント設計パターン
### Atomic Design適用
- Atoms: Button, Input, Label
- Molecules: SearchBox, FormField
- Organisms: Header, ProductList

## API設計パターン
### REST API レスポンス形式
```typescript
interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  timestamp: string;
}
```
```

#### templates/.cursor/context.md
**目的**: プロジェクト背景・制約の記録
**更新例**:
```markdown
# プロジェクト背景・制約（あなたのプロジェクト名）

## プロジェクト概要
- **目的**: ECサイトの構築
- **期間**: 3ヶ月
- **チーム**: フロントエンド2名、バックエンド2名

## 技術制約
- **フロントエンド**: React必須（チームスキル）
- **バックエンド**: Node.js推奨
- **データベース**: PostgreSQL
- **インフラ**: AWS

## 品質基準
- **テストカバレッジ**: 適切なレベル以上
- **コードレビュー**: 必須（複数名以上）
```

### 📝 **プロジェクト基本情報**

#### README.md
- プロジェクト名を実際の名前に変更
- 概要を実際のプロジェクト内容に更新
- GitHubリポジトリURLを正しいものに変更

#### package.json（Node.jsプロジェクトの場合）
```json
{
  "name": "your-actual-project-name",
  "description": "your actual project description",
  "author": "your name",
  "repository": "your-repo-url"
}
```

## ⏱️ 更新作業の時間目安

### 最小限の更新（10分）
1. README.md のプロジェクト名を変更
2. templates/.cursor/knowledge.md をプロジェクト用に書き換え

### 推奨更新（20分）
上記に加えて：
3. templates/.cursor/context.md 更新
4. 使用言語に応じたルール調整

### フル活用（30分）
上記すべてに加えて：
5. templates/.cursor/patterns.md の詳細記録
6. チーム開発ルールの策定
7. 全templatesファイルの実プロジェクト情報での更新

## 🔧 使用方法の詳細

### 1. 基本的な知識記録
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

### 2. 自動参照の確認
AIとの対話で以下のように参照されることを確認：
```
@.cursor/knowledge.md @.cursor/patterns.md
「ユーザー認証機能を実装してください」
```

### 3. MDCルールの活用
```yaml
---
description: "TypeScript開発時の品質管理ルール"
globs: "**/*.{ts,tsx}"
alwaysApply: false
---

# TypeScript開発ルール
- 型安全性の確保
- ESLint/Prettier準拠
- テストカバレッジ適切なレベル以上
```

## ⚡ 効果的な活用のコツ

### 1. 継続的な更新
- 新しい技術判断があるたびに記録
- 週1回の振り返りで知識を整理
- 失敗事例も積極的に記録

### 2. チーム共有
- 重要な判断は必ずknowledge.mdに記録
- パターンは再利用可能な形で記録
- 定期的なレビューでチーム知識を統一

### 3. 自動化の活用
- MDCルールで自動参照を設定
- ファイルパターンに応じた自動適用
- AI判断による適切なルール選択

## 📊 進捗確認のチェックリスト

### 短期（1週間）
- [ ] 基本ファイルの更新完了
- [ ] 最初の技術判断を記録
- [ ] AIとの対話で自動参照を確認

### 中期（1ヶ月）
- [ ] 10件以上の知識記録
- [ ] 5つ以上のパターン蓄積
- [ ] チーム内での知識共有開始

### 長期（3ヶ月）
- [ ] システムの継続的活用
- [ ] 一貫した設計判断の実現
- [ ] 新メンバーのオンボーディング支援

## 🔄 次のステップ

1. **[チーム導入ガイド](team-implementation-guide.md)** - チーム全体での活用
2. **[開発ログ](development-log.md)** - システム開発の詳細記録
3. **継続的改善** - 定期的な振り返りと改善

## 🔧 トラブルシューティング

### よくある問題

**Q: ルールが適用されない**
A: `.cursor/rules/`ディレクトリの場所とファイル拡張子（`.mdc`）を確認

**Q: 自動適用が働かない**
A: `globs`パターンとファイルパスが一致しているか確認

**Q: テンプレートファイルが更新されない**
A: `templates/.cursor/`内のファイルを実際のプロジェクト情報で更新

---

**⚠️ 重要**: このシステムを効果的に活用するには、`templates/.cursor/`内のファイルを実際のプロジェクト情報で更新することが必須です。テンプレートのままでは自動参照の効果が得られません。 