# Release Notes — v6.2.4

**リリース日**: 2026-09-26
**Codename**: Anchor

v6.2.4 は、チームの規約を再実行で消えない場所へ移す版です。あわせて、スキルを個別に入れたときの案内を直しました。

## Changed

- **`team-standards` の規約を `references/STANDARDS_TEMPLATE.md` に移した**: これまでは、規約を `team-standards/SKILL.md` に直接書くよう案内していました。ところが v6.2.0 から勧めている `init.sh` / `init.ps1` の再実行は `SKILL.md` を配布元の内容で置き換えるため、更新のたびに規約が初期値へ戻っていました。規約の本体を `references/STANDARDS_TEMPLATE.md` に移し、再実行で残すファイルに加えました。`SKILL.md` は、このファイルを読んで従うよう指示するだけになります

## 更新するときにすること

v6.2.3 以前で `team-standards/SKILL.md` に規約を書いていた場合、再実行すると `SKILL.md` は新しい内容に置き換わり、次のような案内が出ます。

```text
  案内: team-standards の規約は、この版から references/STANDARDS_TEMPLATE.md に書きます（再実行で残ります）。
        SKILL.md の規約を書き換えていた場合は、<退避先>/team-standards/SKILL.md の規約部分を <導入先>/references/STANDARDS_TEMPLATE.md へ移してください。
```

書き換えていた規約は、退避先（`skills.backup-*/team-standards/SKILL.md`）に残っています。規約部分を `STANDARDS_TEMPLATE.md` へ移してください。移したあとの再実行では、案内は出ません。`--no-backup` で再実行した場合は退避していないので、Git の履歴から移してください。

frontmatter の `paths` は仕様上 `SKILL.md` に置くしかないため、変えていた場合は再実行のたびに入れ直す必要があります。

## Fixed

- **スキルを個別に入れると記録用スクリプトが動かない**: `add-entry.sh` などの記録用スクリプトは、`project-setup` スキルにある `_skill-base.sh` を使います。`gh skill install` / `apm install` でスキルを個別に入れる例では、このことを案内していませんでした。README・gh skill 連携・APM 連携に `project-setup` も入れるよう明記し、見つからないときはスクリプトがその旨を表示して止まるようにしました
- **アクションスキルのコマンド例が `.agents/` 決め打ち**: `.claude/skills/` や `.cursor/skills/` に導入した場合（`--legacy-claude`、`--cursor-only`、`gh skill install --agent` など）は、コマンドの先頭を読み替えるよう明記しました

## 関連

- [CHANGELOG.md](CHANGELOG.md)
- [導入済みプロジェクトの更新](docs/getting-started/updating.md)
- 前リリース: [v6.2.3](RELEASE_NOTES_v6.2.3.md)
