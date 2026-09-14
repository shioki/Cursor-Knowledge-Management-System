# GitHub リリース手順

このドキュメントでは、本リポジトリの **push** と **GitHub Release 作成** を確実に行うための設定と手順を説明します。

## よくある事象

- `git push origin main` は成功するが、`gh release create` を実行すると次のメッセージが出て失敗する:
  - `To get started with GitHub CLI, please run: gh auth login`
  - `Alternatively, populate the GH_TOKEN environment variable with a GitHub API authentication token.`

**原因**: Git の認証（SSH や credential helper）と **GitHub CLI (`gh`) の認証は別**です。push には Git 認証だけあれば十分ですが、Release 作成には `gh` の認証が必要です。

## 抜本的解決策（どちらか一方で可）

### 方法 A: GitHub CLI を一度ログインする（推奨・手元のマシン向け）

1. ターミナルで次を実行:
   ```bash
   gh auth login
   ```
2. 表示に従い、**GitHub.com** を選び、**HTTPS** または **SSH**、そして **Login with a web browser**（またはトークン貼り付け）で認証する。
3. 完了後、同じマシンでは `gh release create` がそのまま使えます。

**確認**:
```bash
gh auth status
```
`Logged in to github.com as 〜` と出れば OK です。

### 方法 B: 環境変数 GH_TOKEN を設定する（CI・スクリプト・非対話向け）

`gh` は環境変数 **`GH_TOKEN`**（または `GITHUB_TOKEN`）が設定されていると、対話ログインなしで API にアクセスします。

1. GitHub で **Personal Access Token (PAT)** を発行する  
   - [GitHub → Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)  
   - スコープに少なくとも `repo`（リポジトリと Release 作成に必要）を付与する。
2. 手元のマシンで毎回使う場合（例: bash）:
   ```bash
   export GH_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
   ```
   恒常的に使う場合は `~/.bashrc` や `~/.zshrc` に上記を追記（トークンは他人に見せないこと）。
3. CI（GitHub Actions など）では、シークレットに `GH_TOKEN` または `GITHUB_TOKEN` を設定し、ワークフロー内で `env` に渡す。

**確認**:
```bash
export GH_TOKEN="ghp_あなたのトークン"
gh auth status
```

---

- **手元でだけリリースする** → 方法 A で十分です。  
- **CI でリリースする / スクリプトで非対話に実行したい** → 方法 B（`GH_TOKEN`）を使います。  
- 両方設定していても問題ありません（`gh` はログイン済みならそれを使い、なければ `GH_TOKEN` を参照します）。

## リリースの実行手順

1. **認証の確認**
   ```bash
   gh auth status
   ```
   未ログインの場合は上記「抜本的解決策」の A または B を実施する。

2. **バージョンを揃える**  
   [`.cursor-plugin/plugin.json`](../../.cursor-plugin/plugin.json) と [`apm.yml`](../../apm.yml) の `version` を、これから付けるタグ（`v` を除いた値）に合わせる。  
   揃っていない場合、`scripts/release.sh` は release を作成せずに終了します。README や `init.sh` などの表示文字列も併せて更新してください（一覧は [AGENTS.md](../../AGENTS.md) の「ドキュメントの版数」）。

3. **リリースノートの準備**  
   ルートに `RELEASE_NOTES_vX.Y.Z.md` を用意する（例: `RELEASE_NOTES_v6.1.1.md`）。  
   既に同じ名前のファイルがある場合はそのまま利用してよい。ファイルが無い場合、スクリプトはその時点で停止します。

4. **push（まだの場合）**
   ```bash
   git push origin main
   ```

5. **リリース作成**  
   次のいずれかで実行する。

   **オプション 1: npm スクリプト（推奨）**
   ```bash
   npm run release -- v6.1.1
   ```
   未認証の場合は日本語でエラー案内を表示して終了します。

   本番実行前に、副作用なしで一連の検証だけを走らせることもできます。

   ```bash
   npm run release -- v6.1.1 --dry-run
   ```

   **Windows でリリースする場合**: `scripts/release.sh` は Bash 前提のため、**Git Bash** または **WSL** で `npm run release -- v6.1.1` を実行してください。

   **オプション 2: gh を直接使う**
   ```bash
   gh release create v6.1.1 \
     --title "v6.1.1 - タイトル" \
     --notes-file RELEASE_NOTES_v6.1.1.md
   ```

   この場合は後述の事前検証が走りません。検証を省略したくない場合はオプション 1 を使ってください。

## release.sh が行う事前検証

`npm run release` は、タグを作る前に次の順で確認します。いずれかで問題が見つかると、release を作成せずに終了します。

1. `gh` のインストールと認証
2. `.cursor-plugin/plugin.json` / `apm.yml` の `version` がリリースタグと一致すること
3. `npm run docs:check`（`skills:check` / `components:check` / `plugin:check` / `links:check`）
4. `gh skill publish --dry-run`（`gh skill` が使える場合のみ）
5. `RELEASE_NOTES_<タグ>.md` の存在

3 について、v5 までは `npm` が見つからない環境では検証をスキップしてリリースを続行していました。検証を飛ばせてしまうと検証を組み込んだ意味がないため、v6 からは `npm` が無い場合にエラーで停止します。Node.js を用意してから再実行してください。

**`release.sh` は `gh release create` の後に実際の `gh skill publish` を実行しません。** `gh skill publish`（`--dry-run` を付けない場合）は自分自身がリリース作成の主体になろうとし、`gh release create` が既に作った同じタグを再利用できずに失敗します（`tag_name already exists; choose a different version`）。v6.1.0 でこれを実際に試し、失敗したリリースを削除して `gh skill publish` に作り直させたところ、GitHub の immutable release 保護によって同じタグの再作成そのものが恒久的に拒否されました（結果、`v6.1.0` は欠番です。詳細は [CHANGELOG.md](../../CHANGELOG.md) の v6.1.1 の注記）。

Marketplace / `gh skill` 経由でも配布したい場合は、`gh skill publish --tag vX.Y.Z` を**唯一の**リリース作成手段として使ってください。`release.sh`（`gh release create` ベース）と同じタグに対して両方を実行しないでください。

## トラブルシューティング

| 現象 | 対処 |
|------|------|
| `git push` で Username を聞かれる | Git の認証設定（SSH キーまたは credential helper）を確認する。[GitHub のドキュメント](https://docs.github.com/ja/authentication) を参照。 |
| `gh auth status` で not logged in | 上記「方法 A」の `gh auth login` を実行する。 |
| CI で `gh` が使えない | シークレットで `GH_TOKEN` を設定し、ジョブの `env` に渡しているか確認する。 |
| `npm が見つかりません` で停止する | 事前検証に Node.js が必要です。インストールして再実行する。 |
| `version ... が一致しません` で停止する | `plugin.json` と `apm.yml` の `version` をタグに合わせる。 |
| `リリースノートが見つかりません` で停止する | ルートに `RELEASE_NOTES_<タグ>.md` を作成する。 |

## 関連リンク

- [Marketplace 提出手順](marketplace-submission.md) - 提出前チェックリストと docs:check の内訳
- [gh skill 連携](gh-skill-integration.md) - スキル公開と immutable release
- [GitHub CLI のインストールと認証](https://docs.github.com/ja/get-started/using-github/github-cli)
- [GitHub Release の作成](https://docs.github.com/ja/repositories/releasing-projects-on-github/managing-releases-in-a-repository)
