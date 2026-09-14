# gh skill 連携

GitHub CLI に追加された [`gh skill`](https://github.blog/changelog/2026-04-16-manage-agent-skills-with-github-cli/) コマンドを使うと、本リポジトリの個別スキルを GitHub から直接インストール・更新できます。

## 前提条件

- GitHub CLI `v2.90.0` 以上
  ```bash
  gh --version
  gh extension upgrade --all
  ```

## スキルの置き場所

本リポジトリのスキルは、リポジトリ直下の `skills/` にあります。`gh skill` はリポジトリのルートからスキルディレクトリを探索するため、追加のオプションなしでそのまま見つかります。

v5 までは `templates/.agents/skills/` に置いていましたが、`gh skill` は `--allow-hidden-dirs` を指定しない限りドットで始まるディレクトリの配下を走査しません。そのため v5 の利用者は毎回このフラグを付ける必要がありました。v6 で配置をルートの `skills/` に移したことで、この制約は解消しています。

## 個別スキルのインストール

### Cursor 向け

```bash
# 最新
gh skill install shioki/Cursor-Knowledge-Management-System knowledge-management --agent cursor

# タグ指定
gh skill install shioki/Cursor-Knowledge-Management-System knowledge-management@v6.1.1 --agent cursor

# タグ固定（以降 gh skill update でも更新されない）
gh skill install shioki/Cursor-Knowledge-Management-System knowledge-management --agent cursor --pin v6.1.1
```

インストール先は `--agent cursor` の場合、自動的に `.cursor/skills/` または `~/.cursor/skills/` になります。`--scope user` を付けるとユーザーグローバルにインストールされます。

### Claude Code 向け

```bash
gh skill install shioki/Cursor-Knowledge-Management-System debug-workflow --agent claude-code
```

`--agent claude-code` は `.claude/skills/` に直接インストールするため、`init.sh` のようなシンボリックリンク橋渡しは不要です（スキル自体はこの経路が一番シンプルです）。ただし `gh skill install` が扱うのはスキル単体のみで、hooks（`hooks/claude-code/` + `.claude/settings.json`）や `CLAUDE.md` の生成は行いません。

`gh skill` に post-install hook は無く、スキルコピー以外をこの経路で自動化する手段はありません。hooks と `CLAUDE.md` も使いたい場合は [README.md の「手動コピー」](../../README.md#手動コピー) か `init.sh` を使ってください。スキルだけ Claude Code に載せたい用途では、`--agent claude-code` で完結します。

### Codex 向け

```bash
gh skill install shioki/Cursor-Knowledge-Management-System pattern-library --agent codex
```

### アクションスキルを入れる場合

`/record-decision` のようなスラッシュ起動のワークフローも、v6 からはスキルとして配布されています。コマンド名がそのままスキル名です。

```bash
gh skill install shioki/Cursor-Knowledge-Management-System record-decision --agent cursor
```

アクションスキルは記録先のディレクトリ構成を対応するドメインスキルと共有します。`record-decision` は `knowledge-management` の `references/decisions/` に書き込むため、両方を入れておくと参照と記録の双方が揃います。

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

本リポジトリでは、13 個すべての SKILL.md に以下のフロントマターを揃えており、`gh skill publish` のバリデーションを通る構成になっています:

- `name`（フォルダ名と一致する kebab-case）
- `description`
- `license`
- `compatibility`
- `metadata.tags`

`npm run skills:check` がこれらを Agent Skills 仕様に沿って検証します。仕様に無い最上位キーは Cursor 側で無視されるため、見つかった場合は警告します。

### メンテナ向け: リリース時の検証

新しいバージョンをタグとして push する前に、以下で検証できます:

```bash
# 公開せずに検証だけ行う
npm run skill:check
```

`npm run skill:check` は `gh skill publish --dry-run` のエイリアスです。`npm run release -- vX.Y.Z`（`scripts/release.sh`）も内部で同じ dry-run を実行するため、リリース手順に沿っていれば個別に叩く必要はありません。問題があれば `gh skill publish --fix` で frontmatter を自動補修できます。

**`gh skill publish`（`--dry-run` を付けない実際の公開）と `npm run release -- vX.Y.Z` は同じタグに対して併用できません。** どちらも自分自身がリリース作成の主体になろうとするため、片方が作ったタグをもう片方が再利用しようとして `tag_name already exists` で失敗します。`v6.1.0` はこれを実際に踏み、リリースを削除して作り直そうとした結果、GitHub の immutable release 保護によりタグの再作成自体が恒久的に拒否されました（欠番になった経緯は [CHANGELOG.md](../../CHANGELOG.md) の v6.1.1 の注記を参照）。

Marketplace / `gh skill` での配布を主にしたい場合は、`scripts/release.sh` を使わず `gh skill publish --tag vX.Y.Z` を唯一のリリース作成手段にしてください:

```bash
gh skill publish --tag vX.Y.Z
```

### Immutable release の有効化

本パッケージのサプライチェーン保全のため、GitHub リポジトリ設定で **release immutability** を有効化してください:

**Settings → General → Releases → Enable release immutability**

これにより、公開済みのタグやリリースアセットが（管理者であっても）書き換えられなくなり、`gh skill install --pin` で固定したユーザーは常に同じ内容を取得できるようになります。

## 参考

- [Manage agent skills with GitHub CLI](https://github.blog/changelog/2026-04-16-manage-agent-skills-with-github-cli/)
- [gh skill documentation](https://cli.github.com/manual/gh_skill)
- [Agent Skills 標準仕様](https://agentskills.io)
