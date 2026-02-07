# スキルガイド

7 つのエージェントスキルの詳細な使い方を解説します。

## project-context

### 概要
プロジェクトの背景、制約、技術スタック、アーキテクチャに関する情報を提供するスキルです。

### 自動適用される場面
- 新機能の設計・実装方針の提案時
- 技術スタックに関する質問時
- アーキテクチャの議論時

### カスタマイズ方法
`references/CONTEXT_TEMPLATE.md` にプロジェクト情報を記入してください。

```markdown
## プロジェクト基本情報
| 項目 | 内容 |
|------|------|
| プロジェクト名 | My Awesome App |
| 目的 | ECサイトのリニューアル |
| 開始時期 | 2026-01 |
| チーム規模 | 5名 |

## 技術スタック
### フロントエンド
| 技術 | バージョン | 用途 |
|------|-----------|------|
| React | 19.x | UI フレームワーク |
| TypeScript | 5.x | 型安全性 |
```

### 連携コマンド
- `/update-context` - コンテキスト情報の更新

---

## team-standards

### 概要
コーディング規約、命名規則、ブランチ戦略等のチーム開発標準を提供するスキルです。

### 自動適用される場面
- コードレビュー時
- 新しいファイル作成時
- コミットメッセージの作成時

### カスタマイズ方法
`SKILL.md` の各セクションをプロジェクトの規約に合わせて編集してください。

例: 命名規則の変更
```markdown
#### 命名規則
- **変数・関数**: snake_case（Python プロジェクトの場合）
- **クラス**: PascalCase
- **定数**: UPPER_SNAKE_CASE
- **ファイル名**: snake_case.py
```

---

## knowledge-management

### 概要
技術判断の記録・参照・検索を管理するスキルです。

### 自動適用される場面
- 「なぜこの技術を選んだ？」等の質問時
- 技術選定の議論時
- 過去の決定を参照する場面

### 記録テンプレート

```markdown
### 2026-02-07 - フレームワーク選択

#### 判断内容
フロントエンドフレームワークの選択

#### 検討した選択肢
1. **React**
   - メリット: エコシステムが豊富、チーム経験あり
   - デメリット: ボイラープレートが多い
2. **Vue.js**
   - メリット: 学習コスト低、テンプレート構文
   - デメリット: チーム経験なし

#### 決定と理由
**決定**: React を採用
**理由**: チームの習熟度を優先

#### 影響範囲
- フロントエンド全体
- テスト戦略
```

### 自動化スクリプト
```bash
# エントリ追加
bash .cursor/skills/knowledge-management/scripts/add-entry.sh "フレームワーク選択"
```

### 連携コマンド
- `/record-decision` - 対話形式で技術判断を記録
- `/review-knowledge` - 知識ベースの定期レビュー

---

## pattern-library

### 概要
実装パターンの検索・適用・登録を管理するスキルです。

### 自動適用される場面
- 新機能の実装時
- 既存パターンの参照が必要なとき
- リファクタリング時

### 記録テンプレート

```markdown
## パターン名: API エラーハンドリング

> 登録日: 2026-02-07

### 目的
- **解決する問題**: API 呼び出しのエラー処理の統一
- **適用場面**: すべての外部 API 通信
- **期待効果**: エラーハンドリングの一貫性

### 実装例
\```typescript
const apiCall = async (endpoint: string) => {
  try {
    const response = await fetch(endpoint);
    if (!response.ok) throw new AppError(`API Error: ${response.status}`);
    return await response.json();
  } catch (error) {
    handleError(error);
    throw error;
  }
};
\```

### 使用上の注意
- **制約事項**: タイムアウト設定を忘れずに
- **パフォーマンス影響**: リトライ回数に注意
```

### 自動化スクリプト
```bash
# パターン追加
bash .cursor/skills/pattern-library/scripts/add-pattern.sh "API エラーハンドリング"
```

### 連携コマンド
- `/add-pattern` - 対話形式でパターンを登録

---

## debug-workflow

### 概要
デバッグプロセス全体を支援するスキルです。問題の特定から解決、記録までをカバーします。

### 自動適用される場面
- バグやエラーの調査時
- パフォーマンス問題の分析時
- 過去の類似問題を検索する場面

### デバッグセッションの流れ

1. `/start-debug` コマンドでセッション開始
2. 問題情報のヒアリング
3. 過去の類似問題を自動検索
4. 調査方針の提案
5. 解決策の記録
6. `/log-improvement` で再発防止策を記録

### 自動化スクリプト
```bash
# セッション作成
bash .cursor/skills/debug-workflow/scripts/create-session.sh "ログイン画面のエラー"

# 過去セッション検索
bash .cursor/skills/debug-workflow/scripts/search-sessions.sh "認証"
```

### 連携コマンド
- `/start-debug` - デバッグセッション開始
- `/log-improvement` - 解決後の改善記録

---

## improvement-tracking

### 概要
改善提案の記録・効果測定・追跡を管理するスキルです。

### 自動適用される場面
- リファクタリング後の効果測定時
- 技術的負債の議論時
- コードレビューでの改善提案時

### 記録テンプレート

```markdown
### 2026-02-07 - API レスポンスキャッシュ導入

#### 背景
頻繁にアクセスされる API のレスポンス時間が長い

#### 改善内容
Redis によるレスポンスキャッシュを導入

#### 効果
- **Before**: 平均 450ms
- **After**: 平均 50ms（キャッシュヒット時）
- **改善率**: 89%

#### ステータス
完了
```

### 自動化スクリプト
```bash
# 改善エントリ追加
bash .cursor/skills/improvement-tracking/scripts/add-improvement.sh "APIレスポンスキャッシュ導入"
```

### 連携コマンド
- `/log-improvement` - 改善内容を記録
- `/review-knowledge` - 改善の効果を定期レビュー

---

## project-setup

### 概要
新規プロジェクトへの知識管理システム導入を支援するスキルです。

### 使用場面
- 新プロジェクト作成時
- 既存プロジェクトへのシステム追加時

### セットアップ手順

```bash
# 自動セットアップ
bash path/to/templates/.cursor/skills/project-setup/scripts/init.sh /path/to/project

# 構造検証
bash .cursor/skills/project-setup/scripts/validate.sh
```

### 詳細
[クイックスタート](../getting-started/quick-start.md) を参照してください。
