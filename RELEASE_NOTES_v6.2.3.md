# Release Notes — v6.2.3

**リリース日**: 2026-09-26
**Codename**: Literal

v6.2.3 は、hooks の作業ログと、デバッグセッションの検索を直す修正版です。どちらも、入力を文字どおりに扱うようにしました。

## Fixed

- **作業ログのパスが崩れる**: `afterFileEdit`（Cursor）と `PostToolUse`（Claude Code）の hooks は、`sed` でパスを取り出していました。そのため、`"` を含むパスは途中で切れ（例: `src/a "b".ts` → `src/a /`）、Windows ネイティブのパス（`C:\Users\...`）は `C://Users//...` になって、プロジェクトからの相対パスにもなりませんでした。JSON の文字列を 1 文字ずつ読んで取り出し、`C:\...` は `$PWD` と同じ形（Git Bash の `/c/...`、WSL の `/mnt/c/...`、Cygwin の `/cygdrive/c/...`）にそろえます。`\n` などのエスケープは元に戻さず、ログは 1 行 1 件に保ちます
- **`search-sessions.sh` がキーワードを正規表現として扱う**: `[` を含むキーワードはエラーになったうえで「見つかりませんでした」と表示され、`\|` や `.*` では関係のないセッションまで当たっていました。キーワードを文字列そのものとして探します
- **開発者向け文書の dogfooding 手順が開発記録を消す**: CKMS 自身を開発する人向けの `docs/advanced/plugin-development.md` は、`rm -rf .agents` してから作り直す手順でした。`.agents/` は `.gitignore` の対象なので、中の開発記録は Git からも戻せません。`init.sh` の再実行だけで反映する手順に改めました。利用者のプロジェクトには影響しません

## 確認していること

CI で、導入先の hooks と `search-sessions.sh` を実際に動かして確かめています（Linux と Windows の Git Bash）。Git Bash では、`C:\...` 形式のパスが相対パスになることも確かめます。

## 関連

- [CHANGELOG.md](CHANGELOG.md)
- 前リリース: [v6.2.2](RELEASE_NOTES_v6.2.2.md)
