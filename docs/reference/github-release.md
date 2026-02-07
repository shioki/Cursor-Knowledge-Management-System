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

2. **リリースノートの準備**  
   ルートに `RELEASE_NOTES_vX.Y.Z.md` を用意する（例: `RELEASE_NOTES_v3.0.0.md`）。  
   既に同じ名前のファイルがある場合はそのまま利用してよい。

3. **push（まだの場合）**
   ```bash
   git push origin main
   ```

4. **リリース作成**  
   次のいずれかで実行する。

   **オプション 1: npm スクリプト（推奨）**
   ```bash
   npm run release -- v3.0.0
   ```
   未認証の場合は日本語でエラー案内を表示して終了します。

   **オプション 2: gh を直接使う**
   ```bash
   gh release create v3.0.0 \
     --title "v3.0.0 - タイトル" \
     --notes-file RELEASE_NOTES_v3.0.0.md
   ```

## トラブルシューティング

| 現象 | 対処 |
|------|------|
| `git push` で Username を聞かれる | Git の認証設定（SSH キーまたは credential helper）を確認する。[GitHub のドキュメント](https://docs.github.com/ja/authentication) を参照。 |
| `gh auth status` で not logged in | 上記「方法 A」の `gh auth login` を実行する。 |
| CI で `gh` が使えない | シークレットで `GH_TOKEN` を設定し、ジョブの `env` に渡しているか確認する。 |

## 関連リンク

- [GitHub CLI のインストールと認証](https://docs.github.com/ja/get-started/using-github/github-cli)
- [GitHub Release の作成](https://docs.github.com/ja/repositories/releasing-projects-on-github/managing-releases-in-a-repository)
