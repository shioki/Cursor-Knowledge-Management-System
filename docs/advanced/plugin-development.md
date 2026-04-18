# Cursor Plugin 開発ガイド

本リポジトリは **Cursor Plugin** として配布可能な構造になっています。このドキュメントでは、ローカルテストから Marketplace 提出までの手順を解説します。

## プラグイン構成

プラグインのマニフェストは [.cursor-plugin/plugin.json](../../.cursor-plugin/plugin.json) に置かれています。

```json
{
  "name": "cursor-knowledge-management-system",
  "version": "5.0.0",
  "paths": {
    "skills": "templates/.agents/skills",
    "commands": "templates/.cursor/commands"
  }
}
```

`paths` フィールドで、スキルとコマンドのソースディレクトリを明示しています。Cursor の Plugin ローダーはこれらのパスを読み取り、`templates/.agents/skills/` 配下の各スキルと `templates/.cursor/commands/` 配下の各コマンドを自動検出します。

## ローカルテスト

本リポジトリを Cursor にローカルインストールして動作確認する手順です。

### 1. シンボリックリンクで読み込む

```bash
# Mac/Linux
mkdir -p ~/.cursor/plugins/local
ln -s "$(pwd)" ~/.cursor/plugins/local/cursor-knowledge-management-system
```

```powershell
# Windows (PowerShell 管理者)
New-Item -ItemType Directory -Path "$HOME\.cursor\plugins\local" -Force
New-Item -ItemType SymbolicLink `
  -Path "$HOME\.cursor\plugins\local\cursor-knowledge-management-system" `
  -Target (Get-Location).Path
```

### 2. Cursor を再起動

`Cmd/Ctrl+Shift+P` → **Developer: Reload Window** を実行するか、Cursor 自体を再起動してください。

### 3. 読み込み確認

- **Cursor Settings → Rules** でスキル 7 種が「Agent Decides」セクションに表示されることを確認
- チャットで `/` を入力してコマンド 7 種が候補に表示されることを確認

### 4. 外す

ローカルテストを終えたら、シンボリックリンクを削除してください。

```bash
rm ~/.cursor/plugins/local/cursor-knowledge-management-system
```

## マニフェストの検証

構造や必須フィールドをチェックするスクリプトを用意しています。

```bash
npm run plugin:check
```

内部で以下を確認します:

- `.cursor-plugin/plugin.json` の JSON パース可否
- `name`, `version`, `description`, `author`, `license` の存在
- `paths.skills` / `paths.commands` が指すディレクトリの存在
- `apm.yml` の基本スキーマ（APM 対応時）

## Marketplace への提出

Cursor 公式の [Marketplace 提出フォーム](https://cursor.com/marketplace/publish) から審査にかけます。提出前のチェックリストは [docs/reference/marketplace-submission.md](../reference/marketplace-submission.md) を参照してください。

## 関連ドキュメント

- [Cursor Plugins 公式ドキュメント](https://cursor.com/ja/docs/plugins)
- [Cursor プラグインテンプレート](https://github.com/cursor/plugin-template)
- [Marketplace セキュリティレビュー](https://cursor.com/help/security-and-privacy/marketplace-security)
