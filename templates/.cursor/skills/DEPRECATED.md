# DEPRECATED: `templates/.cursor/skills/`

v5.0.0 以降、本テンプレートの正規ソースは `templates/.agents/skills/` に移行しました。

`templates/.cursor/skills/` は以下の用途でのみ残置されています:

- `--cursor-only` モードで `.cursor/skills/` に配置したいユーザーの過去互換
- Cursor 3.x 以前の環境で `.cursor/skills/` のみをサポートする場合のフォールバック

## 推奨される移行

新規プロジェクトや既存プロジェクトの移行では、以下をご利用ください:

```bash
# .agents/skills に配置（Cursor 3.x / Claude Code / Codex 共用）
bash templates/.agents/skills/project-setup/scripts/init.sh /path/to/your-project

# .claude/skills に配置（v4.x 互換）
bash templates/.agents/skills/project-setup/scripts/init.sh /path/to/your-project --legacy-claude

# .cursor/skills に配置（Cursor-only モード）
bash templates/.agents/skills/project-setup/scripts/init.sh /path/to/your-project --cursor-only
```

## このディレクトリは将来のメジャーバージョンで削除予定です

`templates/.cursor/skills/` 配下の SKILL.md は、`templates/.agents/skills/` と同期が保たれないことがあります。
常に `templates/.agents/skills/` を正規ソースとして参照してください。

参考:
- [Cursor Skills ドキュメント](https://cursor.com/ja/docs/skills)
- [Agent Skills 標準仕様](https://agentskills.io)
