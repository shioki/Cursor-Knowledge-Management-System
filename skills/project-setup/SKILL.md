---
name: project-setup
description: 新しいプロジェクトに Cursor Knowledge Management System を導入する際に使用。初期セットアップ、構造検証、カスタマイズガイドを提供する。
license: MIT
compatibility: Cursor 3.x, Claude Code, Codex
metadata:
  tags: [setup, cursor, knowledge-management]
---

# プロジェクトセットアップ

新しいプロジェクトに Cursor Knowledge Management System を導入するためのスキルです。

## When to Use

- 新しいプロジェクトに知識管理システムを導入したいとき
- 既存プロジェクトにスキル・hooks・subagent を追加したいとき
- セットアップの正しさを検証したいとき

## Instructions

### 1. 導入方法の選択

| 方法 | 向いているケース |
|------|-----------------|
| Cursor Marketplace | Cursor だけで使う。個別プロジェクトにファイルを置きたくない |
| `init.sh` / `init.ps1` | プロジェクトに実体を置き、チームで Git 管理したい |
| `gh skill install` | 特定のスキルだけを取り込みたい |
| `apm install` | 他のエージェントパッケージとまとめて依存管理したい |

以下は `init.sh` を使う場合の手順です。

### 2. 初期セットアップ

`init.sh` は Mac / Linux 用です。Windows では同じディレクトリの `init.ps1`、または Git Bash / WSL で `init.sh` を使ってください。

**デフォルト**: `.agents/skills` に配置（Cursor / Claude Code / Codex で共有）

```bash
bash path/to/cursor-knowledge-management-system/skills/project-setup/scripts/init.sh /path/to/target-project
```

主なオプション:

| オプション | 効果 |
|-----------|------|
| `--yes` / `-y` | すべての確認に yes と答える（CI・非対話環境向け） |
| `--legacy-claude` | `.claude/skills` に配置（v4.x 互換） |
| `--cursor-only` | `.cursor/skills` に配置（Cursor のみ） |
| `--with-agents-md` | `AGENTS.md` テンプレートも配置 |
| `--no-hooks` | hooks を配置しない |
| `--no-agents` | subagent を配置しない |

配置されるもの:

- `<base>/skills/` — スキル 13 種
- `<base>/debug-sessions/` — デバッグセッションの保存先
- `.cursor/agents/knowledge-curator.md` — 知識ベース棚卸し用の subagent
- `.cursor/hooks/` と `.cursor/hooks.json` — 記録支援 hooks
- `.cursorignore`

手動でコピーする場合:

```bash
# Mac/Linux
cp -r skills /path/to/your-project/.agents/skills
cp -r agents /path/to/your-project/.cursor/agents
cp -r hooks /path/to/your-project/.cursor/hooks
cp templates/.cursorignore /path/to/your-project/.cursorignore
mkdir -p /path/to/your-project/.agents/debug-sessions
find /path/to/your-project/.agents/skills -name "*.sh" -exec chmod +x {} \;
```

手動コピーの場合、`.cursor/hooks.json` は `hooks/hooks.json` を参考に自分で作成してください。スクリプトのパスを `.cursor/hooks/` 起点に書き換える必要があります。

### 3. 構造の検証

```bash
bash .agents/skills/project-setup/scripts/validate.sh
# （.claude/skills / .cursor/skills も検出対象）
```

Windows では Git Bash で実行してください。

### 4. 初期カスタマイズ（推奨順序）

#### 最小限の更新（10 分）

1. `/update-context` でプロジェクト基本情報を記入
2. `/record-decision` で最初の技術判断を記録

#### 推奨更新（20 分）

3. `/add-pattern` で初期パターンを登録
4. `team-standards` スキルの `SKILL.md` をプロジェクトの規約に更新（frontmatter の `paths` も使用言語に合わせる）

#### フル活用（30 分）

5. `debug-workflow` のテンプレートを確認
6. `improvement-tracking` の目標を設定
7. `<base>/knowledge-hooks.conf` で hooks の挙動を調整

### 5. 動作確認

- Cursor の Customize > Skills でスキルが検出されることを確認
- チャットで `/` を入力し、`/record-decision` などのアクションスキルが表示されることを確認
- エージェントとの対話でドメインスキルが自動適用されることを確認
- hooks を有効にした場合、新しい会話の冒頭で知識の索引が読み込まれることを確認

## v5 以前からの移行

`.cursor/commands/` にあった 7 つのコマンドは、v6 でアクションスキルへ統合されました。移行手順は `docs/getting-started/migration-from-v5.md` を参照してください。

## 関連

- Cursor Plugin 配布や Marketplace 提出については `docs/advanced/plugin-development.md`
- hooks の詳細は `docs/advanced/hooks-guide.md`
- subagent の詳細は `docs/advanced/subagents-guide.md`
- `gh skill install` による導入については README
- Microsoft APM 経由の導入については `docs/reference/apm-integration.md`
