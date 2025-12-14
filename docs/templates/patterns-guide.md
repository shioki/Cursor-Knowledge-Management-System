# patterns.md テンプレート使用ガイド

このガイドでは、`templates/.cursor/patterns.md` の詳細な使用方法と記載例を説明します。

## 📋 概要

`patterns.md` は、プロジェクトで使用する共通パターン、実装テンプレート、環境別コマンド集などを記録するテンプレートです。チーム内での標準化と効率化を促進します。

## 🔧 .cursor/rules活用パターン

### 基本的な知見参照パターン - 記載例

#### .cursor/rules形式での知見参照（自動適用）
```
@.cursor/knowledge.md @.cursor/patterns.md
「認証機能を実装してください」
→ 過去の類似実装パターンが自動的に参照される
→ 設計判断の一貫性が保たれる
→ 実装品質が向上する
```

#### 条件付き適用パターン
```
# 特定のファイルタイプに対する自動適用
@.cursor/patterns.md[React コンポーネント実装テンプレート]
対象: **/*.{tsx,jsx}
条件: コンポーネント作成時
効果: 統一されたコンポーネント構造
```

#### 複合参照パターン
```
# 複数ファイルの組み合わせ参照
@.cursor/context.md @.cursor/knowledge.md @.cursor/patterns.md
「新機能を実装してください」
→ プロジェクト背景 + 過去の知見 + 実装パターン
→ 包括的で一貫性のある提案
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

## セキュリティ考慮事項
- XSS対策（HttpOnly Cookie）
- CSRF対策（SameSite属性）
- セッション管理（適切な有効期限）
```

## 💻 環境別コマンド集

### Windows (PowerShell) - 記載例

#### プロジェクト固有コマンド
```powershell
# 開発環境セットアップ
npm install
Copy-Item .env.example .env.local
npm run db:migrate
npm run db:seed

# 開発サーバー起動
npm run dev

# テスト実行
npm test
npm run test:e2e
npm run test:coverage

# ビルド・デプロイ
npm run build
npm run deploy:staging
npm run deploy:production

# データベース操作
npm run db:reset
npm run db:backup
npm run db:restore backup-file.sql

# ログ確認
Get-Content logs/app.log -Tail 50
Get-Content logs/error.log -Tail 20
```

#### macOS/Linux (Bash) - プロジェクト固有
```bash
# 開発環境セットアップ
npm install
cp .env.example .env.local
npm run db:migrate
npm run db:seed

# 開発サーバー起動
npm run dev

# テスト実行
npm test
npm run test:e2e
npm run test:coverage

# ビルド・デプロイ
npm run build
npm run deploy:staging
npm run deploy:production

# データベース操作
npm run db:reset
npm run db:backup
npm run db:restore backup-file.sql

# ログ確認
tail -f logs/app.log
tail -f logs/error.log
```

### Docker環境
```bash
# コンテナ操作
docker-compose up -d
docker-compose down
docker-compose logs -f app
docker-compose exec app bash

# データベース操作
docker-compose exec db psql -U postgres -d myapp
docker-compose exec db pg_dump -U postgres myapp > backup.sql
```

#### macOS/Linux (Bash) - プロジェクト固有
```bash
# 開発環境セットアップ
npm install
cp .env.example .env.local
npm run db:migrate
npm run db:seed

# 開発サーバー起動
npm run dev

# テスト実行
npm test
npm run test:e2e
npm run test:coverage

# ビルド・デプロイ
npm run build
npm run deploy:staging
npm run deploy:production

# データベース操作
npm run db:reset
npm run db:backup
npm run db:restore backup-file.sql

# ログ確認
tail -f logs/app.log
tail -f logs/error.log
```

#### Docker環境
```bash
# コンテナ操作
docker-compose up -d
docker-compose down
docker-compose logs -f app
docker-compose exec app bash

# データベース操作
docker-compose exec db psql -U postgres -d myapp
docker-compose exec db pg_dump -U postgres myapp > backup.sql
```

## 🏗️ 実装テンプレート

### React コンポーネント実装テンプレート - 記載例

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
  className?: string;
}

export interface User {
  id: string;
  name: string;
  email: string;
  avatar: string;
  role: 'admin' | 'user';
}

// UserProfile.tsx
import React from 'react';
import { UserProfileProps } from './types';
import styles from './UserProfile.module.css';

export const UserProfile: React.FC<UserProfileProps> = ({
  user,
  onEdit,
  isEditable = false,
  className
}) => {
  const handleEdit = () => {
    if (onEdit) {
      onEdit(user);
    }
  };

  return (
    <div className={`${styles.container} ${className || ''}`}>
      <img 
        src={user.avatar} 
        alt={user.name} 
        className={styles.avatar}
        loading="lazy"
      />
      <div className={styles.info}>
        <h2 className={styles.name}>{user.name}</h2>
        <p className={styles.email}>{user.email}</p>
        <span className={styles.role}>{user.role}</span>
      </div>
      {isEditable && (
        <button 
          onClick={handleEdit} 
          className={styles.editButton}
          aria-label={`${user.name}を編集`}
        >
          編集
        </button>
      )}
    </div>
  );
};

// UserProfile.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { UserProfile } from './UserProfile';
import { User } from './types';

const mockUser: User = {
  id: '1',
  name: 'テストユーザー',
  email: 'test@example.com',
  avatar: '/avatar.jpg',
  role: 'user'
};

describe('UserProfile', () => {
  test('ユーザー情報が正しく表示される', () => {
    render(<UserProfile user={mockUser} />);
    
    expect(screen.getByText('テストユーザー')).toBeInTheDocument();
    expect(screen.getByText('test@example.com')).toBeInTheDocument();
    expect(screen.getByText('user')).toBeInTheDocument();
  });

  test('編集可能な場合、編集ボタンが表示される', () => {
    const onEdit = jest.fn();
    render(<UserProfile user={mockUser} isEditable onEdit={onEdit} />);
    
    const editButton = screen.getByRole('button', { name: 'テストユーザーを編集' });
    expect(editButton).toBeInTheDocument();
    
    fireEvent.click(editButton);
    expect(onEdit).toHaveBeenCalledWith(mockUser);
  });
});
```

### API実装テンプレート - 記載例

#### ファイル構成
```
src/api/users/
├── index.ts                    # エクスポート
├── userApi.ts                 # API関数
├── userApi.test.ts            # テスト
├── types.ts                   # 型定義
└── constants.ts               # 定数
```

#### 実装例
```typescript
// types.ts
export interface CreateUserRequest {
  name: string;
  email: string;
  role: 'admin' | 'user';
}

export interface UpdateUserRequest extends Partial<CreateUserRequest> {
  id: string;
}

export interface UserResponse {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user';
  createdAt: string;
  updatedAt: string;
}

// userApi.ts
import { apiCall } from '../base';
import { CreateUserRequest, UpdateUserRequest, UserResponse } from './types';

export const userApi = {
  // ユーザー一覧取得
  getUsers: async (): Promise<UserResponse[]> => {
    const response = await apiCall<UserResponse[]>('/api/users', {
      method: 'GET'
    });
    return response.data || [];
  },

  // ユーザー詳細取得
  getUser: async (id: string): Promise<UserResponse | null> => {
    const response = await apiCall<UserResponse>(`/api/users/${id}`, {
      method: 'GET'
    });
    return response.data || null;
  },

  // ユーザー作成
  createUser: async (data: CreateUserRequest): Promise<UserResponse> => {
    const response = await apiCall<UserResponse>('/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    if (!response.success || !response.data) {
      throw new Error('ユーザーの作成に失敗しました');
    }
    return response.data;
  },

  // ユーザー更新
  updateUser: async (data: UpdateUserRequest): Promise<UserResponse> => {
    const { id, ...updateData } = data;
    const response = await apiCall<UserResponse>(`/api/users/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(updateData)
    });
    if (!response.success || !response.data) {
      throw new Error('ユーザーの更新に失敗しました');
    }
    return response.data;
  },

  // ユーザー削除
  deleteUser: async (id: string): Promise<void> => {
    const response = await apiCall(`/api/users/${id}`, {
      method: 'DELETE'
    });
    if (!response.success) {
      throw new Error('ユーザーの削除に失敗しました');
    }
  }
};
```
```

## 📏 チーム標準の定義

### コーディング規約 - 記載例

#### TypeScript
- **命名規則**: camelCase（変数・関数）、PascalCase（型・クラス）
- **型定義**: 明示的な型定義を推奨
- **null/undefined**: strict null checks を有効化
- **any型**: 使用禁止（unknown型を使用）

#### React
- **関数コンポーネント**: アロー関数で定義
- **Props**: interface で型定義
- **State**: useState, useReducer を適切に使い分け
- **副作用**: useEffect の依存配列を適切に設定

#### CSS
- **命名規則**: BEM記法
- **単位**: rem を基本とする
- **色**: CSS変数で管理
- **レスポンシブ**: モバイルファースト

#### Git
- **ブランチ**: feature/機能名、fix/修正内容
- **コミット**: Conventional Commits 形式
- **プルリクエスト**: テンプレートに従って記載

### レビュー基準 - 記載例

#### 必須チェック項目
- [ ] 機能要件を満たしている
- [ ] テストが適切に書かれている
- [ ] エラーハンドリングが実装されている
- [ ] セキュリティ上の問題がない
- [ ] パフォーマンスに問題がない

#### 推奨チェック項目
- [ ] コードが読みやすい
- [ ] 適切なコメントが書かれている
- [ ] 再利用可能な設計になっている
- [ ] 既存のパターンに従っている
- [ ] ドキュメントが更新されている

#### レビュー手順
1. 機能動作の確認
2. コード品質の確認
3. テストの確認
4. ドキュメントの確認
5. 承認またはフィードバック

## 🔄 継続的な改善

### パターンの更新プロセス

#### 新パターンの追加
1. **提案**: チームメンバーからの提案
2. **検討**: 技術的妥当性の評価
3. **試行**: 小規模での試験導入
4. **評価**: 効果測定と問題点の洗い出し
5. **採用**: 正式なパターンとして追加

#### 既存パターンの見直し
- **定期レビュー**: 四半期ごとの見直し
- **問題報告**: 使用中の問題点の収集
- **改善提案**: より良いパターンの検討
- **更新実施**: パターンの修正・削除

#### 効果測定
- **開発効率**: 実装時間の短縮
- **品質向上**: バグ発生率の低下
- **一貫性**: コードの統一性向上
- **学習効果**: 新メンバーの習得速度

---

このガイドを参考に、チーム内での標準化と効率化を促進してください。 