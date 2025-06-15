# 共通パターン・テンプレート

## よく使うCursorコマンド・操作

### ファイル操作
```
Ctrl+P : ファイル検索
Ctrl+Shift+P : コマンドパレット  
Ctrl+Shift+E : エクスプローラー表示
Ctrl+` : ターミナル表示/非表示
Ctrl+Shift+` : 新しいターミナル
```

### AI活用パターン
```
Ctrl+K : Cursor AI Chat起動
Ctrl+L : 現在のファイル全体をAIに送信
Ctrl+I : インラインでAI提案を受ける
@ファイル名 : 特定ファイルを参照してAI回答
@フォルダ名 : フォルダ全体を参照
```

## 環境別コマンド集

### Windows (PowerShell)
```powershell
# ディレクトリ操作
md "ディレクトリ名"              # ディレクトリ作成
ls / dir                        # ディレクトリ一覧
tree /f                         # 階層構造表示

# ファイル操作
New-Item -ItemType File -Path "ファイル名"    # ファイル作成
Get-Content "ファイル名"                      # ファイル内容表示
Get-ChildItem -Recurse -Filter "*.md"        # ファイル検索
```

### macOS/Linux (Bash)
```bash
# ディレクトリ操作
mkdir -p "ディレクトリ名"        # ディレクトリ作成（再帰）
ls -la                          # ディレクトリ一覧（詳細）
tree                            # 階層構造表示

# ファイル操作
touch "ファイル名"               # ファイル作成
cat "ファイル名"                # ファイル内容表示
find . -name "*.md"             # ファイル検索
```

## プロジェクト固有のコマンド集
[プロジェクトでよく使うコマンドを記述してください]

### 開発環境セットアップ
```bash
# 例：Node.js プロジェクト
npm install                     # 依存関係インストール
npm run dev                     # 開発サーバー起動
npm run test                    # テスト実行
npm run build                   # ビルド実行
```

### データベース操作
```sql
-- 例：よく使うクエリ
SELECT * FROM users WHERE active = 1;
```

### デプロイメント
```bash
# 例：デプロイコマンド
git push origin main
```

## 実装テンプレート
[頻繁に使う実装パターンを記述してください]

### 関数テンプレート
```javascript
// 例：非同期関数のテンプレート
async function fetchData(url) {
  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error fetching data:', error);
    throw error;
  }
}
```

### エラーハンドリングパターン
```javascript
// 例：統一されたエラーハンドリング
const handleError = (error, context) => {
  console.error(`Error in ${context}:`, error);
  // ログ送信、ユーザー通知等
};
```

## 効率化Tips
[プロジェクト固有の効率化手法を記述してください]

### Cursor特有の活用法
1. **プロジェクト全体の理解**: `@` でファイルやフォルダを指定してAIに質問
2. **差分確認**: 変更前後でAIに最適化提案を求める
3. **リファクタリング**: 選択範囲を指定してAIに改善提案を依頼
4. **テスト生成**: 関数選択してAIにテストコード生成を依頼
5. **ドキュメント生成**: コード選択してAIにドキュメント生成を依頼

### 知見蓄積のベストプラクティス
1. **即座に記録**: 解決した瞬間に記録する
2. **検索タグ付け**: 後で見つけやすいキーワードを含める  
3. **定期見直し**: 月1回は知見の整理・統合を行う
4. **チーム共有**: 有用な知見は積極的に共有する

## プロジェクト固有パターン
[プロジェクト特有のパターンを記述してください]

### 命名規則
```
// 例：変数命名規則
const userName = '...';          // camelCase
const API_ENDPOINT = '...';      // CONSTANT_CASE
```

### ファイル構成パターン
```
src/
  components/
    Button/
      Button.tsx
      Button.test.tsx
      Button.stories.tsx
      index.ts
```

---

> **💡 Tip**: このファイルは新しいパターンを発見するたびに随時更新してください。チームで共有することで、全体の生産性が向上します。 