# テンプレートファイル使用ガイド

このガイドでは、`templates/.cursor/` 内のテンプレートファイルの詳細な使用方法と記載例を説明します。

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

## 📚 knowledge.md の使用方法

### 設計判断の記録 - 記載例

```markdown
## 設計判断の記録

### 2024-01-15 - 状態管理ライブラリの選定

#### 判断内容
React アプリケーションの状態管理ライブラリとして Redux Toolkit を採用

#### 検討した選択肢
1. **Redux Toolkit**
   - メリット: 豊富なエコシステム、デバッグツール充実
   - デメリット: 学習コスト、ボイラープレート
   - コスト: 中程度

2. **Zustand**
   - メリット: シンプル、軽量、TypeScript サポート
   - デメリット: エコシステムが小さい
   - コスト: 低

3. **Context API + useReducer**
   - メリット: 標準機能、追加依存なし
   - デメリット: 大規模アプリでのパフォーマンス問題
   - コスト: 低

#### 決定内容と理由
**決定**: Redux Toolkit
**理由**: 
- チームの既存知識を活用できる
- 大規模アプリケーションでの実績
- デバッグツールの充実

#### 決定者・関与者
- **決定者**: テックリード
- **技術検討**: フロントエンド開発チーム
- **承認者**: プロジェクトマネージャー

#### 影響範囲
- フロントエンド全体の状態管理
- 開発者の学習コスト
- プロジェクトの技術的負債

#### .cursor/rules連携
- **関連パターン**: @.cursor/patterns.md で実装パターンを確認
- **デバッグ履歴**: @.cursor/debug-log.md で類似問題を検索
- **改善履歴**: @.cursor/improvements.md で過去の改善事例を参照

#### タグ
`#状態管理` `#React` `#重要度高`
```

### 技術パターン集 - 記載例

```markdown
## 技術パターン集

### API エラーハンドリングパターン

#### 概要
統一されたAPIエラーハンドリングとユーザーフィードバック

#### 使用場面
- API呼び出し時のエラー処理
- ユーザーへのエラー通知
- ログ記録とモニタリング

#### 実装例
```typescript
// services/api.ts
export const apiCall = async <T>(
  endpoint: string,
  options?: RequestInit
): Promise<ApiResponse<T>> => {
  try {
    const response = await fetch(endpoint, options);
    
    if (!response.ok) {
      throw new ApiError(response.status, response.statusText);
    }
    
    const data = await response.json();
    return { success: true, data };
  } catch (error) {
    console.error('API呼び出しエラー:', error);
    return { 
      success: false, 
      error: error instanceof ApiError ? error : new UnknownError() 
    };
  }
};
```

#### メリット・デメリット
**メリット**:
- 一貫したエラー処理
- デバッグの容易さ
- ユーザー体験の向上

**デメリット**:
- 初期実装コスト
- パターンの学習コスト

#### 注意点
- エラーメッセージの国際化対応
- セキュリティ情報の漏洩防止
- 適切なログレベルの設定

#### .cursor/rules自動適用条件
- **対象ファイル**: `**/*.{ts,tsx,js,jsx}`
- **適用タイミング**: API関連ファイル編集時に自動参照
- **関連ルール**: `.cursor/rules/api-patterns.mdc`

#### 関連パターン
- [認証エラーハンドリング] - @.cursor/patterns.md で詳細確認
- [リトライ機構] - @.cursor/patterns.md で比較検討
```

### ADR (Architecture Decision Record) - 記載例

```markdown
## アーキテクチャ決定記録 (ADR: Architecture Decision Record)

### ADR-001: マイクロフロントエンド アーキテクチャの採用

#### ステータス
承認済み

#### コンテキスト
大規模なWebアプリケーションで複数チームが並行開発を行う必要がある
- **プロジェクト状況**: @.cursor/context.md で背景確認
- **技術制約**: 既存のモノリシックフロントエンドの限界
- **チーム状況**: 5つの開発チームが独立して開発

#### 決定内容
Module Federation を使用したマイクロフロントエンド アーキテクチャを採用

#### 結果
**プラス面**: 
- チーム間の独立性向上
- デプロイの独立性
- 技術スタックの柔軟性

**マイナス面**: 
- 複雑性の増加
- 運用コストの増加
- パフォーマンスオーバーヘッド

**中立面**: 
- 学習コストの発生
- 初期セットアップの時間

#### .cursor/rules連携効果
- **自動適用**: 関連ファイル編集時に自動的にこの決定が参照される
- **一貫性確保**: team-standards.mdcにより決定内容が自動的に適用される
- **知見蓄積**: 実装過程での問題は @.cursor/debug-log.md に自動記録

#### 関連するADR
- ADR-002: [共通コンポーネントライブラリの設計]
```

---

## 🔧 patterns.md の使用方法

### .cursor/rules活用パターン - 記載例

```markdown
## .cursor/rules活用パターン

### 基本的な知見参照パターン
```
# .cursor/rules形式での知見参照（自動適用）
@.cursor/knowledge.md @.cursor/patterns.md
「認証機能を実装してください」
→ 過去の類似実装パターンが自動的に参照される
→ 設計判断の一貫性が保たれる
→ 実装品質が向上する
```

### .cursor/rules設定例
```yaml
---
description: "認証機能の実装パターン"
globs: "src/auth/**/*.{ts,tsx}"
alwaysApply: false
---

# 認証実装パターン
## JWT トークン管理
- アクセストークンの自動更新
- リフレッシュトークンの安全な保存
- トークン期限切れ時の処理

## 認証状態管理
- ログイン状態の永続化
- 認証エラーの統一処理
- 権限チェックの実装
```
```

### 環境別コマンド集 - 記載例

```markdown
## 環境別コマンド集

### Windows (PowerShell) - プロジェクト固有
```powershell
# 開発環境セットアップ
npm install
cp .env.example .env.local
npm run db:migrate

# 開発サーバー起動
npm run dev

# テスト実行
npm test
npm run test:e2e

# ビルド・デプロイ
npm run build
npm run deploy:staging
```

### macOS/Linux (Bash) - プロジェクト固有
```bash
# 開発環境セットアップ
npm install
cp .env.example .env.local
npm run db:migrate

# 開発サーバー起動
npm run dev

# テスト実行
npm test
npm run test:e2e

# ビルド・デプロイ
npm run build
npm run deploy:staging
```
```

### 実装テンプレート - 記載例

```markdown
## 実装テンプレート

### React コンポーネント実装テンプレート

#### ファイル構成
```
src/components/UserProfile/
├── index.ts                    # エクスポート
├── UserProfile.tsx            # メインコンポーネント
├── UserProfile.test.tsx       # テスト
├── UserProfile.stories.tsx    # Storybook
├── UserProfile.module.css     # スタイル
└── types.ts                   # 型定義
```

#### 実装手順
1. 型定義作成 (`types.ts`)
2. メインコンポーネント実装 (`UserProfile.tsx`)
3. テスト作成 (`UserProfile.test.tsx`)
4. Storybook 作成 (`UserProfile.stories.tsx`)
5. スタイリング適用 (`UserProfile.module.css`)
6. エクスポート設定 (`index.ts`)

#### コード例
```typescript
// types.ts
export interface UserProfileProps {
  user: User;
  onEdit?: (user: User) => void;
  isEditable?: boolean;
}

// UserProfile.tsx
import React from 'react';
import { UserProfileProps } from './types';
import styles from './UserProfile.module.css';

export const UserProfile: React.FC<UserProfileProps> = ({
  user,
  onEdit,
  isEditable = false
}) => {
  return (
    <div className={styles.container}>
      <img src={user.avatar} alt={user.name} className={styles.avatar} />
      <h2 className={styles.name}>{user.name}</h2>
      <p className={styles.email}>{user.email}</p>
      {isEditable && onEdit && (
        <button onClick={() => onEdit(user)} className={styles.editButton}>
          編集
        </button>
      )}
    </div>
  );
};
```
```

---

## 🌐 context.md の使用方法

### プロジェクト基本情報 - 記載例

```markdown
## プロジェクト基本情報

### 基本情報
- **プロジェクト名**: ECサイト管理システム
- **開始日**: 2024-01-01
- **想定終了日**: 2024-06-30
- **プロジェクトタイプ**: Webアプリケーション
- **対象ユーザー**: ECサイト運営者、管理者

### ビジネス目標
- 既存システムの老朽化対応
- 運営効率の向上（30%削減目標）
- ユーザビリティの改善
- モバイル対応の実現
```

### 技術スタック - 記載例

```markdown
## 技術スタック

### フロントエンド
- **フレームワーク**: React 18.2.0
- **言語**: TypeScript 5.0
- **状態管理**: Redux Toolkit
- **スタイリング**: Tailwind CSS
- **テスト**: Jest, React Testing Library

### バックエンド
- **ランタイム**: Node.js 18.x
- **フレームワーク**: Express.js
- **言語**: TypeScript
- **ORM**: Prisma
- **認証**: JWT + Passport.js

### データベース
- **メイン**: PostgreSQL 15
- **キャッシュ**: Redis 7.0
- **検索**: Elasticsearch 8.0

### インフラ
- **クラウド**: AWS
- **コンテナ**: Docker + ECS
- **CI/CD**: GitHub Actions
- **監視**: CloudWatch + Datadog
```

### アーキテクチャ概要 - 記載例

```markdown
## アーキテクチャ概要

### システム構成
```
[Frontend (React)] 
       ↓
[API Gateway] 
       ↓
[Backend Services (Node.js)]
       ↓
[Database (PostgreSQL)]
```

### 主要コンポーネント
- **Web Frontend**: React SPA
- **API Server**: RESTful API + GraphQL
- **Authentication Service**: JWT ベース認証
- **File Storage**: AWS S3
- **Background Jobs**: Bull Queue + Redis

### セキュリティ設計
- HTTPS 通信の強制
- CORS 設定
- Rate Limiting
- SQL Injection 対策
- XSS 対策
```

---

## 🐛 debug-log.md の使用方法

### 問題・エラーログ - 記載例

```markdown
## 問題・エラーログ

### 2024-01-15 - npm install でパッケージインストールが失敗

#### 問題の詳細
新しいプロジェクトで `npm install` を実行すると、特定のパッケージのインストールが失敗し、プロジェクトのセットアップができない。

#### 発生環境
- **OS**: Windows 11
- **Node.js**: v18.17.0
- **npm**: v9.6.7
- **プロジェクト**: React + TypeScript

#### エラーメッセージ
```
npm ERR! code ERESOLVE
npm ERR! ERESOLVE unable to resolve dependency tree
npm ERR! 
npm ERR! While resolving: my-project@0.1.0
npm ERR! Found: react@18.2.0
npm ERR! node_modules/react
npm ERR!   react@"^18.2.0" from the root project
```

#### 調査手順
1. エラーメッセージをGoogle検索
2. package.json の依存関係を確認
3. npm cache の確認・クリア
4. node_modules と package-lock.json の削除・再インストール

#### 解決方法
```bash
# キャッシュクリア
npm cache clean --force

# 既存ファイル削除
rm -rf node_modules package-lock.json

# 再インストール
npm install --legacy-peer-deps
```

#### 根本原因
React 18 と一部のライブラリの peer dependency の競合

#### 予防策
- package.json 作成時に依存関係の互換性を事前確認
- `--legacy-peer-deps` フラグの使用を検討

#### 参考リンク
- https://docs.npmjs.com/cli/v8/using-npm/dependency-resolution
- https://github.com/npm/cli/issues/4232

#### メタ情報
- **発見者**: 開発者A
- **総調査時間**: 45分
- **影響範囲**: 新規プロジェクトセットアップ
- **重要度**: 中
- **タグ**: `#環境構築` `#npm` `#依存関係`
```

### パフォーマンス問題 - 記載例

```markdown
## パフォーマンス問題

### 2024-01-20 - ユーザーリストページの表示が重い

#### 問題の詳細
1000件以上のユーザーデータを表示する際に、ページの読み込みが遅く、スクロールも重い状態。

#### パフォーマンス測定結果
- **初期表示**: 3.2秒 → 目標: 1秒以下
- **スクロール**: 15fps → 目標: 60fps
- **メモリ使用量**: 150MB → 目標: 100MB以下

#### 原因分析
1. 全データの一括レンダリング
2. 不要な再レンダリングの発生
3. 画像の最適化不足

#### 解決策
1. **仮想スクロールの導入**
   ```typescript
   import { FixedSizeList as List } from 'react-window';
   
   const UserList = ({ users }) => (
     <List
       height={600}
       itemCount={users.length}
       itemSize={80}
       itemData={users}
     >
       {UserItem}
     </List>
   );
   ```

2. **React.memo の活用**
   ```typescript
   const UserItem = React.memo(({ user }) => {
     // コンポーネント実装
   });
   ```

3. **画像の遅延読み込み**
   ```typescript
   const UserAvatar = ({ src, alt }) => (
     <img 
       src={src} 
       alt={alt} 
       loading="lazy"
       className="w-12 h-12 rounded-full"
     />
   );
   ```

#### 改善結果
- **初期表示**: 3.2秒 → 0.8秒
- **スクロール**: 15fps → 60fps
- **メモリ使用量**: 150MB → 80MB

#### タグ
`#パフォーマンス` `#React` `#仮想スクロール` `#重要度高`
```

---

## 📈 improvements.md の使用方法

### 改善提案 - 記載例

```markdown
## 改善提案

### 2024-01-25 - TypeScript strict モードの有効化

#### 改善の背景
現在のプロジェクトでは TypeScript の strict モードが無効になっており、型安全性が不十分。ランタイムエラーの発生リスクが高い。

#### 現在の問題
- `any` 型の多用
- null/undefined チェックの不備
- 型推論の不正確性
- IDE の補完機能が十分に活用できない

#### 提案する改善内容
1. `tsconfig.json` で strict モードを有効化
2. 既存コードの段階的な型修正
3. ESLint ルールの追加
4. 型定義ファイルの整備

#### 期待される効果
- **品質向上**: ランタイムエラーの削減
- **開発効率**: IDE補完の向上
- **保守性**: コードの可読性向上
- **チーム**: 型安全性の意識向上

#### 実装計画
1. **Phase 1**: 新規ファイルから strict モード適用
2. **Phase 2**: 既存ファイルの段階的修正
3. **Phase 3**: 全ファイルの strict モード対応完了

#### 所要時間見積もり
- **Phase 1**: 1週間
- **Phase 2**: 3週間
- **Phase 3**: 1週間
- **合計**: 5週間

#### リスク・懸念事項
- 既存コードの大幅修正が必要
- 一時的な開発速度の低下
- チームメンバーの学習コスト

#### 対策
- 段階的な導入でリスクを最小化
- 型定義のベストプラクティス共有
- ペアプログラミングでの知識共有

#### タグ
`#品質改善` `#TypeScript` `#技術的負債` `#重要度高`
```

### 実装済み改善 - 記載例

```markdown
## 実装済み改善

### 2024-01-10 - CI/CD パイプラインの自動化

#### 改善の背景
手動デプロイによる人的ミスとデプロイ時間の長さが課題となっていた。

#### 改善前の状況
- **デプロイ時間**: 30分（手動作業）
- **エラー率**: 月2-3回のデプロイミス
- **作業負荷**: 開発者の手動作業が必要

#### 改善内容
GitHub Actions を使用した自動 CI/CD パイプラインの構築

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm ci
      - name: Run tests
        run: npm test
      - name: Run E2E tests
        run: npm run test:e2e

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to AWS
        run: |
          npm run build
          aws s3 sync dist/ s3://${{ secrets.S3_BUCKET }}
          aws cloudfront create-invalidation --distribution-id ${{ secrets.CLOUDFRONT_ID }}
```

#### 改善後の効果
- **デプロイ時間**: 30分 → 5分（83%短縮）
- **エラー率**: 月2-3回 → 0回
- **作業負荷**: 手動作業 → 完全自動化
- **品質**: 自動テストによる品質保証

#### 実装方法
1. GitHub Actions ワークフローの作成
2. AWS IAM ロールの設定
3. シークレット情報の設定
4. テスト環境での動作確認
5. 本番環境への適用

#### 参考情報
- https://docs.github.com/en/actions
- https://docs.aws.amazon.com/cli/

#### メタ情報
- **実施者**: DevOpsエンジニア
- **所要時間**: 2日
- **影響範囲**: 全体のデプロイプロセス
- **効果測定**: デプロイ時間とエラー率で測定

#### タグ
`#CI/CD` `#自動化` `#効率化` `#大幅改善`
```

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

このガイドを参考に、プロジェクトに適した知識管理システムを構築してください。 