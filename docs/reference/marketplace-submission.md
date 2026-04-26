# Cursor Marketplace 提出手順

Cursor Marketplace は公開前に手動セキュリティレビューが行われます。本ドキュメントは、本プラグイン（Cursor Knowledge Management System）を Marketplace に提出する際のチェックリストと手順を示します。

## 提出前チェックリスト

### 必須

- [ ] [.cursor-plugin/plugin.json](../../.cursor-plugin/plugin.json) の `version` が最新のリリースタグと一致している
- [ ] `npm run docs:check` が全てパスしている（skills / commands / plugin / links）
- [ ] 各 SKILL.md のフロントマターに `name` / `description` / `license` が揃っている
- [ ] README.md にインストール方法（init.sh / gh skill / apm）が記載されている
- [ ] [LICENSE](../../LICENSE) ファイルがリポジトリルートに存在する
- [ ] 最新の [CHANGELOG.md](../../CHANGELOG.md) にリリースノートが反映されている

### 推奨

- [ ] GitHub リポジトリで **immutable releases** を有効化している（`Settings → Rules → Releases → Require immutable`）
- [ ] **Tag protection** を設定し、勝手にタグを書き換えられないようにしている
- [ ] **Secret scanning** を有効化している
- [ ] **Code scanning** を有効化している（CodeQL など）
- [ ] パブリックな [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish) からの提出が通る状態（メタデータ・サムネイル完備）

## 提出手順

### 1. 最終チェック

```bash
npm run docs:check
```

### 2. タグとリリースを作成

```bash
npm run release -- v5.0.1
```

### 3. Marketplace へ提出

[cursor.com/marketplace/publish](https://cursor.com/marketplace/publish) を開き、以下を提出します:

- GitHub リポジトリ URL（例: `https://github.com/shioki/Cursor-Knowledge-Management-System`）
- プラグインの概要説明（`.cursor-plugin/plugin.json` の description を流用）
- スクリーンショット（推奨）
- プラグインのカテゴリ（Knowledge Management / Developer Tools など）

### 4. セキュリティレビュー

Cursor チームが以下を手動で確認します:

- プラグインが悪意のあるコード・スクリプトを含まないこと
- MCP サーバー定義の安全性（本プラグインでは未同梱）
- 依存関係の整合性
- README / ドキュメントの正確性

レビューは通常 2 〜 7 営業日です。

### 5. 公開

承認されると Marketplace に掲載されます。以降のアップデートは Git タグをプッシュする毎にレビューを受ける形になります。

## アップデートの流れ

1. 機能追加・修正をブランチで行う
2. [CHANGELOG.md](../../CHANGELOG.md) にエントリを追加
3. `.cursor-plugin/plugin.json` の `version` をインクリメント
4. `npm run release -- vX.Y.Z` でタグ付与と GitHub Release を作成
5. Marketplace 側で自動的に新しいバージョンが検出され、再レビューされる

## 参考

- [Cursor Plugins 公式ドキュメント](https://cursor.com/ja/docs/plugins)
- [Marketplace security review](https://cursor.com/help/security-and-privacy/marketplace-security)
- [Cursor Marketplace](https://cursor.com/marketplace)
