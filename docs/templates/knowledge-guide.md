# knowledge.md テンプレート使用ガイド

このガイドでは、`templates/.cursor/knowledge.md` の詳細な使用方法と記載例を説明します。

## 📋 概要

`knowledge.md` は、プロジェクトで蓄積された技術的知見、設計判断、アーキテクチャ決定記録（ADR）などを記録するテンプレートです。チームの知識資産として活用し、一貫性のある開発を支援します。

## 🎯 設計判断の記録

### 設計判断記録 - 記載例

#### 2024-01-15 - 状態管理ライブラリの選定

##### 判断内容
React アプリケーションの状態管理ライブラリとして Redux Toolkit を採用

##### 検討した選択肢
1. **Redux Toolkit**
   - メリット: 豊富なエコシステム、デバッグツール充実、チームの既存知識
   - デメリット: 学習コスト、ボイラープレート
   - コスト: 中程度
   - 適用場面: 大規模アプリケーション

2. **Zustand**
   - メリット: シンプル、軽量、TypeScript サポート
   - デメリット: エコシステムが小さい、大規模での実績不足
   - コスト: 低
   - 適用場面: 中小規模アプリケーション

3. **Context API + useReducer**
   - メリット: 標準機能、追加依存なし
   - デメリット: 大規模アプリでのパフォーマンス問題
   - コスト: 低
   - 適用場面: 小規模アプリケーション

##### 決定内容と理由
**決定**: Redux Toolkit

**理由**: 
- チームの既存知識を活用できる
- 大規模アプリケーションでの実績が豊富
- デバッグツールが充実している
- 将来的な拡張性を考慮

##### 決定者・関与者
- **決定者**: テックリード（佐藤花子）
- **技術検討**: フロントエンド開発チーム全員
- **承認者**: プロジェクトマネージャー（田中太郎）
- **最終確認**: 2024-01-15

##### 影響範囲
- フロントエンド全体の状態管理
- 開発者の学習コスト（約2週間）
- プロジェクトの技術的負債
- 今後の採用・教育方針

##### 実装ガイドライン
```typescript
// Store設定例
import { configureStore } from '@reduxjs/toolkit';
import { userSlice } from './features/user/userSlice';
import { productSlice } from './features/product/productSlice';

export const store = configureStore({
  reducer: {
    user: userSlice.reducer,
    product: productSlice.reducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: ['persist/PERSIST'],
      },
    }),
});
```

##### .cursor/rules連携
- **関連パターン**: @.cursor/patterns.md で実装パターンを確認
- **デバッグ履歴**: @.cursor/debug-log.md で類似問題を検索
- **改善履歴**: @.cursor/improvements.md で過去の改善事例を参照

##### 見直し予定
- **次回レビュー**: 2024-07-15（6ヶ月後）
- **見直し条件**: パフォーマンス問題発生時、チーム構成変更時

##### タグ
`#状態管理` `#React` `#重要度高` `#アーキテクチャ`

## 🔧 技術パターン集

### APIエラーハンドリングパターン - 記載例

#### 概要
統一されたAPIエラーハンドリングとユーザーフィードバックの実装パターン

#### 使用場面
- API呼び出し時のエラー処理
- ユーザーへのエラー通知
- ログ記録とモニタリング
- リトライ機構の実装

#### 実装例
```typescript
// services/api.ts
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: ApiError;
}

export class ApiError extends Error {
  constructor(
    public status: number,
    public statusText: string,
    public code?: string
  ) {
    super(`API Error: ${status} ${statusText}`);
    this.name = 'ApiError';
  }
}

export const apiCall = async <T>(
  endpoint: string,
  options?: RequestInit
): Promise<ApiResponse<T>> => {
  try {
    const response = await fetch(endpoint, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
    });
    
    if (!response.ok) {
      throw new ApiError(response.status, response.statusText);
    }
    
    const data = await response.json();
    return { success: true, data };
  } catch (error) {
    console.error('API呼び出しエラー:', error);
    
    if (error instanceof ApiError) {
      return { success: false, error };
    }
    
    return { 
      success: false, 
      error: new ApiError(500, 'Unknown Error') 
    };
  }
};

// hooks/useApiCall.ts
export const useApiCall = <T>() => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<ApiError | null>(null);

  const execute = async (
    apiFunction: () => Promise<ApiResponse<T>>
  ): Promise<T | null> => {
    setLoading(true);
    setError(null);
    
    try {
      const response = await apiFunction();
      
      if (response.success && response.data) {
        return response.data;
      } else if (response.error) {
        setError(response.error);
        // ユーザー通知
        toast.error(getErrorMessage(response.error));
        return null;
      }
    } catch (err) {
      const apiError = new ApiError(500, 'Unexpected Error');
      setError(apiError);
      toast.error('予期しないエラーが発生しました');
      return null;
    } finally {
      setLoading(false);
    }
    
    return null;
  };

  return { execute, loading, error };
};
```

#### メリット・デメリット
**メリット**:
- 一貫したエラー処理
- デバッグの容易さ
- ユーザー体験の向上
- 保守性の向上

**デメリット**:
- 初期実装コスト
- パターンの学習コスト
- 過度な抽象化のリスク

#### 注意点
- エラーメッセージの国際化対応
- セキュリティ情報の漏洩防止
- 適切なログレベルの設定
- リトライ回数の制限

#### .cursor/rules自動適用条件
- **対象ファイル**: `**/*.{ts,tsx,js,jsx}`
- **適用タイミング**: API関連ファイル編集時に自動参照
- **関連ルール**: `.cursor/rules/api-patterns.mdc`

#### 関連パターン
- [認証エラーハンドリング] - @.cursor/patterns.md で詳細確認
- [リトライ機構] - @.cursor/patterns.md で比較検討
- [ローディング状態管理] - @.cursor/knowledge.md で実装例確認

#### 更新履歴
- 2024-01-10: 初版作成
- 2024-01-20: リトライ機構追加
- 2024-02-01: TypeScript型定義強化
```

## 📋 ADR (Architecture Decision Record)

### ADR記録 - 記載例


## アーキテクチャ決定記録 (ADR: Architecture Decision Record)

### ADR-001: マイクロフロントエンド アーキテクチャの採用

#### ステータス
承認済み（2024-01-20）

#### コンテキスト
大規模なWebアプリケーションで複数チームが並行開発を行う必要がある

**背景情報**:
- **プロジェクト状況**: @.cursor/context.md で背景確認
- **技術制約**: 既存のモノリシックフロントエンドの限界
- **チーム状況**: 5つの開発チームが独立して開発
- **ビジネス要件**: 機能ごとの独立デプロイが必要

**現在の問題**:
- デプロイ時の相互依存
- チーム間の開発速度の差
- 技術スタックの統一による制約
- 大規模なビルド時間

#### 検討した選択肢
1. **モノリシック構成の継続**
   - メリット: シンプル、既存知識活用
   - デメリット: スケーラビリティの問題
   - リスク: 開発効率の低下

2. **マイクロフロントエンド（Module Federation）**
   - メリット: チーム独立性、技術選択の自由度
   - デメリット: 複雑性の増加、運用コスト
   - リスク: 初期学習コスト

3. **マイクロフロントエンド（Single-SPA）**
   - メリット: 成熟したフレームワーク
   - デメリット: 設定の複雑さ
   - リスク: ベンダーロックイン

#### 決定内容
Module Federation を使用したマイクロフロントエンド アーキテクチャを採用

**技術仕様**:
```javascript
// webpack.config.js (Shell App)
const ModuleFederationPlugin = require('@module-federation/webpack');

module.exports = {
  plugins: [
    new ModuleFederationPlugin({
      name: 'shell',
      remotes: {
        userModule: 'userModule@http://localhost:3001/remoteEntry.js',
        productModule: 'productModule@http://localhost:3002/remoteEntry.js',
      },
    }),
  ],
};

// webpack.config.js (Remote App)
module.exports = {
  plugins: [
    new ModuleFederationPlugin({
      name: 'userModule',
      filename: 'remoteEntry.js',
      exposes: {
        './UserApp': './src/App',
        './UserRoutes': './src/routes',
      },
    }),
  ],
};
```

#### 結果・影響
**プラス面**: 
- チーム間の独立性向上（開発速度20%向上）
- デプロイの独立性（デプロイ頻度3倍増加）
- 技術スタックの柔軟性
- 障害の局所化

**マイナス面**: 
- 複雑性の増加（学習コスト2週間）
- 運用コストの増加（インフラ費用15%増）
- パフォーマンスオーバーヘッド（初期ロード5%増）

**中立面**: 
- 学習コストの発生
- 初期セットアップの時間（3週間）
- 監視・デバッグツールの整備が必要

#### 実装ガイドライン
1. **共通ライブラリの管理**
   - React, React-DOM は Shell App で提供
   - 共通コンポーネントは専用パッケージで管理

2. **通信方式**
   - イベントバス経由での通信
   - 共有状態は最小限に抑制

3. **デプロイ戦略**
   - 各マイクロフロントエンドは独立デプロイ
   - Shell App は最後にデプロイ

#### .cursor/rules連携効果
- **自動適用**: 関連ファイル編集時に自動的にこの決定が参照される
- **一貫性確保**: team-standards.mdcにより決定内容が自動的に適用される
- **知見蓄積**: 実装過程での問題は @.cursor/debug-log.md に自動記録

#### 関連するADR
- ADR-002: [共通コンポーネントライブラリの設計]
- ADR-003: [マイクロフロントエンド間通信方式]

#### 見直し条件
- パフォーマンス問題が深刻化した場合
- チーム構成が大幅に変更された場合
- 運用コストが予算を大幅に超過した場合

#### 次回レビュー
2024-07-20（6ヶ月後）
```

## 🔄 .cursor/rules との連携

### 自動参照設定例

```yaml
---
description: "技術的知見の自動参照"
globs: "src/**/*.{ts,tsx}"
alwaysApply: false
---

# 技術的知見の活用
@.cursor/knowledge.md を参照して、過去の設計判断と技術パターンを考慮した提案を行う

## 設計判断の一貫性
- 状態管理: Redux Toolkit を使用
- API通信: 統一されたエラーハンドリングパターンを適用
- コンポーネント設計: 再利用可能な設計を優先

## 技術パターンの適用
- エラーハンドリング: ApiError クラスを使用
- 非同期処理: useApiCall フックを活用
- 型定義: 明示的な型定義を実施
```

## 📝 記載のベストプラクティス

### 1. 構造化された記録
- **一貫したフォーマット**: テンプレートに従った記載
- **明確な分類**: 設計判断、技術パターン、ADRの区別
- **適切なタグ付け**: 検索性を向上させるタグの活用

### 2. 具体性と詳細性
- **具体的な実装例**: コードサンプルの提供
- **定量的な評価**: 数値による効果測定
- **明確な責任者**: 決定者と関与者の明記

### 3. 継続的な更新
- **定期的な見直し**: 決定内容の妥当性確認
- **新しい知見の追加**: 学習した内容の蓄積
- **古い情報の整理**: 不要になった情報の削除

---

このガイドを参考に、チームの技術的知見を効果的に蓄積し、一貫性のある開発を実現してください。 
