# クイックスタートガイド

## 導入方法を選ぶ

| 方法 | 向いているケース | 所要時間 |
|------|-----------------|---------|
| Cursor Marketplace | Cursor だけで使う。プロジェクトにファイルを置きたくない | 1 分 |
| `init.sh` / `init.ps1` | プロジェクトに実体を置き、チームで Git 管理したい | 5 分 |
| `gh skill install` | 特定のスキルだけ取り込みたい | 2 分 |
| `apm install` | 他のエージェントパッケージとまとめて管理したい | 2 分 |

このガイドは `init.sh` / `init.ps1` を使う手順を説明します。ほかの方法は [README](../../README.md) を参照してください。

## 1. リポジトリのクローン

```bash
git clone https://github.com/shioki/Cursor-Knowledge-Management-System.git
cd Cursor-Knowledge-Management-System
```

## 2. セットアップスクリプトの実行

**Mac / Linux:**

```bash
bash skills/project-setup/scripts/init.sh /path/to/your-project
```

**Windows (PowerShell):**

```powershell
.\skills\project-setup\scripts\init.ps1 -TargetPath "C:\path\to\your-project"
```

確認プロンプトを出さずに実行するには `--yes`（PowerShell では `-Yes`）を付けます。CI や自動化から呼ぶ場合はこちらを使ってください。

### 配置されるもの

```text
your-project/
├── .agents/
│   ├── skills/              # スキル 13 種（唯一の実体）
│   └── debug-sessions/      # デバッグセッションの保存先
├── .claude/
│   ├── skills/              # .agents/skills へのシンボリックリンク
│   ├── hooks/               # 記録支援スクリプト（Claude Code 用）
│   └── settings.json
├── .cursor/
│   ├── agents/
│   │   └── knowledge-curator.md
│   ├── hooks/               # 記録支援スクリプト（Cursor 用）
│   └── hooks.json
└── .cursorignore
```

`.agents/skills/` は Cursor と Codex が直接読み込む公式ディレクトリです。Claude Code は `.claude/skills/` しか標準で探索しないため、`init.sh` がシンボリックリンクを自動作成して橋渡しします（`--no-claude-bridge` で無効化可）。

### 主なオプション

| オプション | 効果 |
|-----------|------|
| `--yes` / `-Yes` | すべての確認に yes と答える |
| `--legacy-claude` | `.claude/skills` に配置（v4.x 互換） |
| `--cursor-only` | `.cursor/skills` に配置（Cursor のみ） |
| `--with-agents-md` | `AGENTS.md` テンプレートも配置（`CLAUDE.md` も同時に作成） |
| `--no-hooks` | hooks を配置しない |
| `--no-agents` | subagent を配置しない |
| `--no-claude-bridge` | `.claude/skills` への橋渡しを作らない |

### 手動でコピーする場合

```bash
cd /path/to/your-project
CKMS=/path/to/Cursor-Knowledge-Management-System

cp -r "$CKMS/skills" .agents/skills
cp -r "$CKMS/agents" .cursor/agents
cp -r "$CKMS/hooks" .cursor/hooks
cp "$CKMS/templates/.cursorignore" .cursorignore
mkdir -p .agents/debug-sessions
find .agents/skills -name "*.sh" -exec chmod +x {} \;
```

`.cursor/hooks.json` は [hooks/hooks.json](../../hooks/hooks.json) を参考に作成してください。スクリプトのパスを `.cursor/hooks/` 起点に書き換える必要があります。詳細は [hooks ガイド](../advanced/hooks-guide.md) にあります。

## 3. 動作確認

### スキル

1. Cursor Settings を開く（Mac: `Cmd+Shift+J` / Windows: `Ctrl+Shift+J`）
2. Skills に移動
3. ドメインスキル 7 種が表示されることを確認

### アクションスキル

1. チャットで `/` を入力
2. `record-decision`、`add-pattern` などが候補に出ることを確認

### 構造の検証

```bash
bash .agents/skills/project-setup/scripts/validate.sh
```

Windows では Git Bash で実行してください。エラー 0 件・警告 0 件になれば正常です。

## 4. 初期カスタマイズ

ここを飛ばすと、スキルは空のテンプレートを参照するだけになります。最低限の 2 つは必ず実施してください。

### 最小限（10 分）

1. チャットで `/update-context` と入力し、プロジェクトの基本情報を記入
2. チャットで `/record-decision` と入力し、最初の技術判断を記録

### 推奨（20 分）

3. `/add-pattern` で初期パターンを登録
4. `.agents/skills/team-standards/SKILL.md` をプロジェクトの規約に更新

`team-standards` の frontmatter にある `paths` は、このスキルをソースコード作業中だけ読み込ませるためのスコープ指定です。プロジェクトで使う言語に合わせて増減させてください。

### フル活用（30 分）

5. `debug-workflow` のテンプレートを確認
6. `improvement-tracking` の目標を設定
7. `.agents/knowledge-hooks.conf` で hooks の挙動を調整（[hooks ガイド](../advanced/hooks-guide.md)）

## 導入完了チェックリスト

- [ ] `init.sh` / `init.ps1` の実行完了
- [ ] `validate.sh` がエラー 0 件で通る
- [ ] Cursor Settings でスキルが検出される
- [ ] チャットで `/record-decision` が候補に出る
- [ ] `/update-context` でプロジェクト情報を記入した
- [ ] `/record-decision` で最初の技術判断を記録した
- [ ] `team-standards` をプロジェクトの規約に合わせた

## トラブルシューティング

**スキルが Cursor Settings に表示されない**

`.agents/skills/` がプロジェクトルート直下にあり、各スキルフォルダに `SKILL.md` があることを確認してください。`validate.sh` が構造をチェックします。

**`/` を入力してもアクションスキルが出ない**

アクションスキルは `disable-model-invocation: true` を持つ通常のスキルです。スキルとして認識されていれば `/` の候補に出ます。スキル自体が検出されていない場合は上の項目を確認してください。

v5 以前から移行した場合、`.cursor/commands/` が残っていると候補が重複します。`validate.sh` が警告するので、確認のうえ削除してください。

**スクリプトが実行できない**

Mac / Linux では `chmod +x` で実行権限を付与してください。Windows では Git Bash または WSL で `bash` を指定して実行します。

**hooks が動かない**

`.cursor/hooks/*.sh` に実行権限があるか確認してください。手元で直接実行して出力を確かめられます。

```bash
echo '{"session_id":"test"}' | .cursor/hooks/inject-knowledge-index.sh
```

**セットアップが途中で止まる**

既存ファイルの上書き確認で入力待ちになっています。非対話環境では自動でスキップされますが、`--yes` を付ければ確認なしで進みます。

## 以前のバージョンからの移行

- v5.x から: [v5 からの移行ガイド](migration-from-v5.md)
- v3.x から: [v3 からの移行ガイド](migration-from-v3.md)
- v2.x（`.cursor/rules` 形式）から: [v2.x からの移行ガイド](migration-from-rules.md)

## 次のステップ

- [スキルの全体像](skills-and-commands.md) — ドメインスキルとアクションスキルの違い
- [スキルガイド](../templates/skills-guide.md) — ドメインスキル 7 種の詳細
- [アクションスキルガイド](../templates/action-skills-guide.md) — アクションスキル 6 種の詳細
- [hooks ガイド](../advanced/hooks-guide.md) — 記録を習慣にする仕組み
- [subagents ガイド](../advanced/subagents-guide.md) — 知識ベースの棚卸し
- [完全ガイド](../cursor-knowledge-management-system.md) — システム全体の設計
- [チーム導入ガイド](../advanced/team-implementation.md) — チーム全体での活用

---

導入後は継続的な更新が成功の鍵です。日々の技術判断を `/record-decision` で記録し続けることで効果が出ます。記録が続かない場合は、[hooks](../advanced/hooks-guide.md) で仕組みとして補うことを検討してください。
