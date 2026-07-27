# Cursor + Claude Code 並行利用ガイド

Cursor IDE と Claude Code（ターミナル CLI）、および Codex を同一プロジェクトで並行利用するためのガイドです。

## 想定ユースケース

- **Cursor**: IDE でコード編集、チャット、Agent を利用
- **Claude Code**: 同じプロジェクトのターミナルで `claude` コマンドを実行
- **共有**: スキル、技術判断記録、デバッグセッション、パターンライブラリを両ツールで参照・更新

## セットアップ

既定では `.agents/skills/` にスキルを配置します。これは Cursor・Claude Code・Codex が共通で読み込む公式ディレクトリなので、1 か所に置くだけで全ツールから共有されます。

```bash
bash path/to/Cursor-Knowledge-Management-System/skills/project-setup/scripts/init.sh /path/to/your-project
```

作成されるもの:

```text
プロジェクトルート/
├── .agents/
│   ├── skills/                 # スキル 13 種（全エージェント共通）
│   │   ├── knowledge-management/
│   │   ├── record-decision/
│   │   └── ...
│   └── debug-sessions/         # デバッグセッション記録
└── .cursor/
    ├── agents/                 # subagent（Cursor のみ）
    ├── hooks/                  # 記録支援スクリプト（Cursor のみ）
    └── hooks.json
```

## v6 で共有できる範囲が広がった

v5 まで、`/record-decision` などの記録ワークフローは `.cursor/commands/` に置かれた Cursor 専用コマンドでした。Claude Code から同じ操作をするには、スキル本文を読んで手作業でたどる必要がありました。

v6 ではこれらをアクションスキルに統合したため、`.agents/skills/` に置かれ、全エージェントから同じように呼び出せます。

| 機能 | v5 | v6 |
|------|----|----|
| ドメインスキル 7 種 | 共有 | 共有 |
| 記録ワークフロー 6 種 | Cursor のみ | 共有 |
| subagent | なし | Cursor のみ |
| hooks | なし | Cursor のみ |

subagent と hooks は Cursor 固有の仕組みなので共有できません。ただしどちらも補助機能で、無くてもスキルは動作します。Claude Code から `/review-knowledge` を使った場合、サブエージェントに委譲せずスキル自身が走査します。

## スキルの呼び出し

| ツール | 呼び出し方 |
|--------|-----------|
| Cursor | エージェントが文脈に応じて自動適用。アクションスキルは `/` で選択 |
| Claude Code | 自動適用。明示する場合は `/skill-name` |
| Codex | 自動適用 |

## 推奨ワークフロー

1. **IDE での開発**: Cursor でコード編集し、`/record-decision` で技術判断を記録
2. **ターミナルでの調査**: Claude Code で `claude このエラーの原因を調べて` と実行。`debug-workflow` が自動適用され、過去のセッションを参照
3. **記録の共有**: どちらで記録しても `.agents/` 配下に保存され、両方から参照できる

知識層が 1 概念 1 ファイルになったため、Cursor と Claude Code で同時に別々の記録を追加してもコンフリクトしません。競合しうるのは索引 `README.md` の 1 行だけです。

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

- [Agent Skills 標準仕様](https://agentskills.io)
- [Cursor エージェントスキル](https://cursor.com/ja/docs/context/skills)
