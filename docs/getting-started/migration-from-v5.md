# v5 から v6 への移行ガイド

v6.0.0 はメジャーバージョンアップです。配布側のディレクトリ構造が変わり、コマンドがスキルに統合されました。利用側プロジェクトへの影響は限定的ですが、いくつか手を動かす必要があります。

## 何が変わったか

### 1. コマンドがアクションスキルになった

`.cursor/commands/` にあった 7 つのコマンドのうち 6 つは、`disable-model-invocation: true` を持つスキルに変換され、`skills/` に統合されました。

`/record-decision` などの呼び出し方は変わりません。Cursor 以外のエージェントからも使えるようになったのが違いです。

`/migrate-from-rules` は廃止しました。Cursor に組み込みの `/migrate-to-skills` と役割が重複し、対象である v2.x の rules 形式は 4 メジャーバージョン前のものだからです。

### 2. 知識が 1 概念 1 ファイルになった

v5 では `KNOWLEDGE_TEMPLATE.md` のような単一ファイルに追記し続ける方式でした。v6 では判断・パターン・改善のそれぞれを個別ファイルにし、ディレクトリごとの `README.md` を索引にします。

| 種類 | v6 の保存先 |
|------|------------|
| 技術判断 | `<base>/skills/knowledge-management/references/decisions/YYYY-MM-DD-スラッグ.md` |
| 実装パターン | `<base>/skills/pattern-library/references/patterns/スラッグ.md` |
| 改善記録 | `<base>/skills/improvement-tracking/references/improvements/YYYY-MM-DD-スラッグ.md` |
| デバッグセッション | `<base>/debug-sessions/YYYY-MM-DD_スラッグ.md`（変更なし） |

### 3. hooks と subagent が追加された

記録の習慣化を支援する hooks 3 種と、知識ベース棚卸し用の subagent 1 種が加わりました。どちらも任意で、無くてもスキルは動作します。

### 4. 配布リポジトリの構造が変わった

スキルの実体が `templates/.agents/skills/` から**リポジトリ直下の `skills/`** に移りました。drift していた複製 `templates/.cursor/skills/` は削除しました。

この変更は配布側の話なので、利用側プロジェクトの `.agents/skills/` という配置は変わりません。ただしセットアップスクリプトのパスが変わります。

```bash
# v5
bash path/to/CKMS/templates/.agents/skills/project-setup/scripts/init.sh /path/to/project

# v6
bash path/to/CKMS/skills/project-setup/scripts/init.sh /path/to/project
```

### 5. plugin.json が公式スキーマ準拠になった

v5 のマニフェストは公式スキーマに存在しない `paths` / `compatibility` を使っており、`repository` の型も誤っていました。スキーマは `additionalProperties: false` なので、このマニフェストではコンポーネントが読み込まれません。v6 で修正済みです。

Cursor Marketplace またはローカルプラグインとして v5 を使っていた場合、スキルが認識されていなかった可能性があります。v6 で解消します。

## 移行手順

### 手順 1: 既存の記録をバックアップする

```bash
cd /path/to/your-project
cp -r .agents .agents.v5-backup
```

`.claude/` または `.cursor/` に配置している場合はそちらを対象にしてください。

### 手順 2: v6 を上書き導入する

```bash
git -C /path/to/Cursor-Knowledge-Management-System pull
bash /path/to/Cursor-Knowledge-Management-System/skills/project-setup/scripts/init.sh /path/to/your-project
```

`.agents/skills` が既に存在するため上書き確認が出ます。`y` を選んでください。

**注意**: `skills/*/references/` 配下の記録も上書きされます。手順 1 のバックアップから、次のファイルを書き戻してください。

- `knowledge-management/references/KNOWLEDGE_TEMPLATE.md`
- `pattern-library/references/PATTERNS_TEMPLATE.md`
- `improvement-tracking/references/IMPROVEMENTS_TEMPLATE.md`
- `project-context/references/CONTEXT_TEMPLATE.md`
- `debug-workflow/references/DEBUG_TEMPLATE.md`

```bash
for f in knowledge-management/references/KNOWLEDGE_TEMPLATE.md \
         pattern-library/references/PATTERNS_TEMPLATE.md \
         improvement-tracking/references/IMPROVEMENTS_TEMPLATE.md \
         project-context/references/CONTEXT_TEMPLATE.md \
         debug-workflow/references/DEBUG_TEMPLATE.md; do
  cp ".agents.v5-backup/skills/$f" ".agents/skills/$f"
done
```

`.agents/debug-sessions/` は上書きされないので、そのまま残ります。

### 手順 3: 旧コマンドを削除する

```bash
rm -rf .cursor/commands
```

残しておくと `/` の候補にアクションスキルと旧コマンドが両方表示され、どちらが動いたのか分からなくなります。`validate.sh` が残存を警告します。

`.cursor/commands/` に自作のコマンドを追加していた場合は、そのファイルだけを残してください。

### 手順 4: 検証する

```bash
bash .agents/skills/project-setup/scripts/validate.sh
```

エラー 0 件・警告 0 件になれば移行完了です。

### 手順 5: team-standards をカスタマイズし直す

`team-standards/SKILL.md` をプロジェクト向けに編集していた場合、手順 2 で上書きされています。バックアップから内容を戻したうえで、v6 で追加された frontmatter の `paths` を確認してください。

```yaml
paths:
  - "**/*.{ts,tsx,js,jsx,mjs,cjs}"
  - "**/*.{py,rb,go,rs,java,kt,swift}"
```

このスコープに合致するファイルを扱っているときだけスキルが読み込まれます。プロジェクトで使う言語に合わせて増減させてください。言語を問わず常に参照させたい場合は `paths` の行をすべて削除します。

## 既存の記録はどうなるか

v5 形式の `*_TEMPLATE.md` に追記された記録は**そのまま読めます**。v6 のスキルは、個別ファイルの索引とレガシーファイルの両方を参照するよう書かれています。

一括変換ツールは用意していません。判断ごとに「まだ有効か」「切り出す価値があるか」を人が判断すべきだからです。次のいずれかを選んでください。

**そのまま残す** — 何もしなくて構いません。新規記録だけが個別ファイルになり、古い記録はレガシーファイルに残ります。

**少しずつ切り出す** — `/review-knowledge` を実行すると `knowledge-curator` がレガシーファイルも走査します。価値の高い判断から個別ファイルへ移してください。

**まとめて切り出す** — 記録数が少ない場合は、`/record-decision` で新しいファイルを作り、レガシーファイルから内容を移してください。移し終えたセクションはレガシーファイルから削除します。

## hooks を使うかどうか

hooks は v6 の新機能で、導入は任意です。

- `sessionStart` と `afterFileEdit` は既定で有効です。会話の開始時に知識の索引が渡され、編集したファイルがログに残ります
- `stop`（記録提案）は既定で無効です。有効にすると 1 ターンを消費するため、まず 2 つで運用してから判断することをおすすめします

不要なら `--no-hooks` を付けて導入するか、`.cursor/hooks.json` を削除してください。詳細は [hooks ガイド](../advanced/hooks-guide.md) にあります。

## トラブルシューティング

**`/record-decision` が候補に出ない**

`.agents/skills/record-decision/SKILL.md` が存在するか確認してください。存在するのに出ない場合、Cursor を再起動（`Developer: Reload Window`）してください。

**`/` の候補が重複する**

`.cursor/commands/` が残っています。手順 3 を実行してください。

**過去の技術判断が参照されなくなった**

`KNOWLEDGE_TEMPLATE.md` が手順 2 で上書きされた可能性があります。バックアップから書き戻してください。

**hooks が邪魔になる**

```bash
rm .cursor/hooks.json
```

スキルの動作には影響しません。

## 元に戻す

```bash
cd /path/to/your-project
rm -rf .agents .cursor/hooks .cursor/hooks.json .cursor/agents
mv .agents.v5-backup .agents
git -C /path/to/Cursor-Knowledge-Management-System checkout v5.0.1
```

v5 のコマンドが必要な場合は、そのタグから `templates/.cursor/commands` をコピーし直してください。

## 関連

- [クイックスタート](quick-start.md)
- [スキルの全体像](skills-and-commands.md)
- [hooks ガイド](../advanced/hooks-guide.md)
- [subagents ガイド](../advanced/subagents-guide.md)
