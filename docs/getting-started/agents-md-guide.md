# AGENTS.md 運用ガイド

[Cursor Rules](https://cursor.com/ja/docs/rules) でサポートされる `AGENTS.md` は、プロジェクトルート（および任意のサブディレクトリ）に配置する軽量な Markdown ファイルです。フロントマターを持たないシンプル形式なので、`.cursor/rules/*.mdc` より保守しやすく、チームで共通の指示を素早く共有できます。

本システムのスキルとは **補完関係** にあり、次のように使い分けることを推奨します。

| ツール | 役割 | 配置 |
|-------|------|------|
| **AGENTS.md** | プロジェクト全体のベース指示（スタイル、ポリシー、命名規則） | リポジトリルート / 各サブディレクトリ |
| **ドメインスキル** | ドメイン知識 + 自動化。エージェントが文脈から自動選択する | `.agents/skills/` |
| **アクションスキル** | ユーザー起点のワークフロー（`/record-decision` など） | `.agents/skills/`（`disable-model-invocation: true`） |
| **subagent** | 大きな走査の切り出し（`knowledge-curator`） | `.cursor/agents/` |
| **hooks** | 会話開始時の索引注入、編集ログ | `.cursor/hooks/` と `.cursor/hooks.json` |
| **`.cursor/rules/*.mdc`** | 条件付き適用（globs, alwaysApply）の細かい制御 | `.cursor/rules/` |

AGENTS.md は常に読み込まれます。分量が増えるほど毎リクエストのトークンが増えるため、条件付きで十分な内容はスキルの `description` と `paths` に寄せるのが基本方針です。

## セットアップ

### 手動配置

本リポジトリの `templates/AGENTS.md.template` をプロジェクトルートにコピーして、プロジェクトに合わせて編集します。

```bash
cp templates/AGENTS.md.template /path/to/your-project/AGENTS.md
```

### init.sh から追加

`--with-agents-md` オプション付きで init を実行すると、スキル・subagent・hooks と同時に `AGENTS.md` テンプレートも配置されます。既存の `AGENTS.md` がある場合は上書きしません。

```bash
bash skills/project-setup/scripts/init.sh /path/to/your-project --with-agents-md
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
│   ├── skills/                  # スキル 13 種（本システム提供）
│   └── debug-sessions/          # デバッグ記録
├── .cursor/
│   ├── agents/                  # subagent（knowledge-curator）
│   ├── hooks/                   # hook スクリプト
│   ├── hooks.json               # hook 設定
│   └── rules/                   # 任意: 条件付きの追加ルール
├── frontend/
│   └── AGENTS.md                # UI 固有のルール（任意）
└── backend/
    └── AGENTS.md                # API 固有のルール（任意）
```

スキルは `.agents/skills/` に置くため、Cursor だけでなく Claude Code や Codex からも同じものが読まれます。`.cursor/` 配下に入るのは Cursor 固有の拡張である subagent と hooks だけです。

## ベストプラクティス

### DO

- AGENTS.md はプロジェクト全員が読める分量（概ね 200 行以内）に収める
- コードの複製ではなく、ルール・ポリシーに絞る
- サブディレクトリ固有の事情はネスト AGENTS.md に分離する
- チーム標準規約は `.agents/skills/team-standards/SKILL.md` と住み分けを意識する。あちらは `paths` でソースコードを扱うときだけ読み込まれるので、コーディング規約の本体はスキル側に置くほうが軽く済む
- 記録の残し方を徹底したい場合は、AGENTS.md に「技術判断をしたら `/record-decision` を使う」のような一文だけ置き、手順自体はアクションスキルに任せる

### DON'T

- 巨大なスタイルガイドを丸写ししない（linter / formatter で強制すべき）
- 他のルールファイルと重複する内容を書かない
- スキルの手順を AGENTS.md に転記しない（二重管理になり、必ず drift する）
- 頻繁に変わる情報は書かない（メンテナンスコスト増）

## 関連ドキュメント

- [Cursor Rules 公式ドキュメント](https://cursor.com/ja/docs/rules)
- [スキルガイド](../templates/skills-guide.md)
- [アクションスキルガイド](../templates/action-skills-guide.md)
- [カスタムスキル作成ガイド](../advanced/custom-skills.md)
