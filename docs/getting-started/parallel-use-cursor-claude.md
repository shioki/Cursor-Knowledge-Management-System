# Cursor + Claude Code 並行利用ガイド

Cursor IDE と Claude Code（ターミナル CLI）、および Codex を同一プロジェクトで並行利用するためのガイドです。

## 想定ユースケース

- **Cursor**: IDE でコード編集、チャット、Agent を利用
- **Claude Code**: 同じプロジェクトのターミナルで `claude` コマンドを実行
- **共有**: スキル、技術判断記録、デバッグセッション、パターンライブラリを両ツールで参照・更新

## セットアップ

既定では `.agents/skills/` にスキルを配置します。これは Cursor と Codex が標準で探索するディレクトリですが、**Claude Code は `.agents/skills/` を標準では探索しません**（探索先は `.claude/skills/` のみ）。そのため `init.sh` は `.claude/skills` を `.agents/skills` へのシンボリックリンクとして自動作成し、複製せずに橋渡しします。

```bash
bash path/to/Cursor-Knowledge-Management-System/skills/project-setup/scripts/init.sh /path/to/your-project
```

作成されるもの:

```text
プロジェクトルート/
├── .agents/
│   ├── skills/                 # スキル 13 種（唯一の実体）
│   │   ├── knowledge-management/
│   │   ├── record-decision/
│   │   └── ...
│   └── debug-sessions/         # デバッグセッション記録
├── .claude/
│   ├── skills/                 # .agents/skills へのシンボリックリンク（Claude Code 用）
│   ├── hooks/                  # 記録支援スクリプト（Claude Code 用）
│   └── settings.json
└── .cursor/
    ├── agents/                 # subagent（Cursor のみ）
    ├── hooks/                  # 記録支援スクリプト（Cursor のみ）
    └── hooks.json
```

`--with-agents-md` を付けた場合は、プロジェクトルートに `AGENTS.md` と、その `@AGENTS.md` を import するだけの `CLAUDE.md` も作成されます。Claude Code は AGENTS.md も自動では読まないため、この import が無いと恒久指示が届きません。

## v6 で共有できる範囲が広がった

v5 まで、`/record-decision` などの記録ワークフローは `.cursor/commands/` に置かれた Cursor 専用コマンドでした。Claude Code から同じ操作をするには、スキル本文を読んで手作業でたどる必要がありました。

v6 ではこれらをアクションスキルに統合したため、`.agents/skills/` に置かれ、Cursor・Codex からは直接、Claude Code からは `.claude/skills` の橋渡し経由で同じように呼び出せます。

| 機能 | v5 | v6 |
|------|----|----|
| ドメインスキル 7 種 | 共有 | 共有（Claude Code は橋渡し経由） |
| 記録ワークフロー 6 種 | Cursor のみ | 共有（Claude Code は橋渡し経由） |
| subagent | なし | Cursor のみ |
| hooks | なし | 両方（スキーマは別、`hooks/` と `hooks/claude-code/`） |

subagent は Cursor 固有の仕組みなので共有できません。無くてもスキルは動作するので、Claude Code から `/review-knowledge` を使った場合はサブエージェントに委譲せずスキル自身が走査します。hooks は v6.1 で Claude Code 向けにも用意しましたが、入出力のスキーマが異なるため別スクリプトです（[hooks ガイド](../advanced/hooks-guide.md)）。

## スキルの呼び出し

| ツール | 呼び出し方 |
|--------|-----------|
| Cursor | エージェントが文脈に応じて自動適用。アクションスキルは `/` で選択 |
| Claude Code | `.claude/skills` の橋渡しが作成されていれば自動適用。明示する場合は `/skill-name` |
| Codex | 自動適用 |

## 推奨ワークフロー

1. **IDE での開発**: Cursor でコード編集し、`/record-decision` で技術判断を記録
2. **ターミナルでの調査**: Claude Code で `claude このエラーの原因を調べて` と実行。`debug-workflow` が自動適用され、過去のセッションを参照
3. **記録の共有**: どちらで記録しても `.agents/` 配下に保存され、両方から参照できる

知識層が 1 概念 1 ファイルになったため、Cursor と Claude Code で同時に別々の記録を追加してもコンフリクトしません。競合しうるのは索引 `README.md` の 1 行だけです。

## タスクの引き継ぎ

同じリポジトリを開いたまま、**切り出しは Claude Code、実装は Cursor** と分ける使い方があります。スキルと記録は `.agents/` で共有できますが、会話の文脈はツールをまたがないため、依頼は要約ではなく引き継ぎ文にします。

含めるもの:

| 節 | 書くこと |
|----|----------|
| 背景 | 何が壊れるか |
| 再現手順 | コピーして実行できるコマンド |
| 対象ファイル | パス（行や関数名があるとよい） |
| 修正方針 | 採用する手段、依存を増やさない制約、意図的にやらないこと |
| テスト観点 | 手動確認と、CI に足すならその内容 |
| 付随課題 | 本筋と分ける。必須にしない |

実装側は方針と矛盾しない二次障害（例: 同じ入力でファイル名が壊れる）を直して構いません。完了したら、変更ファイル・検証結果・未実施の付随課題をコードブロックで返すと、切り出し側の会話を続けられます。

チャットは媒体であり、正典ではありません。残す知見は `/record-decision` やパターン・改善記録へ移してください。

Claude Code 自体の導入（インストール、最初のひと仕事、`CLAUDE.md`）は [Claude Code入門](https://zenn.dev/hampen2929/articles/20260814-claude-code-getting-started) を参照しました。プロジェクト共通の恒久指示は CKMS では `AGENTS.md` と `.agents/skills/` に置くので、`CLAUDE.md` と役割が重なる内容はここに集約してください。

## 特定のツールだけで使う場合

Claude Code を導入していない場合も既定のままで構いませんが、明示的に配置先を変えることもできます。

```bash
# .claude/skills に配置（v4.x 互換）
bash path/to/.../init.sh /path/to/your-project --legacy-claude

# .cursor/skills に配置（Cursor のみ）
bash path/to/.../init.sh /path/to/your-project --cursor-only
```

`--cursor-only` を選ぶと Claude Code と Codex からは読み込まれません。あとから共有したくなった場合、`.cursor/skills` を `.agents/skills` に移動すれば済みます。

## 参考リンク

- [Claude Code入門 — インストールから最初のひと仕事まで](https://zenn.dev/hampen2929/articles/20260814-claude-code-getting-started)
- [Agent Skills 標準仕様](https://agentskills.io)
- [Cursor エージェントスキル](https://cursor.com/ja/docs/context/skills)
