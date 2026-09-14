# CKMS hooks

エージェントのライフサイクルに合わせて知識管理を補助する hooks です。このディレクトリ直下は **Cursor 用**で、Cursor Plugin として導入した場合は自動で読み込まれ、`init.sh` で導入した場合は `.cursor/hooks/` と `.cursor/hooks.json` に配置されます。

**Claude Code 用**は `claude-code/` サブディレクトリです。スキーマが異なるため別スクリプトになっています（詳細は [hooks ガイド](../docs/advanced/hooks-guide.md)）。`init.sh` では `.claude/hooks/` と `.claude/settings.json` に配置されます。

## 提供する hooks（Cursor）

| イベント | スクリプト | 役割 | 既定 |
|---------|-----------|------|------|
| `sessionStart` | `inject-knowledge-index.sh` | 蓄積済み知識の索引を初期コンテキストへ注入する | 有効 |
| `afterFileEdit` | `log-activity.sh` | 編集したファイルを軽量ログに追記する | 有効 |
| `stop` | `suggest-record.sh` | 記録漏れがありそうなときに記録を促す | **無効** |

`sessionStart` が注入するのは索引だけで、知識ファイル本体は読み込みません。「どこに何があるか」をエージェントに知らせ、実際の読み込みは必要になった時点で行わせる設計です。索引の組み立ては `_hook-lib.sh` の `ckms_build_knowledge_index` が担い、`claude-code/session-start.sh` とも共通です。

## 提供する hooks（Claude Code）

| イベント | スクリプト | 役割 | 既定 |
|---------|-----------|------|------|
| `SessionStart` | `claude-code/session-start.sh` | 同上 | 有効 |
| `PostToolUse`（`matcher: "Edit\|Write"`） | `claude-code/post-tool-use-log-activity.sh` | 同上 | 有効 |
| `Stop` | `claude-code/stop-suggest-record.sh` | 同上（`decision: "block"` + `reason` を使用） | **無効** |

## 設定

ベースディレクトリ（`.agents/` / `.claude/` / `.cursor/` のうち `skills/` を持つもの）に `knowledge-hooks.conf` を置くと挙動を変更できます。

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

## stop フックについて

`stop` フックが返す `followup_message` は次のユーザーメッセージとして自動送信されるため、1 ターン分のコストがかかります。この挙動を望まないチームのほうが多いと考えられるため、既定では無効にしています。

有効にした場合も次の条件をすべて満たしたときにだけ発火します。

- `knowledge-hooks.conf` で `suggest_record = true` になっている
- エージェントが正常終了した（`status` が `completed`）
- その日の編集ファイル数が `suggest_min_files` 以上ある
- 最後の編集より後に技術判断ファイルが追加されていない

加えて `loop_limit: 1` を設定しているため、1 つの会話で 2 回以上発火することはありません。

## 依存関係

`jq` / `python` / `node` に依存しません。POSIX シェルと `sed` / `awk` / `find` のみを使います。Windows では Git Bash または WSL が必要です。

## 無効化

不要な hook は Cursor なら `hooks.json`（プロジェクト導入時は `.cursor/hooks.json`）、Claude Code なら `.claude/settings.json` の `hooks` から該当エントリを削除してください。すべて不要な場合はファイルごと削除して問題ありません。hooks が無くてもスキルは通常どおり動作します。
