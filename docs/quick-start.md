# クイックスタートガイド

## 🚀 5分で始める導入手順

### 1. リポジトリのクローン
```bash
git clone https://github.com/your-username/cursor-knowledge-management-system.git
cd cursor-knowledge-management-system
```

### 2. テンプレートを実際のプロジェクトにコピー

**Windows（PowerShell）:**
```powershell
# あなたの実際のプロジェクトディレクトリに移動
cd C:\path\to\your-actual-project

# テンプレートをコピー（プロジェクトルート直下に配置）
Copy-Item -Path "C:\path\to\cursor-knowledge-management-system\templates\.cursor" -Destination ".cursor" -Recurse

# .cursorignoreファイルもコピー（推奨）
Copy-Item -Path "C:\path\to\cursor-knowledge-management-system\templates\.cursorignore" -Destination ".cursorignore"
```

**Mac/Linux（bash）:**
```bash
# あなたの実際のプロジェクトディレクトリに移動
cd /path/to/your-actual-project

# テンプレートをコピー（プロジェクトルート直下に配置）
cp -r /path/to/cursor-knowledge-management-system/templates/.cursor .cursor

# .cursorignoreファイルもコピー（推奨）
cp /path/to/cursor-knowledge-management-system/templates/.cursorignore .cursorignore
```

### 3. **⚠️ 重要: 必須更新ファイル**

**コピー後、以下のファイルは必ず実際のプロジェクト情報で更新が必要です：**

#### 🔥 **知識管理ファイル（最重要）**
- [ ] `.cursor/knowledge.md` - 実際の技術判断を記録
- [ ] `.cursor/patterns.md` - プロジェクト固有のパターンを記録
- [ ] `.cursor/context.md` - プロジェクト背景・制約を記録

**⚠️ テンプレートのままでは自動参照の効果が得られません**

## ⏱️ 更新作業の時間目安

### 最小限の更新（10分）
1. `.cursor/knowledge.md` をプロジェクト用に書き換え
2. `.cursor/context.md` の基本情報を更新

### 推奨更新（20分）
上記に加えて：
3. `.cursor/patterns.md` の初期パターンを記録
4. プロジェクト固有の制約を追加

### フル活用（30分）
上記すべてに加えて：
5. `.cursor/debug-log.md` の初期設定
6. `.cursor/improvements.md` の目標設定

## 📝 具体的な更新例

### .cursor/knowledge.md の更新
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

### .cursor/patterns.md の更新
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

### .cursor/context.md の更新
```markdown
# プロジェクト背景・制約（あなたのプロジェクト名）

## プロジェクト概要
- **目的**: ECサイトの構築
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

## 🔧 使用開始の確認

### 1. 基本的な知識記録
```markdown
# .cursor/knowledge.md に記録
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

### 3. MDCルールの動作確認
TypeScriptファイルを開いた際に、適切なルールが自動適用されることを確認

## 📊 導入完了チェックリスト

### 初期設定
- [ ] テンプレートファイルのコピー完了
- [ ] 基本ファイルの更新完了
- [ ] 最初の技術判断を記録

### 動作確認
- [ ] AIとの対話で自動参照が動作
- [ ] MDCルールが適切に適用
- [ ] ファイル構造が正しく配置

### 継続運用準備
- [ ] 定期的な更新スケジュール設定
- [ ] チームメンバーへの共有（チーム導入の場合）
- [ ] 効果測定方法の決定

## 🆘 トラブルシューティング

### よくある問題
**Q: ルールが適用されない**
A: `.cursor/rules/`ディレクトリの場所とファイル拡張子（`.mdc`）を確認

**Q: 自動参照が働かない**
A: ファイルが実際のプロジェクト情報で更新されているか確認

**Q: コピーコマンドが失敗する**
A: パスが正しいか、権限があるかを確認

## 📚 次のステップ

- [完全ガイド](cursor-knowledge-management-system.md) - システムの詳細理解
- [チーム導入ガイド](team-implementation-guide.md) - チーム全体での活用
- [開発ログ](development-log.md) - システム開発の背景

---

**🎯 重要**: 導入後は継続的な更新が成功の鍵です。日々の技術判断を記録し続けることで、真の効果を実感できます。 