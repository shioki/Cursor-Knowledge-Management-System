# 導入済みプロジェクトの更新

CKMS の配布元を更新したあと、導入先へ反映する手順です。初回導入は [クイックスタート](quick-start.md) を参照してください。

## 再実行する

配布元を最新にしてから、最初と同じコマンドで `init.sh` / `init.ps1` を再実行します。

```bash
git -C /path/to/Cursor-Knowledge-Management-System pull
bash /path/to/Cursor-Knowledge-Management-System/skills/project-setup/scripts/init.sh /path/to/your-project
```

Windows では同じディレクトリの `init.ps1` を使います。確認なしで進めるときは `--yes`（PowerShell では `-Yes`）を付けます。

再実行で置き換わるのは、配布元にある CKMS のスキルです。次は残ります。

- 判断記録・パターン・改善記録（`decisions/`、`patterns/`、`improvements/`）
- 各スキルの `references/*_TEMPLATE.md`（v5 以前の記録、`project-context` の文脈、`team-standards` の規約）
- プロジェクト固有のスキルと、ほかの配布元が `.agents/skills/` に置いたスキル
- 配布元から無くなったスキル（削除せず、残した旨を表示します）

`decisions/` などの記録ディレクトリでは、同じパスのファイルは利用者の内容が優先されます。配布元がそのディレクトリに新しく足したファイルは残ります。記録ディレクトリをシンボリックリンク（Windows ではジャンクションも）にしている場合は、リンクのまま残します。リンク先には配布元のファイルを足しません。

置き換える前に、導入先の `skills/` を隣の `skills.backup-YYYYmmdd-HHMMSS/` へ退避します。退避が不要なときは `--no-backup`（PowerShell では `-NoBackup`）を付けます。退避先を Git に含めない例は [チーム導入ガイド](../advanced/team-implementation.md) にあります。

`SKILL.md` は再実行で配布元の内容になります。配布元と違っていれば警告します。版を上げただけで、手元で書き換えていなくても出ます。カスタマイズしていた場合はバックアップから戻してください。`SKILL.md` 以外の配布ファイル（`scripts/*.sh` など）は、警告なしで置き換わります。

`team-standards` の規約は、v6.2.4 から `team-standards/references/STANDARDS_TEMPLATE.md` に書きます。このファイルは再実行で残ります。v6.2.3 以前に規約を `team-standards/SKILL.md` へ直接書いていた場合は、再実行のときに案内が出るので、退避先（`skills.backup-*/team-standards/SKILL.md`）から規約部分を `STANDARDS_TEMPLATE.md` へ移してください。frontmatter の `paths` は `SKILL.md` にあるため、変えていた場合は再実行のたびに入れ直します。

`.cursorignore` は既にある場合は上書きしません。配布元と内容が違うときだけ、その旨を表示します。v6.1.1 以前に導入した `.cursorignore` には退避先の除外が無く、`skills.backup-*/` の古い記録が Cursor の索引に入ります。その場合は追加する行を表示するので、`.cursorignore` に足してください。

```gitignore
.agents/skills.backup-*/
.claude/skills.backup-*/
.cursor/skills.backup-*/
```

`.cursor/hooks.json` も、既にあれば `.cursorignore` と同じく上書きしません。`.cursor/agents/*.md` は、確認に yes と答えたとき（`--yes` / `-Yes` を含む）に配布元の内容で上書きされます。

`.claude/skills` が `.agents/skills` へのシンボリックリンクなら、再実行の結果はそのまま見えます。リンクを作れずにコピーした場合は、再実行しても「既に存在します」となり、コピー側は古いままです。Claude Code がそのコピー側に記録を書いていることがあるので、コピーを消す前に `decisions/`、`patterns/`、`improvements/`、`references/*_TEMPLATE.md` を `.agents/skills` の同じ位置へ移してください。同じファイルが両方にあるときは、残すほうを確認してから移します。移したあとでコピーを削除し、再実行するとリンクを作り直します。

記録ディレクトリの中で、配布元にもあるファイル（索引の `README.md` など）を消していても、再実行で戻ります。同じパスでは利用者の内容が優先されます。使うスクリプトは、更新する CKMS リポジトリの `init.sh` / `init.ps1` にしてください。別のプロジェクトに入っているスクリプトを使うと、そのプロジェクトの記録が導入先に入ります。初回導入でも同じ警告が出ます。

`--legacy-claude`（`.claude/skills`）と `--cursor-only`（`.cursor/skills`）でも同じです。導入先にある `init.sh` を、その導入先自身に向けては実行できません。CKMS リポジトリ側のスクリプトを使ってください。

## v6.1.1 以前の再実行で記録が消えたとき

v6.0.0 から v6.1.1 の `init.sh --yes`（対話で上書きに `y` と答えた場合も同じ）は、導入先の `skills/` を削除してから作り直していました。判断記録、プロジェクト固有のスキル、ほかの配布元のスキルが消えます。`init.ps1` も同じでした。

残っている場合は、次から戻してください。

- 導入先リポジトリの Git 履歴（消える前のコミットから該当ファイルを復元する）
- そのとき手元に残したコピー

v6.2.0 以降の再実行では、上記の記録とスキルは削除しません。
