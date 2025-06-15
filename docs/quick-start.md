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

### 4. **📝 テンプレートファイルの使用方法**

各テンプレートファイルは構造のみを提供し、詳細な記載例は別ドキュメントで提供しています。

#### ✅ 新しいテンプレート構造の利点
- **安全性**: HTMLコメント問題を完全回避
- **明確性**: テンプレート構造が一目瞭然
- **使いやすさ**: 詳細な使用方法を別ドキュメントで提供
- **保守性**: テンプレートファイルの簡潔性

#### 📖 詳細な使用方法
**完全な記載例とベストプラクティス**: `docs/template-usage-guide.md` を参照してください。

このガイドには以下が含まれています：
- 各テンプレートファイルの詳細な記載例
- 具体的なコード例
- 段階的な記入方法
- ベストプラクティス
- 継続的活用の方法

#### 🎯 推奨する使用手順

**Step 1: テンプレート構造の理解**
```markdown
# 各テンプレートファイルの基本構造を確認
## セクション1
## セクション2
## セクション3
```

**Step 2: ガイドを参照しながら記入**
```bash
# ガイドを開きながら作業
code docs/template-usage-guide.md
code .cursor/knowledge.md
```

**Step 3: プロジェクト固有情報の記入**
```markdown
# 実際のプロジェクト情報に置き換え
## 設計判断の記録
### 2024-01-15 - フレームワーク選択
#### 判断内容
React vs Vue.js の選択
...
```

#### 💡 効率的な記入方法

**最小限の更新（10分）**
1. `.cursor/knowledge.md` の基本情報を更新
2. `.cursor/context.md` のプロジェクト概要を記入

**推奨更新（20分）**  
上記に加えて：

3. `.cursor/patterns.md` の初期パターンを記録
4. プロジェクト固有の制約を追加

**フル活用（30分）**  
上記すべてに加えて：

5. `.cursor/debug-log.md` の初期設定
6. `.cursor/improvements.md` の目標設定

## 🔧 使用開始の確認

### 1. 基本的な知識記録
詳細な記載例は `docs/template-usage-guide.md` を参照してください。

**簡単な例**:
```markdown
# .cursor/knowledge.md に記録
## 設計判断の記録

### 2024-01-15 - API設計方針
#### 判断内容
REST vs GraphQL の選択

#### 決定内容と理由
**決定**: REST API を採用
**理由**: 
- チームの習熟度が高い
- プロジェクトの複雑さに適している
- 開発期間の制約を考慮
```

### 2. 自動参照の確認
AIとの対話で以下のように参照されることを確認：
```
@.cursor/knowledge.md @.cursor/patterns.md
「ユーザー認証機能を実装してください」
```

### 3. .cursor/rules連携の動作確認
関連ファイル編集時に、適切な知見が自動参照されることを確認

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

- [テンプレート使用ガイド](template-usage-guide.md) - 詳細な記載例とベストプラクティス
- [完全ガイド](cursor-knowledge-management-system.md) - システムの詳細理解
- [チーム導入ガイド](team-implementation-guide.md) - チーム全体での活用
- [開発ログ](development-log.md) - システム開発の背景

---

**🎯 重要**: 導入後は継続的な更新が成功の鍵です。日々の技術判断を記録し続けることで、真の効果を実感できます。 