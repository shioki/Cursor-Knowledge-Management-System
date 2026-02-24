---
name: project-setup
description: 新しいプロジェクトにCursor Knowledge Management Systemを導入する際に使用。初期セットアップ、構造検証、カスタマイズガイドを提供する。
---

# プロジェクトセットアップ

新しいプロジェクトに Cursor Knowledge Management System を導入するためのスキルです。

## When to Use

- 新しいプロジェクトに知識管理システムを導入したいとき
- 既存プロジェクトにスキルとコマンドを追加したいとき
- セットアップの正しさを検証したいとき

## Instructions

### 1. 初期セットアップ

以下のスクリプトでスキルとコマンドを一括コピーできます。**init.sh は Mac/Linux 用です。Windows では手動で Copy-Item を実行するか、Git Bash で init.sh を実行するか、init.ps1（同 scripts/ に用意されている場合）を使用してください。**

```bash
bash path/to/cursor-knowledge-management-system/templates/.cursor/skills/project-setup/scripts/init.sh /path/to/target-project
```

または手動でコピー:

```bash
# Mac/Linux
cp -r templates/.cursor/skills /path/to/your-project/.cursor/skills
cp -r templates/.cursor/commands /path/to/your-project/.cursor/commands
cp templates/.cursorignore /path/to/your-project/.cursorignore
```

```powershell
# Windows (PowerShell)
Copy-Item -Path "templates\.cursor\skills" -Destination ".cursor\skills" -Recurse
Copy-Item -Path "templates\.cursor\commands" -Destination ".cursor\commands" -Recurse
Copy-Item -Path "templates\.cursorignore" -Destination ".cursorignore"
```

### 2. 構造の検証

セットアップ後、以下のスクリプトで構造を検証できます。**Windows** の場合は **Git Bash** で `bash .cursor/skills/project-setup/scripts/validate.sh` を実行してください。

```bash
bash .cursor/skills/project-setup/scripts/validate.sh
```

### 3. 初期カスタマイズ（推奨順序）

セットアップ後、以下の順序でカスタマイズを進めてください:

#### 最小限の更新（10分）
1. `/update-context` コマンドでプロジェクト基本情報を記入
2. `/record-decision` コマンドで最初の技術判断を記録

#### 推奨更新（20分）
上記に加えて:
3. `/add-pattern` コマンドで初期パターンを登録
4. team-standards スキルの SKILL.md をプロジェクトの規約に更新

#### フル活用（30分）
上記すべてに加えて:
5. debug-workflow のテンプレートを確認
6. improvement-tracking の目標を設定

### 4. 動作確認

- Cursor Settings > Rules でスキルが検出されることを確認
- チャットで `/` を入力してコマンドが表示されることを確認
- エージェントとの対話でスキルが自動適用されることを確認
