---
name: project-setup
description: 新しいプロジェクトにCursor Knowledge Management Systemを導入する際に使用。初期セットアップ、構造検証、カスタマイズガイドを提供する。
license: MIT
compatibility: Cursor 3.x, Claude Code, Codex
metadata:
  tags: [setup, cursor, knowledge-management]
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

**デフォルト** (v5.0.0~): 公式ディレクトリ `.agents/skills` に配置（Cursor 3.x / Claude Code / Codex で共有）
```bash
bash path/to/cursor-knowledge-management-system/templates/.agents/skills/project-setup/scripts/init.sh /path/to/target-project
```

**レガシー `.claude/skills` モード**: Claude Code 既存プロジェクト互換用
```bash
bash path/to/.../init.sh /path/to/target-project --legacy-claude
```

**Cursor のみ**: `.cursor/skills` に配置（Cursor のみで完結させたい場合）
```bash
bash path/to/.../init.sh /path/to/target-project --cursor-only
```

または手動でコピー（推奨 = `.agents/skills`）:

```bash
# Mac/Linux
cp -r templates/.agents/skills /path/to/your-project/.agents/skills
cp -r templates/.cursor/commands /path/to/your-project/.cursor/commands
cp templates/.cursorignore /path/to/your-project/.cursorignore
mkdir -p /path/to/your-project/.agents/debug-sessions
```

```powershell
# Windows (PowerShell)
Copy-Item -Path "templates\.agents\skills" -Destination ".agents\skills" -Recurse
Copy-Item -Path "templates\.cursor\commands" -Destination ".cursor\commands" -Recurse
Copy-Item -Path "templates\.cursorignore" -Destination ".cursorignore"
New-Item -ItemType Directory -Path ".agents\debug-sessions" -Force
```

### 2. 構造の検証

セットアップ後、以下のスクリプトで構造を検証できます。**Windows** の場合は **Git Bash** で実行してください。

```bash
bash .agents/skills/project-setup/scripts/validate.sh
# （.claude/skills / .cursor/skills も検出対象）
```

### 3. 初期カスタマイズ（推奨順序）

セットアップ後、以下の順序でカスタマイズを進めてください:

#### 最小限の更新（10分）
1. `/update-context` コマンドでプロジェクト基本情報を記入
2. `/record-decision` コマンドで最初の技術判断を記録

#### 推奨更新（20分）
上記に加えて:
3. `/add-pattern` コマンドで初期パターンを登録
4. team-standards スキルの SKILL.md をプロジェクトの規約に更新（`.agents/skills/team-standards/SKILL.md` など）

#### フル活用（30分）
上記すべてに加えて:
5. debug-workflow のテンプレートを確認
6. improvement-tracking の目標を設定

### 4. 動作確認

- Cursor Settings > Rules でスキルが検出されることを確認（Cursor 3.x では `.agents/skills` と `.cursor/skills` を公式に読み込み）
- チャットで `/` を入力してコマンドが表示されることを確認
- エージェントとの対話でスキルが自動適用されることを確認

## 関連

- Cursor Plugin 配布や Marketplace 提出については `docs/advanced/plugin-development.md` を参照
- `gh skill install` による導入については README を参照
- Microsoft APM 経由の導入については `docs/reference/apm-integration.md` を参照
