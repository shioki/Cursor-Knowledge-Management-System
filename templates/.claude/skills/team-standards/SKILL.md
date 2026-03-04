---
name: team-standards
description: コーディング規約、命名規則、ブランチ戦略、コミットメッセージ規約、コードレビュー基準について質問があった場合に使用。チーム開発の標準を提供する。
compatibility: Cursor, Claude Code
---

# チーム開発標準

チーム全体で一貫した開発プロセスを維持するための標準規約を提供するスキルです。

## When to Use

- コーディング規約や命名規則について質問があったとき
- コードレビューを行うとき
- ブランチ戦略やコミットメッセージについて質問があったとき
- 新しいチームメンバーのオンボーディング時

## Instructions

以下の規約に従ってコードレビューや提案を行ってください。

### コーディング規約

#### 命名規則
- **変数・関数**: camelCase（例: `getUserData`, `isValid`）
- **クラス・コンポーネント**: PascalCase（例: `UserService`, `LoginForm`）
- **定数**: UPPER_SNAKE_CASE（例: `MAX_RETRY_COUNT`, `API_BASE_URL`）
- **ファイル名**: kebab-case（例: `user-service.ts`, `login-form.tsx`）

#### コメント規約
```typescript
/**
 * 関数の説明
 * @param {type} paramName - パラメータの説明
 * @returns {type} 戻り値の説明
 * @example
 * const result = functionName(param);
 */
function functionName(paramName: type): returnType {
  // 実装の詳細説明（必要に応じて）
  return result;
}
```

#### インポート順序
```typescript
// 1. 外部ライブラリ
import React from 'react';
import axios from 'axios';

// 2. 内部ライブラリ・ユーティリティ
import { utils } from '@/lib/utils';
import { config } from '@/config';

// 3. 相対インポート
import './component.css';
import { LocalComponent } from './LocalComponent';
```

### 開発フロー

#### ブランチ戦略
- **main**: 本番環境用（常に安定）
- **develop**: 開発統合用
- **feature/[機能名]**: 機能開発用
- **hotfix/[修正内容]**: 緊急修正用

#### コミットメッセージ
```
type(scope): subject

body

footer
```

**タイプ:**
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント
- `style`: フォーマット
- `refactor`: リファクタリング
- `test`: テスト追加・修正

#### プルリクエスト
- **タイトル**: 変更内容を簡潔に記述
- **説明**: 変更理由と影響範囲を明記
- **チェックリスト**: テスト実行、ドキュメント更新確認
- **レビュー**: 最低1名の承認が必要

### 品質管理

#### テスト要件
- **単体テスト**: 適切なカバレッジ以上
- **統合テスト**: 主要フローの検証
- **E2Eテスト**: ユーザーシナリオの検証

#### コードレビュー観点
- **機能性**: 要件を満たしているか
- **可読性**: 理解しやすいコードか
- **保守性**: 変更・拡張しやすいか
- **パフォーマンス**: 性能に問題はないか
- **セキュリティ**: 脆弱性はないか

### セキュリティ基準

#### 認証・認可
- **パスワード**: 最低8文字、複雑性要件
- **セッション**: 適切なタイムアウト設定
- **API**: 適切な認証・認可の実装

#### データ保護
- **個人情報**: 暗号化・マスキング
- **ログ**: 機密情報の除外
- **通信**: HTTPS/TLS必須

---

> **カスタマイズ**: この規約はプロジェクトに合わせて変更してください。
> チームで合意した内容をこのファイルに反映し、全員で共有します。
