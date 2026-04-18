# AGENTS.md 運用ガイド

[Cursor Rules](https://cursor.com/ja/docs/rules) でサポートされる `AGENTS.md` は、プロジェクトルート（および任意のサブディレクトリ）に配置する軽量な Markdown ファイルです。フロントマターを持たないシンプル形式なので、`.cursor/rules/*.mdc` より保守しやすく、チームで共通の指示を素早く共有できます。

本システムの Skills + Commands とは **補完関係** にあり、次のように使い分けることを推奨します。

| ツール | 役割 | 配置 |
|-------|------|------|
| **AGENTS.md** | プロジェクト全体のベース指示（スタイル、ポリシー、命名規則） | リポジトリルート / 各サブディレクトリ |
| **Skills (`.agents/skills/`)** | ドメイン知識 + 自動化（scripts, references） | プロジェクトルート配下の `.agents/skills/` |
| **Commands (`.cursor/commands/`)** | ユーザー起点のワークフロー（`/record-decision` など） | `.cursor/commands/` |
| **`.cursor/rules/*.mdc`** | 条件付き適用（globs, alwaysApply）の細かい制御 | `.cursor/rules/` |

## セットアップ

### 手動配置

本リポジトリの `templates/AGENTS.md.template` をプロジェクトルートにコピーして、プロジェクトに合わせて編集します。

```bash
cp templates/AGENTS.md.template /path/to/your-project/AGENTS.md
```

### init.sh から追加

`--with-agents-md` オプション付きで init を実行すると、スキル・コマンドと同時に `AGENTS.md` テンプレートも配置されます。

```bash
bash templates/.agents/skills/project-setup/scripts/init.sh /path/to/your-project --with-agents-md
```

## ネストされた AGENTS.md

サブディレクトリに AGENTS.md を配置すると、**そのディレクトリ配下のファイルを扱う際にのみ自動適用**されます。親ディレクトリの指示とマージされ、より具体的な指示が優先されます。

```
project/
  AGENTS.md              # グローバルな指示
  frontend/
    AGENTS.md            # フロントエンド固有の指示
    components/
      AGENTS.md          # コンポーネント固有の指示
  backend/
    AGENTS.md            # バックエンド固有の指示
```

サブディレクトリ用のサンプルは `templates/AGENTS.md.nested-example.md` を参照してください。

## 本システムと組み合わせた推奨構成

```
project/
├── AGENTS.md                    # 全体のポリシー（テンプレートから作成）
├── .agents/
│   ├── skills/                  # 7 スキル（本システム提供）
│   └── debug-sessions/          # デバッグ記録
├── .cursor/
│   ├── commands/                # 7 コマンド（本システム提供）
│   └── rules/                   # 任意: 条件付きの追加ルール
├── frontend/
│   └── AGENTS.md                # UI 固有のルール（任意）
└── backend/
    └── AGENTS.md                # API 固有のルール（任意）
```

## ベストプラクティス

### DO

- AGENTS.md はプロジェクト全員が読める分量（概ね 200 行以内）に収める
- コードの複製ではなく、ルール・ポリシーに絞る
- サブディレクトリ固有の事情はネスト AGENTS.md に分離する
- チーム標準規約は `.agents/skills/team-standards/SKILL.md` と住み分けを意識する

### DON'T

- 巨大なスタイルガイドを丸写ししない（linter / formatter で強制すべき）
- 他のルールファイルと重複する内容を書かない
- 頻繁に変わる情報は書かない（メンテナンスコスト増）

## 関連ドキュメント

- [Cursor Rules 公式ドキュメント](https://cursor.com/ja/docs/rules)
- [スキルガイド](../templates/skills-guide.md)
- [コマンドガイド](../templates/commands-guide.md)
