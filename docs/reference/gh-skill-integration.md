# gh skill 連携

GitHub CLI に追加された [`gh skill`](https://github.blog/changelog/2026-04-16-manage-agent-skills-with-github-cli/) コマンドを使うと、本リポジトリの個別スキルを GitHub から直接インストール・更新できます。

## 前提条件

- GitHub CLI `v2.90.0` 以上
  ```bash
  gh --version
  gh extension upgrade --all
  ```

## 個別スキルのインストール

### Cursor 向け

```bash
# 最新
gh skill install shioki/Cursor-Knowledge-Management-System knowledge-management --agent cursor

# タグ指定
gh skill install shioki/Cursor-Knowledge-Management-System knowledge-management@v5.0.1 --agent cursor

# タグ固定（以降 gh skill update でも更新されない）
gh skill install shioki/Cursor-Knowledge-Management-System knowledge-management --agent cursor --pin v5.0.1
```

インストール先は `--agent cursor` の場合、自動的に `.cursor/skills/` または `~/.cursor/skills/` になります。`--scope user` を付けるとユーザーグローバルにインストールされます。

### Claude Code 向け

```bash
gh skill install shioki/Cursor-Knowledge-Management-System debug-workflow --agent claude-code
```

### Codex 向け

```bash
gh skill install shioki/Cursor-Knowledge-Management-System pattern-library --agent codex
```

## 対話的インストール

特定のスキルを指定せずにリポジトリを指定すれば、一覧から選択できます:

```bash
gh skill install shioki/Cursor-Knowledge-Management-System --agent cursor
```

## 更新

```bash
# 全スキルの更新確認
gh skill update

# 個別更新
gh skill update knowledge-management

# 全部更新
gh skill update --all
```

`gh skill` は SKILL.md の frontmatter に埋め込まれた provenance（repo / ref / tree SHA）を使って、実際に内容が変わっているかどうかを検出します。

## プレビュー

インストール前に内容を確認するには:

```bash
gh skill preview shioki/Cursor-Knowledge-Management-System knowledge-management
```

## 検索

```bash
gh skill search knowledge-management
```

## 本パッケージの gh skill publish 対応

本リポジトリでは、すべての SKILL.md に以下のフロントマターを揃えており、`gh skill publish` のバリデーションを通る構成になっています:

- `name`
- `description`
- `license`
- `compatibility`
- `metadata.tags`

### メンテナ向け: リリース時の検証

新しいバージョンをタグとして push する前に、以下で検証できます:

```bash
gh skill publish
```

問題があれば `gh skill publish --fix` で frontmatter を自動補修できます。

### Immutable release の有効化

本パッケージのサプライチェーン保全のため、GitHub リポジトリ設定で **immutable releases** を有効化してください:

**Settings → Rules → Releases → Require immutable**

これにより、公開済みのタグやリリースアセットが（管理者であっても）書き換えられなくなり、`gh skill install --pin` で固定したユーザーは常に同じ内容を取得できるようになります。

## 参考

- [Manage agent skills with GitHub CLI](https://github.blog/changelog/2026-04-16-manage-agent-skills-with-github-cli/)
- [gh skill documentation](https://cli.github.com/manual/gh_skill)
- [Agent Skills 標準仕様](https://agentskills.io)
