# Cursor + Claude Code 並行利用ガイド

Cursor IDE と Claude Code（ターミナル CLI）を同一プロジェクトで並行して利用するためのガイドです。

## 想定ユースケース

- **Cursor**: IDE でコード編集、チャット、Agent を利用
- **Claude Code**: 同じプロジェクトのターミナルで `claude` コマンドを実行
- **共有**: スキル、技術判断記録、デバッグセッション、パターンライブラリを両ツールで参照・更新

## セットアップ

v4.0.0 では、デフォルトで `.claude/skills/` にスキルを配置します。Cursor と Claude Code の両方がこのディレクトリを読むため、同一プロジェクトで即時に共有されます。

```bash
# デフォルト（共有モード）
bash path/to/Cursor-Knowledge-Management-System/templates/.claude/skills/project-setup/scripts/init.sh /path/to/your-project
```

これにより以下が作成されます:

- `.claude/skills/` - 7 つのスキル（両ツールで共有）
- `.claude/debug-sessions/` - デバッグセッション記録
- `.cursor/commands/` - Cursor 専用コマンド

## スキルの呼び出し

| ツール | 呼び出し方法 |
|--------|-------------|
| **Cursor** | チャットで `/` を入力してコマンドを選択。またはエージェントが文脈に応じて自動適用 |
| **Claude Code** | チャットで `/skill-name` と入力（例: `/knowledge-management`） |

## データの共有構造

```
プロジェクトルート/
├── .claude/
│   ├── skills/           # スキル（Cursor / Claude Code 共通）
│   │   ├── knowledge-management/
│   │   ├── pattern-library/
│   │   └── ...
│   └── debug-sessions/   # デバッグセッション記録
└── .cursor/
    └── commands/         # Cursor 専用コマンド（/record-decision 等）
```

## 推奨ワークフロー

1. **IDE での開発**: Cursor でコード編集、`/record-decision` で技術判断を記録
2. **ターミナルでの調査**: Claude Code で `claude このエラーの原因を調べて` と実行。`/debug-workflow` スキルが自動適用され、過去のデバッグセッションを参照
3. **知識の蓄積**: どちらのツールで記録しても `.claude/skills/.../references/` に保存され、両方から参照可能

## Cursor のみで利用する場合

Claude Code を導入していない場合は、`--cursor-only` オプションで従来どおり `.cursor/skills/` に配置できます:

```bash
bash path/to/.../init.sh /path/to/your-project --cursor-only
```

## 参考リンク

- [Agent Skills 標準仕様](https://agentskills.io)
- [Cursor エージェントスキル](https://cursor.com/ja/docs/context/skills)
