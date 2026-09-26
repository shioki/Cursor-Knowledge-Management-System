---
name: team-standards
description: コーディング規約、命名規則、ブランチ戦略、コミットメッセージ規約、コードレビュー基準について質問があった場合に使用。チーム開発の標準を提供する。
paths:
  - "**/*.{ts,tsx,js,jsx,mjs,cjs}"
  - "**/*.{py,rb,go,rs,java,kt,swift}"
  - "**/*.{c,h,cc,cpp,hpp,cs,php}"
  - "**/*.{vue,svelte,css,scss}"
  - "**/*.{sql,sh,ps1}"
license: MIT
compatibility: Cursor 3.x, Claude Code, Codex
metadata:
  tags: [standards, conventions, code-review]
---

# チーム開発標準

チーム全体で一貫した開発プロセスを維持するための標準規約を提供するスキルです。

## When to Use

- コーディング規約や命名規則について質問があったとき
- コードレビューを行うとき
- ブランチ戦略やコミットメッセージについて質問があったとき
- 新しいチームメンバーのオンボーディング時

## Instructions

### 1. 規約の確認

まず `references/STANDARDS_TEMPLATE.md` を読み込み、チームで合意した規約を把握してください。命名規則、コメント、インポート順序、ブランチ戦略、コミットメッセージ、プルリクエスト、テスト、レビュー観点、セキュリティ基準がまとまっています。

### 2. 規約に沿った回答・レビュー

`STANDARDS_TEMPLATE.md` の規約に従って、コードレビューや提案を行ってください。

チームで新しい規約に合意したら、`STANDARDS_TEMPLATE.md` を更新します。

---

> **カスタマイズ**: 規約は `references/STANDARDS_TEMPLATE.md` に書きます。このファイルは `init.sh` / `init.ps1` を再実行しても残ります。
> この `SKILL.md` は再実行で配布元の内容に置き換わるため、規約をここに書かないでください。
>
> frontmatter の `paths` は、このスキルをソースコード作業中だけ読み込ませるためのスコープ指定です。
> プロジェクトで使う言語に合わせて増減させてください。言語を問わず常に参照させたい場合は
> `paths` の行をすべて削除します。`paths` は `SKILL.md` にあるため、再実行すると初期値に戻ります。
> 変えていた場合は、再実行のあとに入れ直してください。
