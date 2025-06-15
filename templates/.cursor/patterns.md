# 共通パターン・テンプレート（MDC対応版）

> **💡 MDC形式での活用**: このファイルは `.cursor/rules/patterns-library.mdc` から自動参照されます。
> 該当技術ファイル編集時に、MDCルールが自動的に関連パターンを提案します。

## MDC活用パターン

### 自動参照コマンド
```
# MDC形式での知見参照（自動適用）
@.cursor/knowledge.md 過去の技術判断は？
@.cursor/patterns.md この技術の標準パターンは？
@.cursor/debug/sessions/ 類似問題の解決例は？
@.cursor/context.md プロジェクト制約は？
```

### MDCルール活用パターン
```yaml
# Always Rules - 常時適用される基本パターン
description: "基本的な開発標準"
globs: "**/*"
alwaysApply: true

# Auto Rules - ファイルタイプ別自動適用
description: "JavaScript/TypeScript専用パターン"
globs: "**/*.{js,ts,jsx,tsx}"
alwaysApply: false

# Agent Rules - AI判断による適用
description: "コードレビュー時の品質チェック"
globs: ""
alwaysApply: false
```

## Cursor AI操作パターン

### 基本操作
```
Ctrl+K : Cursor AI Chat起動
Ctrl+L : 現在のファイル全体をAIに送信
Ctrl+I : インラインでAI提案を受ける
Ctrl+Shift+I : AI Composer起動（複数ファイル編集）
```

### MDC連携操作
```
# ファイル参照（MDCルールで自動化）
@ファイル名 : 特定ファイルを参照してAI回答
@フォルダ名 : フォルダ全体を参照
@.cursor/ : 知識管理システム全体を参照

# 知見活用（自動適用）
該当ファイル編集時 → MDCルールが自動的に関連知見を適用
問題発生時 → debug-workflow.mdcが自動的にデバッグ支援を提供
```

## 環境別コマンド集（MDC統合版）

### Windows (PowerShell) - MDC対応
```powershell
# ディレクトリ操作
md ".cursor\rules"                      # MDCルールディレクトリ作成
md ".cursor\debug\sessions"             # デバッグセッションディレクトリ作成
ls .cursor -Recurse                     # MDC構造確認
tree .cursor /f                         # MDC階層構造表示

# MDCファイル操作
New-Item -ItemType File -Path ".cursor\rules\custom.mdc"    # 新MDCルール作成
Get-Content ".cursor\rules\*.mdc"                           # 全MDCルール確認
Get-ChildItem -Recurse -Filter "*.mdc"                      # MDCファイル検索
```

### macOS/Linux (Bash) - MDC対応
```bash
# ディレクトリ操作
mkdir -p .cursor/rules                  # MDCルールディレクトリ作成
mkdir -p .cursor/debug/sessions         # デバッグセッションディレクトリ作成
ls -la .cursor/                         # MDC構造確認
tree .cursor                            # MDC階層構造表示

# MDCファイル操作
touch .cursor/rules/custom.mdc          # 新MDCルール作成
cat .cursor/rules/*.mdc                 # 全MDCルール確認
find .cursor -name "*.mdc"              # MDCファイル検索
```

## プロジェクト固有のコマンド集（MDC統合版）
[プロジェクトでよく使うコマンドを記述してください]

### 開発環境セットアップ（MDC対応）
```bash
# 例：Node.js プロジェクト + MDC
npm install                             # 依存関係インストール
cp -r /path/to/cursor-knowledge-management-system/templates/.cursor .cursor  # MDCテンプレート適用
npm run dev                             # 開発サーバー起動（MDC自動適用）
npm run test                            # テスト実行（test-patterns.mdc適用）
npm run build                           # ビルド実行（build-patterns.mdc適用）
```

### データベース操作（MDC連携）
```sql
-- 例：よく使うクエリ（database-patterns.mdcで自動適用）
SELECT * FROM users WHERE active = 1;
-- MDCルールにより、クエリ最適化パターンが自動提案される
```

### デプロイメント（MDC統合）
```bash
# 例：デプロイコマンド（deploy-patterns.mdcで自動適用）
git push origin main
# MDCルールにより、デプロイ前チェックリストが自動適用される
```

## 実装テンプレート（MDC対応版）
[頻繁に使う実装パターンを記述してください]

### 関数テンプレート（自動適用対応）
```javascript
// 例：非同期関数のテンプレート
// このパターンは javascript-patterns.mdc により自動適用される
async function fetchData(url) {
  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();
    
    // MDCルールにより、成功時の処理パターンが自動提案される
    return data;
  } catch (error) {
    // MDCルールにより、エラー情報が .cursor/debug/sessions/ に自動記録される
    console.error('Error fetching data:', error);
    throw error;
  }
}
```

### エラーハンドリングパターン（MDC統合）
```javascript
// 例：統一されたエラーハンドリング
// このパターンは error-handling.mdc により自動適用される
const handleError = (error, context) => {
  // MDCルールにより、エラー分類と記録が自動化される
  console.error(`Error in ${context}:`, error);
  
  // 自動的に .cursor/debug/sessions/ にエラー情報を記録
  // 類似エラーの過去事例を自動検索・提案
};
```

### React コンポーネントパターン（MDC対応）
```tsx
// 例：React関数コンポーネントテンプレート
// このパターンは react-patterns.mdc により自動適用される
import React from 'react';

interface Props {
  // MDCルールにより、Props型定義パターンが自動適用される
}

export const ComponentName: React.FC<Props> = ({ }) => {
  // MDCルールにより、Hooks使用パターンが自動提案される
  
  return (
    <div>
      {/* MDCルールにより、JSX記述パターンが自動適用される */}
    </div>
  );
};

// MDCルールにより、テストファイル作成が自動提案される
```

## 効率化Tips（MDC版）
[プロジェクト固有の効率化手法を記述してください]

### MDC特有の活用法
1. **自動パターン適用**: ファイル編集時に関連パターンが自動適用される
2. **知見の自動参照**: 過去の類似実装が自動的に参照される
3. **問題解決の自動化**: デバッグ時に過去の解決例が自動提案される
4. **品質チェック自動化**: コード品質パターンが自動的に適用される
5. **チーム標準の自動適用**: チーム規約が自動的に適用される

### 従来のCursor活用法（MDC強化版）
1. **プロジェクト全体の理解**: `@.cursor/` でMDC知識管理システム全体を参照
2. **差分確認**: 変更前後でAIに最適化提案を求める（MDCパターン適用）
3. **リファクタリング**: 選択範囲を指定してAIに改善提案を依頼（パターン自動適用）
4. **テスト生成**: 関数選択してAIにテストコード生成を依頼（test-patterns.mdc適用）
5. **ドキュメント生成**: コード選択してAIにドキュメント生成を依頼（doc-patterns.mdc適用）

### MDC知見蓄積のベストプラクティス
1. **自動記録**: MDCルールが解決プロセスを自動的に記録
2. **パターン自動分類**: 新しいパターンが自動的に分類・整理される
3. **定期自動見直し**: MDCルールが知見の整理・統合を自動化
4. **チーム自動共有**: 重要な知見が自動的にチーム共有される

## プロジェクト固有パターン（MDC統合版）
[プロジェクト特有のパターンを記述してください]

### 命名規則（自動適用）
```javascript
// 例：変数命名規則（naming-patterns.mdcで自動適用）
const userName = '...';          // camelCase
const API_ENDPOINT = '...';      // CONSTANT_CASE
const ComponentName = () => {};  // PascalCase（React）

// MDCルールにより、命名規則違反が自動検出・修正提案される
```

### ファイル構成パターン（MDC対応）
```
src/
  components/                    # React コンポーネント
    Button/
      Button.tsx                 # メインコンポーネント
      Button.test.tsx            # テスト（test-patterns.mdc適用）
      Button.stories.tsx         # Storybook（storybook-patterns.mdc適用）
      Button.module.css          # スタイル（css-patterns.mdc適用）
      index.ts                   # エクスポート（export-patterns.mdc適用）
.cursor/                         # MDC知識管理システム
  rules/                         # MDCルールファイル
    *.mdc                        # 各種MDCルール
  debug/                         # デバッグ履歴
    sessions/                    # セッション記録
  knowledge.md                   # 技術知見
  patterns.md                    # このファイル
```

### API設計パターン（MDC統合）
```typescript
// 例：REST API パターン（api-patterns.mdcで自動適用）
interface ApiResponse<T> {
  data: T;
  status: 'success' | 'error';
  message?: string;
  // MDCルールにより、標準レスポンス形式が自動適用される
}

// MDCルールにより、エラーハンドリングパターンが自動提案される
const apiCall = async <T>(endpoint: string): Promise<ApiResponse<T>> => {
  // 実装パターンが自動適用される
};
```

## MDCルール設計パターン

### 基本MDCルール構造
```yaml
---
description: "ルールの説明"
globs: "対象ファイルパターン"
alwaysApply: true/false
---

# ルール内容
## 適用条件
## 実行内容
## 期待効果
```

### よく使うglobs パターン
```yaml
# JavaScript/TypeScript
globs: "**/*.{js,ts,jsx,tsx}"

# Python
globs: "**/*.py"

# 設定ファイル
globs: "**/*.{json,yaml,yml,toml}"

# ドキュメント
globs: "**/*.{md,mdx}"

# テストファイル
globs: "**/*.{test,spec}.{js,ts,jsx,tsx}"

# 全ファイル
globs: "**/*"
```

### MDCルール分類例
- `team-standards.mdc` - チーム標準（Always Rules）
- `javascript-patterns.mdc` - JavaScript専用（Auto Rules）
- `debug-workflow.mdc` - デバッグ支援（Agent Rules）
- `code-review.mdc` - レビュー支援（Manual Rules）

---

## 継続的改善パターン（MDC版）

### 月次パターン見直し
```markdown
## [YYYY年MM月] MDCパターン見直し

### 新規パターン
- [パターン名]: [効果・使用頻度]

### パターン最適化
- [既存パターン名]: [改善内容]

### MDCルール調整
- [ルール名]: [調整理由・効果]

### 削除パターン
- [パターン名]: [削除理由]
```

### パターン品質管理
- [ ] **再利用性**: 他のプロジェクトでも使えるか
- [ ] **自動適用性**: MDCルールで自動適用可能か
- [ ] **効果測定**: 実際に効率化に貢献しているか
- [ ] **保守性**: メンテナンスしやすいか

---

> **🚀 MDC形式の利点**: 
> - **自動適用**: ファイル編集時に関連パターンが自動適用される
> - **一貫性確保**: チーム全体で統一されたパターン使用
> - **効率化**: 手動コピペ不要で即座にパターン活用
> - **継続改善**: 使用状況に基づく自動的なパターン最適化
> - **知見蓄積**: 新パターン発見時の自動的な分類・整理