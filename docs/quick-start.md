# 🚀 5分クイックスタート

このガイドでは、Cursor知見管理システムを最短時間で導入し、即座に効果を実感できるように構成されています。

## 📋 前提条件

- Cursor IDE がインストール済み
- Git が使用可能（任意）
- 基本的なターミナル操作の知識

## ⚡ 1分セットアップ

### Step 1: ディレクトリの作成

**Windows (PowerShell)**:
```powershell
# プロジェクトルートで実行
mkdir .cursor
mkdir .cursor\debug
mkdir .cursor\debug\sessions
mkdir .cursor\debug\temp-logs  
mkdir .cursor\debug\archive
```

**macOS/Linux (Bash)**:
```bash
# プロジェクトルートで実行
mkdir -p .cursor/debug/{sessions,temp-logs,archive}
```

### Step 2: 基本ファイルの作成

**Windows**:
```powershell
New-Item -ItemType File -Path "CURSOR.md"
New-Item -ItemType File -Path ".cursor\context.md"
New-Item -ItemType File -Path ".cursor\patterns.md"
New-Item -ItemType File -Path ".cursor\debug-log.md"
New-Item -ItemType File -Path ".cursor\improvements.md"
New-Item -ItemType File -Path ".cursor\knowledge.md"
```

**macOS/Linux**:
```bash
touch CURSOR.md .cursor/{context,patterns,debug-log,improvements,knowledge}.md
```

### Step 3: テンプレートの取得

このリポジトリの `templates/` ディレクトリから、各ファイルの内容をコピーしてください：

1. [CURSOR.md](../templates/CURSOR.md) → プロジェクトルートの `CURSOR.md`
2. [context.md](../templates/.cursor/context.md) → `.cursor/context.md`
3. [patterns.md](../templates/.cursor/patterns.md) → `.cursor/patterns.md`
4. [debug-log.md](../templates/.cursor/debug-log.md) → `.cursor/debug-log.md`
5. [improvements.md](../templates/.cursor/improvements.md) → `.cursor/improvements.md`
6. [knowledge.md](../templates/.cursor/knowledge.md) → `.cursor/knowledge.md`

## ⚡ 即座に使える活用パターン

### 1. 既存知見の検索
```
@.cursor/debug-log.md 似た問題の解決例はありますか？
@.cursor/patterns.md このプロジェクトの標準パターンは？
@.cursor/context.md この制約の下で、[具体的な質問]
```

### 2. 新しい知見の記録
問題解決直後に：
1. Cursorで該当ファイルを開く（例：`.cursor/debug-log.md`）
2. テンプレートをコピー
3. 問題の詳細を記録
4. タグ付けして保存

### 3. 効果的なAI質問の仕方
```
# 複数ファイルを参照
@.cursor/patterns.md @.cursor/knowledge.md を参考に、
この機能の実装方法を教えてください

# コンテキストを含めた質問
@.cursor/context.md このプロジェクトの制約を考慮して、
パフォーマンスを最適化する方法は？
```

## 🎯 初日の目標（効果実感）

### やること
1. **1つの問題を解決して記録**：最初のデバッグ記録を作成
2. **1つのパターンを登録**：よく使うコマンドやコードパターンを追加
3. **AIに質問してみる**：`@ファイル名` を使って既存知見を参照

### 期待される効果
- 「この問題、前にも見た気がする...」がなくなる
- AI への質問がより具体的で効果的になる
- チームメンバーとの情報共有が楽になる

## 📈 1週間の習慣化チェックリスト

### 日次（5分）
- [ ] 重要な問題解決時に`.cursor/debug-log.md`に記録
- [ ] 新しいパターン発見時に`.cursor/patterns.md`に追加
- [ ] AIに質問する際に`@ファイル名`を使用

### 週次（15分）
- [ ] 今週の重要な知見をチーム共有
- [ ] ファイルの重複や不要な記録を整理
- [ ] 来週の改善目標を設定

## 🚀 効果測定

### 1週間後の変化を確認
- **同じ質問の回数**: 80%削減目標
- **問題解決時間**: 40%短縮目標  
- **AI質問の精度**: 体感で向上を実感

### 測定方法
```markdown
## 週次振り返り（コピー用）

### 今週の知見活用状況
- 新規記録: [X件]
- 既存知見参照: [X回]
- 時間短縮できた事例: [具体例]

### 感じた効果
- [定性的な効果]
- [具体的な時間短縮例]

### 来週の改善点
- [具体的な改善アクション]
```

## 🔄 継続のコツ

### 習慣化のポイント
1. **問題解決の直後に記録**：記憶が鮮明なうちに
2. **小さな改善も記録**：完璧を求めず、継続を重視
3. **AI活用を意識**：`@ファイル名`の使用を習慣化
4. **定期的な整理**：週1回、不要な情報を削除

### よくある失敗パターンと対策
| 失敗パターン | 対策 |
|-------------|------|
| 記録を忘れる | 問題解決直後にアラーム設定 |
| 詳しく書きすぎる | 最低限の情報でOK、完璧を求めない |
| 整理しない | 週1回15分の整理時間を固定化 |
| チーム共有しない | 週1回の共有ミーティングを設定 |

## 🆘 困った時のFAQ

### Q: 何を記録すべきか分からない
**A**: 30分以上調査した問題は記録対象です。「これ、他の人も困るかも？」と思ったら記録しましょう。

### Q: ファイルが多すぎて管理できない
**A**: 最初は `debug-log.md` と `patterns.md` だけに集中してください。慣れてから他のファイルを活用しましょう。

### Q: AIが知見を参照してくれない
**A**: `@ファイル名` の使用と、ファイル内の情報の質を確認してください。具体的で検索しやすい内容になっているかチェックしましょう。

### Q: チームメンバーが使ってくれない
**A**: まず自分で1週間使い、効果を実感してから共有しましょう。数値化された効果（時間短縮等）を示すと納得してもらいやすくなります。

## 🎯 次のステップ

### 1週間後の発展
- [完全版導入ガイド](installation-guide.md)を参照
- プロジェクト固有のカスタマイズを検討
- チーム全体での導入を計画

### 1ヶ月後の展開
- [チーム導入ガイド](team-guide.md)を参照
- 定量的な効果測定を開始
- 継続的改善サイクルを確立

---

> **💡 成功の秘訣**: 
> 完璧を求めず、「まず使ってみる」ことが最重要です。
> 1週間続けば効果を実感でき、継続が楽になります。
> 
> **🎯 今すぐ始めましょう！** 