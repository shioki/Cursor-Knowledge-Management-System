# hooks ガイド

知識管理システムの最大の課題は、記録が続かないことです。スキルは「記録したい」と思った瞬間には役立ちますが、その瞬間自体が訪れないと何も蓄積されません。hooks はエージェントのライフサイクルに割り込み、この「思い出す」部分を仕組みで補います。

CKMS は Cursor と Claude Code の両方に hooks を提供しますが、**スキーマが全く異なる**ため別々のスクリプトになっています。共通のロジック（索引の組み立てなど）は `hooks/_hook-lib.sh` に寄せてあります。

| | Cursor | Claude Code |
|---|--------|-------------|
| 配置 | `hooks/*.sh` + `hooks/hooks.json` | `hooks/claude-code/*.sh` + `.claude/settings.json` |
| 入出力 | stdin/stdout の単純な JSON | stdin/stdout の JSON（イベントごとにキーが異なる） |
| 索引注入イベント | `sessionStart` | `SessionStart` |
| 編集ログイベント | `afterFileEdit` | `PostToolUse`（`matcher: "Edit\|Write"`） |
| 記録提案イベント | `stop`（`followup_message`） | `Stop`（`decision: "block"` + `reason`） |

以降はまず Cursor 版を説明し、最後に Claude Code 版との違いをまとめます。

## CKMS が提供する 3 つの hook

| イベント | スクリプト | 役割 | 既定 |
|---------|-----------|------|------|
| `sessionStart` | `inject-knowledge-index.sh` | 蓄積済み知識の索引を初期コンテキストへ注入する | 有効 |
| `afterFileEdit` | `log-activity.sh` | 編集したファイルを軽量ログに追記する | 有効 |
| `stop` | `suggest-record.sh` | 記録漏れがありそうなときに記録を促す | 無効 |

定義は [hooks/hooks.json](../../hooks/hooks.json) にあります。

## sessionStart — 索引を渡す

会話の開始時に、蓄積済みの技術判断・パターン・改善記録・デバッグセッションの**一覧だけ**を `additional_context` として渡します。

```text
## このプロジェクトに蓄積済みの知識（索引）

ベースディレクトリ: `.agents/`

### 技術判断（12 件）
- `2026-06-18-adopt-postgresql.md` — PostgreSQL を本番 DB として採用
- `2026-05-02-drop-graphql.md` — GraphQL を採用しない判断
...
```

ファイルの中身は読み込みません。エージェントは「何がどこにあるか」だけを知り、必要になった時点で該当ファイルを開きます。索引 1 行あたり数十トークンなので、記録が 50 件あっても初期コストは 1000〜2000 トークン程度に収まります。

これは CKMS が主張する「オンデマンド段階読込」を実際に成立させるための仕組みです。索引が無いと、エージェントはそもそも知識が存在することに気づけません。

カテゴリごとの上限は既定 30 件で、超えた分は「ほか N 件」とだけ表示されます。

## afterFileEdit — 何を触ったかを残す

エージェントがファイルを編集するたびに、日時とパスを `<base>/knowledge-activity.log` に追記します。

```text
2026-07-28T09:12:03	src/auth/session.ts
2026-07-28T09:14:41	src/auth/token.ts
```

このログ自体は知識ではありません。`/review-knowledge` が「頻繁に触っているのに、対応する技術判断もパターンも残っていないモジュール」を洗い出すための材料です。記録漏れは自覚しにくいので、機械的な手がかりが要ります。

知識ベース自身（`<base>/` 配下）の編集は記録しません。記録する行為でログが埋まるのを避けるためです。ログは既定で末尾 500 行だけを保持します。

## stop — 記録を促す（既定で無効）

エージェントが応答を終えたときに、記録に値する作業をしたのに何も残していない場合、`followup_message` で記録を促します。

`followup_message` は次のユーザーメッセージとして**自動送信され、1 ターンを消費します**。この挙動を望まないチームのほうが多いと考えられるため、既定では無効にしています。

### 有効にする

ベースディレクトリに `knowledge-hooks.conf` を作ります。

```ini
suggest_record = true
```

有効にした場合も、次の条件をすべて満たしたときにだけ発火します。

- エージェントが正常終了した（`status` が `completed`）
- その日の編集ファイル数が `suggest_min_files`（既定 3）以上ある
- 最後の編集より後に技術判断ファイルが追加されていない

加えて `loop_limit: 1` を設定しているため、1 つの会話で 2 回以上発火することはありません。

まず 1〜2 週間 `sessionStart` と `afterFileEdit` だけで運用し、記録が定着しないようなら `stop` を足す、という順序をおすすめします。

## 設定

ベースディレクトリ（`.agents/` / `.claude/` / `.cursor/` のうち `skills/` を持つもの）に `knowledge-hooks.conf` を置きます。

```ini
# stop フックによる記録提案を有効にする（既定: false）
suggest_record = true

# 記録提案を出す最小編集ファイル数（既定: 3）
suggest_min_files = 3

# 索引に載せるカテゴリごとの最大件数（既定: 30）
index_max_entries = 30

# 活動ログの最大行数（既定: 500）
activity_log_max_lines = 500
```

このファイルは個人設定なので、リポジトリにコミットせず `.gitignore` に入れることをおすすめします。チームで統一したい場合はコミットしてください。

## 導入方法

### Cursor Plugin として導入した場合

`hooks/hooks.json` が自動で読み込まれます。設定は不要です。

### init.sh で導入した場合

`.cursor/hooks/` にスクリプトが、`.cursor/hooks.json` に定義が配置されます。既に `.cursor/hooks.json` がある場合は上書きせず、追記すべき内容を表示します。

hooks が不要なら `--no-hooks` を付けてください。

```bash
bash skills/project-setup/scripts/init.sh /path/to/project --no-hooks
```

### 手動で導入する場合

`hooks/*.sh` を `.cursor/hooks/` にコピーし、実行権限を付けたうえで `.cursor/hooks.json` を作ります。プロジェクト hooks はプロジェクトルートからの相対パスで解決されるため、`hooks.json` 内のパスを `.cursor/hooks/` 起点に書き換える必要があります。

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      { "command": ".cursor/hooks/inject-knowledge-index.sh", "timeout": 10 }
    ],
    "afterFileEdit": [
      { "command": ".cursor/hooks/log-activity.sh", "timeout": 5 }
    ]
  }
}
```

## Claude Code 版 hooks

Claude Code は Cursor と異なるスキーマを使うため、`hooks/claude-code/` に専用のスクリプトを用意しています。設定は `.claude/settings.json` に書きます（テンプレート: [templates/.claude/settings.json.template](../../templates/.claude/settings.json.template)）。

| スクリプト | 対応する Cursor 版 | イベント |
|-----------|-------------------|---------|
| `hooks/claude-code/session-start.sh` | `inject-knowledge-index.sh` | `SessionStart` |
| `hooks/claude-code/post-tool-use-log-activity.sh` | `log-activity.sh` | `PostToolUse`（`matcher: "Edit\|Write"`） |
| `hooks/claude-code/stop-suggest-record.sh` | `suggest-record.sh` | `Stop` |

設定ファイルの例:

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [{ "type": "command", "command": ".claude/hooks/session-start.sh" }] }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": ".claude/hooks/post-tool-use-log-activity.sh" }]
      }
    ],
    "Stop": [
      { "hooks": [{ "type": "command", "command": ".claude/hooks/stop-suggest-record.sh" }] }
    ]
  }
}
```

`init.sh` を使えば、`.agents/skills` 配置（既定）かつ `--no-claude-bridge` を付けなかった場合に自動で配置されます。

### followup_message との違い

Cursor 版の `stop` フックは `followup_message` を返し、次のユーザーメッセージとして**自動送信**されます。Claude Code の `Stop` hook にはこの仕組みが無いため、代わりに `decision: "block"` + `reason` を使います。これは「まだ応答を終えるべきではない理由」として Claude に渡され、応答が継続する形になります。ユーザーの新しい発言として扱われる Cursor 版とは体感が異なる点に注意してください。

無限ループを避けるため、`stop-suggest-record.sh` は入力 JSON に `stop_hook_active: true`（直前の `Stop` hook の block によって発生したイベントであることを示すフィールド）が含まれる場合は何もしません。このフィールド名は Claude Code のバージョンによって変わる可能性があるため、導入後は実際に無限ループしないか確認してください。

### 動作確認

```bash
echo '{"session_id":"test"}' | .claude/hooks/session-start.sh
echo '{"tool_name":"Edit","tool_input":{"file_path":"'"$PWD"'/src/app.ts"}}' | .claude/hooks/post-tool-use-log-activity.sh
echo '{"status":"completed"}' | .claude/hooks/stop-suggest-record.sh
```

`hookSpecificOutput` のキー名（`additionalContext` など）は Claude Code のバージョンによって変わりうる仕様です。導入したバージョンで実際に会話へ反映されるか確認してください。

## 無効化と削除

不要な hook は `hooks.json` から該当エントリを削除してください。すべて不要ならファイルごと削除して構いません。hooks が無くてもスキルは通常どおり動作します。

## 動作条件

スクリプトは `jq` / `python` / `node` に依存しません。POSIX シェルと `sed` / `awk` / `find` だけを使います。Windows では Git Bash または WSL が必要です。

知識ベース（`skills/` を含む `.agents/` / `.claude/` / `.cursor/` のいずれか）が見つからない場合、すべての hook は空の JSON を返して何もしません。導入直後で記録が 0 件でも、エラーにはなりません。

## トラブルシューティング

### 索引が注入されない

- ベースディレクトリが検出できているか確認してください。`.agents/skills/` などが存在する必要があります
- 手元で直接実行して出力を確認できます

```bash
echo '{"session_id":"test"}' | .cursor/hooks/inject-knowledge-index.sh
```

正常なら `{"additional_context":"..."}` が、知識が 0 件なら `{}` が返ります。

### hook が実行されない

実行権限を確認してください。

```bash
chmod +x .cursor/hooks/*.sh
```

`bash .agents/skills/project-setup/scripts/validate.sh` でも権限をチェックできます。

### 記録提案が出ない

既定で無効です。`knowledge-hooks.conf` に `suggest_record = true` を書いたうえで、その日の編集が 3 ファイル以上あるか確認してください。

## 関連

- [hooks/README.md](../../hooks/README.md) — スクリプトの仕様
- [subagents ガイド](subagents-guide.md)
- [Cursor Hooks 公式ドキュメント](https://cursor.com/ja/docs/agent/hooks)
- [Claude Code Hooks 公式ドキュメント](https://code.claude.com/docs/en/hooks)
