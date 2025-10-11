# debug-log.md テンプレート使用ガイド

このガイドでは、`templates/.cursor/debug-log.md` の詳細な使用方法と記載例を説明します。

## 📋 概要

`debug-log.md` は、プロジェクトで発生した問題、エラー、パフォーマンス課題などの解決過程を記録するテンプレートです。同様の問題の再発防止と、チームの問題解決能力向上に活用します。

## 🐛 問題・エラーログの記録

### 環境構築エラー - 記載例

#### 2024-01-15 - npm install でパッケージインストールが失敗

##### 問題の詳細
新しいプロジェクトで `npm install` を実行すると、特定のパッケージのインストールが失敗し、プロジェクトのセットアップができない。

#### 発生環境
- **OS**: Windows 11 Pro (Build 22621)
- **Node.js**: v18.17.0
- **npm**: v9.6.7
- **プロジェクト**: React + TypeScript
- **発生日時**: 2024-01-15 14:30
- **影響範囲**: 新規開発者のオンボーディング

#### エラーメッセージ
```
npm ERR! code ERESOLVE
npm ERR! ERESOLVE unable to resolve dependency tree
npm ERR! 
npm ERR! While resolving: my-project@0.1.0
npm ERR! Found: react@18.2.0
npm ERR! node_modules/react
npm ERR!   react@"^18.2.0" from the root project
npm ERR! 
npm ERR! Could not resolve dependency:
npm ERR! peer react@"^17.0.0" from @testing-library/react@12.1.5
npm ERR! node_modules/@testing-library/react
npm ERR!   @testing-library/react@"^12.1.5" from the root project
```

#### 再現手順
1. 新しいディレクトリを作成
2. `git clone [repository-url]` でプロジェクトをクローン
3. `npm install` を実行
4. エラーが発生

#### 調査手順
1. **エラーメッセージの分析**
   - ERESOLVE エラーは依存関係の競合を示す
   - React 18 と @testing-library/react@12.1.5 の peer dependency 競合

2. **依存関係の確認**
   ```bash
   npm ls react
   npm ls @testing-library/react
   ```

3. **npm cache の確認**
   ```bash
   npm cache verify
   ```

4. **類似事例の検索**
   - GitHub Issues での類似問題を検索
   - Stack Overflow での解決策を調査

#### 解決方法
**最終的な解決策**:
```bash
# 1. キャッシュクリア
npm cache clean --force

# 2. 既存ファイル削除
rm -rf node_modules package-lock.json

# 3. 依存関係の更新
npm update @testing-library/react@^13.4.0

# 4. 再インストール
npm install
```

**代替解決策**:
```bash
# legacy-peer-deps フラグを使用（一時的な回避策）
npm install --legacy-peer-deps
```

#### 根本原因
- @testing-library/react のバージョンが古く、React 18 に対応していない
- package.json の依存関係が最新の互換性を反映していない

#### 予防策
1. **依存関係管理の改善**
   - package.json 作成時に依存関係の互換性を事前確認
   - 定期的な依存関係の更新（月次）
   - Renovate Bot の導入検討

2. **開発環境の標準化**
   - Docker を使用した開発環境の統一
   - .nvmrc ファイルでNode.jsバージョンを固定

3. **ドキュメント整備**
   - 環境構築手順書の更新
   - トラブルシューティングガイドの作成

#### 参考リンク
- [npm dependency resolution](https://docs.npmjs.com/cli/v8/using-npm/dependency-resolution)
- [React Testing Library compatibility](https://github.com/testing-library/react-testing-library/issues/1232)
- [npm ERESOLVE errors](https://github.com/npm/cli/issues/4232)

#### 関連する問題
- [2024-01-10] Node.js バージョン不整合問題
- [2024-01-08] TypeScript 設定エラー

#### メタ情報
- **発見者**: 新入社員（山田太郎）
- **調査者**: シニア開発者（佐藤花子）
- **総調査時間**: 45分
- **影響範囲**: 新規プロジェクトセットアップ
- **重要度**: 中（オンボーディングに影響）
- **ステータス**: 解決済み
- **タグ**: `#環境構築` `#npm` `#依存関係` `#React`
```

## ⚡ パフォーマンス問題の分析

### レンダリング性能問題 - 記載例


## パフォーマンス問題

### 2024-01-20 - ユーザーリストページの表示が重い

#### 問題の詳細
1000件以上のユーザーデータを表示する際に、ページの読み込みが遅く、スクロールも重い状態。ユーザビリティに深刻な影響を与えている。

#### 発生環境
- **ブラウザ**: Chrome 120.0.6099.109
- **デバイス**: Windows 11, 16GB RAM
- **ネットワーク**: 高速回線（100Mbps）
- **データ量**: 1,200件のユーザーデータ
- **発生日時**: 2024-01-20 10:00

#### パフォーマンス測定結果
**初期測定**:
- **初期表示**: 3.2秒 → 目標: 1秒以下
- **スクロール**: 15fps → 目標: 60fps
- **メモリ使用量**: 150MB → 目標: 100MB以下
- **Lighthouse スコア**: 45点 → 目標: 90点以上

**詳細メトリクス**:
```javascript
// Performance API での測定結果
{
  "FCP": 1800,  // First Contentful Paint (ms)
  "LCP": 3200,  // Largest Contentful Paint (ms)
  "FID": 120,   // First Input Delay (ms)
  "CLS": 0.15   // Cumulative Layout Shift
}
```

#### 原因分析
**React DevTools Profiler での分析**:
1. **全データの一括レンダリング**
   - 1,200個のコンポーネントが同時にレンダリング
   - 各コンポーネントの平均レンダリング時間: 2.5ms

2. **不要な再レンダリングの発生**
   - 親コンポーネントの state 変更で全子コンポーネントが再レンダリング
   - React.memo が適用されていない

3. **画像の最適化不足**
   - 高解像度画像の未圧縮読み込み
   - lazy loading が実装されていない

**Chrome DevTools での分析**:
```javascript
// メモリリーク検出
console.log('Heap Size:', performance.memory.usedJSHeapSize);
// 結果: 157MB (通常の3倍)

// レンダリング時間測定
performance.mark('render-start');
// レンダリング処理
performance.mark('render-end');
performance.measure('render-time', 'render-start', 'render-end');
// 結果: 2,800ms
```

#### 解決策の実装

**1. 仮想スクロールの導入**
```typescript
import { FixedSizeList as List } from 'react-window';

const UserList: React.FC<{ users: User[] }> = ({ users }) => {
  const Row = ({ index, style }: { index: number; style: React.CSSProperties }) => (
    <div style={style}>
      <UserItem user={users[index]} />
    </div>
  );

  return (
    <List
      height={600}
      itemCount={users.length}
      itemSize={80}
      itemData={users}
    >
      {Row}
    </List>
  );
};
```

**2. React.memo の活用**
```typescript
const UserItem = React.memo<{ user: User }>(({ user }) => {
  return (
    <div className="user-item">
      <img 
        src={user.avatar} 
        alt={user.name}
        loading="lazy"
        width={40}
        height={40}
      />
      <div>
        <h3>{user.name}</h3>
        <p>{user.email}</p>
      </div>
    </div>
  );
}, (prevProps, nextProps) => {
  return prevProps.user.id === nextProps.user.id &&
         prevProps.user.updatedAt === nextProps.user.updatedAt;
});
```

**3. 画像の最適化**
```typescript
const OptimizedImage: React.FC<{ src: string; alt: string }> = ({ src, alt }) => {
  const [imageSrc, setImageSrc] = useState<string>('');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const img = new Image();
    img.onload = () => {
      setImageSrc(src);
      setIsLoading(false);
    };
    img.src = src;
  }, [src]);

  return (
    <div className="image-container">
      {isLoading ? (
        <div className="skeleton" />
      ) : (
        <img 
          src={imageSrc} 
          alt={alt} 
          loading="lazy"
          className="optimized-image"
        />
      )}
    </div>
  );
};
```

**4. データの段階的読み込み**
```typescript
const useInfiniteUsers = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);

  const loadMore = useCallback(async () => {
    if (loading || !hasMore) return;
    
    setLoading(true);
    try {
      const newUsers = await fetchUsers({
        offset: users.length,
        limit: 50
      });
      
      setUsers(prev => [...prev, ...newUsers]);
      setHasMore(newUsers.length === 50);
    } catch (error) {
      console.error('Failed to load users:', error);
    } finally {
      setLoading(false);
    }
  }, [users.length, loading, hasMore]);

  return { users, loading, hasMore, loadMore };
};
```

#### 改善結果
**最終測定結果**:
- **初期表示**: 3.2秒 → 0.8秒（75%改善）
- **スクロール**: 15fps → 60fps（300%改善）
- **メモリ使用量**: 150MB → 80MB（47%削減）
- **Lighthouse スコア**: 45点 → 92点

**詳細メトリクス改善**:
```javascript
// 改善後のPerformance API結果
{
  "FCP": 400,   // First Contentful Paint (ms) - 78%改善
  "LCP": 800,   // Largest Contentful Paint (ms) - 75%改善
  "FID": 15,    // First Input Delay (ms) - 88%改善
  "CLS": 0.02   // Cumulative Layout Shift - 87%改善
}
```

#### 学んだ教訓
1. **大量データの表示には仮想スクロールが必須**
2. **React.memo の適切な使用でレンダリング最適化**
3. **画像最適化の重要性**
4. **パフォーマンス測定の継続的実施**

#### 今後の予防策
1. **パフォーマンス監視の自動化**
   - Lighthouse CI の導入
   - Core Web Vitals の継続監視

2. **開発時のパフォーマンスチェック**
   - React DevTools Profiler の定期使用
   - Bundle Analyzer での定期チェック

3. **コードレビューでのパフォーマンス観点追加**
   - 大量データ処理のレビュー項目追加
   - メモ化の適用確認

#### 関連する改善
- [2024-01-25] 商品一覧ページの同様問題解決
- [2024-01-30] 検索機能のパフォーマンス改善

#### タグ
`#パフォーマンス` `#React` `#仮想スクロール` `#重要度高` `#ユーザビリティ`
```

## 🔧 API・通信エラーの記録

### API通信エラー - 記載例


## API・通信エラー

### 2024-01-25 - 認証APIでランダムに401エラーが発生

#### 問題の詳細
本番環境で認証APIが不定期に401 Unauthorized エラーを返し、ユーザーが突然ログアウトされる問題が発生。

#### 発生環境
- **環境**: 本番環境（AWS ECS）
- **API**: /api/auth/refresh
- **発生頻度**: 約5%のリクエスト
- **影響ユーザー**: 約100名/日
- **発生期間**: 2024-01-25 09:00 - 継続中

#### エラーログ
**フロントエンド側**:
```javascript
// Console Error
Error: API Error: 401 Unauthorized
  at apiCall (api.ts:45)
  at refreshToken (auth.ts:23)
  at useAuth (useAuth.ts:67)

// Network Tab
Request URL: https://api.example.com/api/auth/refresh
Request Method: POST
Status Code: 401 Unauthorized
Response Headers:
  content-type: application/json
  x-request-id: req-123456789
```

**バックエンド側**:
```
[2024-01-25 09:15:23] ERROR: JWT verification failed
  Token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  Error: TokenExpiredError: jwt expired
  RequestId: req-123456789
  UserId: user-456
  IP: 203.0.113.1
```

#### 調査過程

**1. ログ分析**
```bash
# CloudWatch Logs での調査
aws logs filter-log-events \
  --log-group-name /aws/ecs/api-service \
  --filter-pattern "401" \
  --start-time 1706169600000

# 結果: 401エラーの発生パターンを確認
# - 特定の時間帯に集中（9:00-10:00, 13:00-14:00）
# - 特定のユーザーに偏りなし
```

**2. JWT トークンの検証**
```javascript
// JWT デコード調査
const jwt = require('jsonwebtoken');
const problematicToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

try {
  const decoded = jwt.decode(problematicToken, { complete: true });
  console.log('Token payload:', decoded.payload);
  console.log('Expiry:', new Date(decoded.payload.exp * 1000));
} catch (error) {
  console.error('Token decode error:', error);
}

// 結果: トークンの有効期限が予想より短い
```

**3. サーバー時刻の確認**
```bash
# ECS タスクの時刻確認
aws ecs execute-command \
  --cluster production-cluster \
  --task task-id \
  --container api-container \
  --command "date"

# 結果: サーバー時刻に2分のズレを発見
```

#### 根本原因
1. **サーバー時刻の不整合**
   - ECS タスク間で時刻が最大2分ずれている
   - JWT の exp クレームの検証で問題が発生

2. **トークンリフレッシュのタイミング問題**
   - フロントエンドでのリフレッシュが有効期限ギリギリ
   - ネットワーク遅延を考慮していない

#### 解決策

**1. サーバー時刻の同期**
```yaml
# ECS Task Definition の更新
version: '3'
services:
  api:
    image: myapp:latest
    command: |
      sh -c "
        # NTP同期の強制実行
        ntpdate -s time.nist.gov
        # アプリケーション起動
        npm start
      "
```

**2. JWT検証の改善**
```typescript
// JWT検証時のクロックスキュー許容
const verifyOptions: jwt.VerifyOptions = {
  clockTolerance: 60, // 60秒の時刻ずれを許容
  issuer: 'myapp',
  audience: 'myapp-users'
};

export const verifyToken = (token: string): Promise<JWTPayload> => {
  return new Promise((resolve, reject) => {
    jwt.verify(token, JWT_SECRET, verifyOptions, (err, decoded) => {
      if (err) {
        logger.error('JWT verification failed', { error: err.message, token });
        reject(err);
      } else {
        resolve(decoded as JWTPayload);
      }
    });
  });
};
```

**3. フロントエンドのリフレッシュ改善**
```typescript
// トークンリフレッシュの改善
export const useTokenRefresh = () => {
  const refreshToken = useCallback(async () => {
    const token = getStoredToken();
    if (!token) return null;

    try {
      const decoded = jwt.decode(token) as JWTPayload;
      const now = Date.now() / 1000;
      const timeUntilExpiry = decoded.exp - now;

      // 有効期限の5分前にリフレッシュ（余裕を持たせる）
      if (timeUntilExpiry < 300) {
        const response = await authApi.refreshToken();
        setStoredToken(response.accessToken);
        return response.accessToken;
      }
    } catch (error) {
      logger.error('Token refresh failed', error);
      // ログアウト処理
      logout();
    }

    return token;
  }, []);

  // 定期的なリフレッシュチェック
  useEffect(() => {
    const interval = setInterval(refreshToken, 60000); // 1分ごと
    return () => clearInterval(interval);
  }, [refreshToken]);

  return { refreshToken };
};
```

#### 検証・テスト
```typescript
// 時刻ずれのシミュレーションテスト
describe('JWT with clock skew', () => {
  beforeEach(() => {
    // システム時刻を2分進める
    jest.useFakeTimers();
    jest.setSystemTime(Date.now() + 120000);
  });

  test('should accept token with clock tolerance', async () => {
    const token = generateTestToken({ exp: Math.floor(Date.now() / 1000) - 30 });
    const result = await verifyToken(token);
    expect(result).toBeDefined();
  });

  afterEach(() => {
    jest.useRealTimers();
  });
});
```

#### 改善結果
- **401エラー発生率**: 5% → 0.1%（95%削減）
- **ユーザー影響**: 100名/日 → 2名/日
- **サポート問い合わせ**: 15件/日 → 1件/日

#### 監視・アラート設定
```yaml
# CloudWatch アラーム設定
AuthenticationErrorRate:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: High-Authentication-Error-Rate
    MetricName: 4XXError
    Namespace: AWS/ApplicationELB
    Statistic: Sum
    Period: 300
    EvaluationPeriods: 2
    Threshold: 10
    ComparisonOperator: GreaterThanThreshold
```

#### 今後の予防策
1. **定期的な時刻同期チェック**
2. **JWT有効期限の適切な設定**
3. **エラー監視の強化**
4. **負荷テストでの時刻ずれシミュレーション**

#### タグ
`#認証` `#JWT` `#時刻同期` `#本番障害` `#重要度高`
```

## 📊 継続的な改善

### 問題解決プロセスの改善


## 問題解決プロセス

### 効果的なデバッグ手順
1. **問題の再現**
   - 最小限の再現手順を特定
   - 環境依存の要因を排除

2. **ログ・メトリクスの収集**
   - 関連するすべてのログを収集
   - パフォーマンスメトリクスの測定

3. **仮説の立案**
   - 複数の原因候補を検討
   - 優先度付けして調査

4. **検証・テスト**
   - 仮説を検証するテストを実施
   - 修正案の効果を測定

5. **解決策の実装**
   - 段階的な修正の適用
   - 影響範囲の最小化

### 知見の共有
- **定期的な振り返り会**
- **問題解決事例の発表**
- **ベストプラクティスの更新**
```

---

このガイドを参考に、効果的な問題解決と知見の蓄積を実現してください。
