# ⚡ 5分でできる！Cursor知見管理システム クイックセットアップ

## 🎯 このガイドの目的

忙しい開発者向けに、Cursor知見管理システムを**5分で導入**できる手順を提供します。

---

## ⏱️ 5分間セットアップ手順

### STEP 1: ディレクトリ作成（30秒）

**Windows:**
```powershell
md .cursor, .cursor\debug, .cursor\debug\sessions, .cursor\debug\temp-logs, .cursor\debug\archive
```

**macOS/Linux:**
```bash
mkdir -p .cursor/debug/{sessions,temp-logs,archive}
```

### STEP 2: 基本ファイル作成（30秒）

**Windows:**
```powershell
$files = @("CURSOR.md", ".cursor\context.md", ".cursor\patterns.md", ".cursor\debug-log.md", ".cursor\improvements.md", ".cursor\knowledge.md")
$files | ForEach-Object { New-Item -ItemType File -Path $_ -Force }
```

**macOS/Linux:**
```bash
touch CURSOR.md .cursor/{context,patterns,debug-log,improvements,knowledge}.md
```

### STEP 3: 最小限テンプレート設定（4分）

#### 3-1. CURSOR.md（必須）
```markdown
# [プロジェクト名] AI開発知見管理

## Cursorへの指示
- `.cursor/`内のファイルから過去知見を参照してください
- 新しい解決策は適切なファイルに記録してください
- 30分以上の問題解決は`.cursor/debug-log.md`に記録してください

## 活用方法
```
@.cursor/patterns.md よく使うパターンを教えて
@.cursor/debug-log.md 似た問題の解決例はある？
```
```

#### 3-2. .cursor/patterns.md（推奨）
```markdown
# よく使うパターン

## Cursorコマンド
- `Ctrl+K`: AI Chat起動
- `@ファイル名`: 特定ファイル参照
- `Ctrl+I`: インライン改善提案

## プロジェクト固有コマンド
[ここにプロジェクトでよく使うコマンドを追加]

## 実装テンプレート  
[ここによく使う実装パターンを追加]
```

#### 3-3. .cursor/debug-log.md（推奨）
```markdown
# デバッグログ

## 記録基準: 30分以上の調査、再発リスクが高い問題

---

## テンプレート
### [日付] - [問題タイトル]
**問題**: 
**解決策**: 
**所要時間**: 
**再発防止**: 
```

---

## 🚀 即座に使える活用パターン

### パターン1: 問題解決時
```
1. 問題発生
2. Cursor Chatで「@.cursor/debug-log.md 似た問題はありますか？」
3. 新しい問題なら調査・解決後、debug-log.mdに記録
```

### パターン2: 新機能開発時
```
1. 設計前に「@.cursor/patterns.md 関連パターンはありますか？」
2. 新パターン発見時、patterns.mdに即座に追加
```

### パターン3: AI回答品質向上
```
「@.cursor/context.md この制約下で、[具体的質問]」
→ プロジェクト固有の文脈を考慮した回答を取得
```

---

## 📋 最初の1週間でやること

### Day 1: セットアップ完了
- [ ] 基本ファイル作成
- [ ] CURSOR.mdにプロジェクト名記入
- [ ] 最初のパターンを1つ記録

### Day 2-3: 習慣化開始
- [ ] 問題解決時に記録する習慣をつける
- [ ] よく使うコマンドをpatterns.mdに追加

### Day 4-7: システム活用
- [ ] AIに知見ファイルを参照させる質問を試す
- [ ] 最初の効果を実感する

---

## ⚠️ よくある落とし穴と対策

### 落とし穴1: 記録を忘れる
**対策**: 問題解決**直後**に記録する習慣を作る

### 落とし穴2: 完璧を求めすぎる
**対策**: 最初は短いメモでOK。徐々に詳細化

### 落とし穴3: ファイルが見つからない
**対策**: Cursorの`@`機能でファイル名を補完活用

---

## 🎉 効果実感の目安

### 1週間後
- 同じ質問をAIに繰り返さなくなる
- プロジェクト固有の回答精度が向上

### 1ヶ月後  
- デバッグ時間が明らかに短縮
- 新しいパターンの蓄積が進む

### 3ヶ月後
- チーム全体での知見共有が自然に
- 開発効率の大幅な向上を実感

---

## 🔧 さらなるカスタマイズ

このクイックセットアップで基本的な効果を実感できたら、[完全版ガイド](./cursor-knowledge-management-system.md)でさらなるカスタマイズを検討してください。

---

## 📞 サポート

- 詳細な使い方: `docs/cursor-knowledge-management-system.md`
- トラブル時: 同ドキュメントの「トラブルシューティング」セクション

---

**セットアップ完了まで**: ⏱️ 約5分  
**効果実感開始**: 📈 約1週間  
**本格活用**: 🚀 約1ヶ月 