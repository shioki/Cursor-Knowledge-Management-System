# クイックスタートガイド

## 5 分で始める導入手順

### 1. リポジトリのクローン
```bash
git clone https://github.com/shioki/Cursor-Knowledge-Management-System.git
cd Cursor-Knowledge-Management-System
```

### 2. テンプレートを実際のプロジェクトにコピー

**Mac/Linux (bash):**
```bash
# あなたの実際のプロジェクトディレクトリに移動
cd /path/to/your-actual-project

# スキルをコピー（v4: .claude/skills で Cursor と Claude Code で共有）
cp -r /path/to/Cursor-Knowledge-Management-System/templates/.claude/skills .claude/skills

# コマンドをコピー
cp -r /path/to/Cursor-Knowledge-Management-System/templates/.cursor/commands .cursor/commands

# .cursorignore をコピー（推奨）
cp /path/to/Cursor-Knowledge-Management-System/templates/.cursorignore .cursorignore

# debug-sessions を作成
mkdir -p .claude/debug-sessions

# スクリプトに実行権限を付与
find .claude/skills -name "*.sh" -exec chmod +x {} \;
```

**Windows (PowerShell):**
```powershell
# あなたの実際のプロジェクトディレクトリに移動
cd C:\path\to\your-actual-project

# スキルをコピー
Copy-Item -Path "C:\path\to\Cursor-Knowledge-Management-System\templates\.claude\skills" -Destination ".claude\skills" -Recurse

# コマンドをコピー
Copy-Item -Path "C:\path\to\Cursor-Knowledge-Management-System\templates\.cursor\commands" -Destination ".cursor\commands" -Recurse

# debug-sessions を作成
New-Item -ItemType Directory -Path ".claude\debug-sessions" -Force

# .cursorignore をコピー（推奨）
Copy-Item -Path "C:\path\to\Cursor-Knowledge-Management-System\templates\.cursorignore" -Destination ".cursorignore"
```

**セットアップスクリプトを使う場合（Mac/Linux）:**
```bash
bash /path/to/Cursor-Knowledge-Management-System/templates/.claude/skills/project-setup/scripts/init.sh /path/to/your-project
```

**Windows でセットアップする場合:**
- **PowerShell のみ**でコピーする場合は、上記の Copy-Item を実行してください。
- **validate.sh** で構造を検証する場合は、**Git Bash** で `bash .claude/skills/project-setup/scripts/validate.sh` を実行してください。
- Windows 用の一括コピースクリプト（init.ps1）を使う場合は、下記 [init.ps1 で一括コピーする場合（Windows）](#initps1-で一括コピーする場合windows) を参照してください。

### 3. 動作確認

#### スキルの確認
1. Cursor Settings を開く（Mac: Cmd+Shift+J / Windows: Ctrl+Shift+J）
2. Rules に移動
3. Agent Decides セクションにスキルが表示されることを確認

#### コマンドの確認
1. Cursor のチャットを開く
2. `/` を入力
3. `record-decision`, `add-pattern` 等のコマンドが表示されることを確認

### 4. 初期カスタマイズ

#### 最小限の更新（10 分）
1. チャットで `/update-context` と入力し、プロジェクトの基本情報を記入
2. チャットで `/record-decision` と入力し、最初の技術判断を記録

#### 推奨更新（20 分）
上記に加えて:
3. チャットで `/add-pattern` と入力し、初期パターンを登録
4. `.claude/skills/team-standards/SKILL.md` をプロジェクトの規約に更新

#### フル活用（30 分）
上記すべてに加えて:
5. デバッグテンプレートの確認
6. 改善目標の設定

### 5. 構造の検証（任意）

セットアップが正しいことを確認:
```bash
# Mac/Linux、または Windows の Git Bash
bash .claude/skills/project-setup/scripts/validate.sh
```

## 導入完了チェックリスト

### 初期設定
- [ ] skills/ ディレクトリのコピー完了
- [ ] commands/ ディレクトリのコピー完了
- [ ] .cursorignore のコピー完了
- [ ] スクリプトの実行権限付与完了（Mac/Linux）/ **Windows**: コピーは PowerShell で完了。検証は Git Bash で validate.sh を実行可能

### 動作確認
- [ ] Cursor Settings でスキルが検出される
- [ ] チャットで `/` コマンドが表示される
- [ ] エージェントとの対話でスキルが自動適用される

### 初期カスタマイズ
- [ ] `/update-context` でプロジェクト情報を記入
- [ ] `/record-decision` で最初の技術判断を記録
- [ ] team-standards のカスタマイズ

## トラブルシューティング

**Q: スキルが Cursor Settings に表示されない**
A: `.claude/skills/`（または `.cursor/skills/`）ディレクトリがプロジェクトルート直下に配置されているか確認してください。各スキルフォルダに `SKILL.md` が存在することを確認してください。

**Q: コマンドが `/` 入力で表示されない**
A: `.cursor/commands/` ディレクトリがプロジェクトルート直下に配置されているか確認してください。Cursor 2.4 以上が必要です。

**Q: スクリプトが実行できない**
A: Mac/Linux では `chmod +x` で実行権限を付与してください。**Windows** の場合は **Git Bash** または **WSL** で `bash` を指定して実行してください（例: `bash .claude/skills/project-setup/scripts/validate.sh`）。

**Q: コピーコマンドが失敗する**
A: パスが正しいか、書き込み権限があるかを確認してください。

### init.ps1 で一括コピーする場合（Windows）

PowerShell で一括コピーするには、**Cursor-Knowledge-Management-System のリポジトリルートで**以下を実行します。ターゲットは実際のプロジェクトパスに置き換えてください。

```powershell
.\templates\.cursor\skills\project-setup\scripts\init.ps1 -TargetPath "C:\path\to\your-actual-project"
```

または、`init.ps1` があるディレクトリに移動してから:

```powershell
cd path\to\Cursor-Knowledge-Management-System\templates\.cursor\skills\project-setup\scripts
.\init.ps1 -TargetPath "C:\path\to\your-actual-project"
```

## v2.x からの移行

v2.x（`.cursor/rules` 形式）を使用していた場合は、[v2.x からの移行ガイド](migration-from-rules.md) を参照してください。自動スクリプト、対話型コマンド、手動手順の 3 つの移行方法を提供しています。

## 次のステップ

- [スキルとコマンドの概要](skills-and-commands.md) - 基本概念を理解
- [v2.x からの移行ガイド](migration-from-rules.md) - .cursor/rules からの移行
- [スキルガイド](../templates/skills-guide.md) - 各スキルの詳細な使い方
- [コマンドガイド](../templates/commands-guide.md) - 各コマンドの詳細な使い方
- [完全ガイド](../cursor-knowledge-management-system.md) - システムの詳細理解
- [チーム導入ガイド](../advanced/team-implementation.md) - チーム全体での活用

---

**重要**: 導入後は継続的な更新が成功の鍵です。日々の技術判断を `/record-decision` で記録し続けることで、真の効果を実感できます。
