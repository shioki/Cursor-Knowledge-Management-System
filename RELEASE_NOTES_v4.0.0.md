# Cursor Knowledge Management System v4.0.0

**リリース日**: 2026-03-05

## ハイライト

v4.0.0 では、**Cursor IDE と Claude Code（ターミナル CLI）の並行利用**をサポートする大幅なアップグレードを行いました。

### 主な変更

- **共有スキル配置**: `.claude/skills/` をデフォルトとし、Cursor と Claude Code の両方で同一スキルを参照可能
- **Cursor 専用モード**: `init --cursor-only` で従来どおり `.cursor/skills` に配置可能
- **パス検出**: 既存の `.cursor/skills` があれば自動で検出し、移行は任意
- **デバッグセッション共有**: `.claude/debug-sessions/` で両ツールから記録を共有

### 新規ドキュメント

- [Cursor + Claude Code 並行利用ガイド](docs/getting-started/parallel-use-cursor-claude.md)
- [v3.x からの移行ガイド](docs/getting-started/migration-from-v3.md)

### クイックスタート（v4）

```bash
# 共有モード（Cursor と Claude Code）
bash templates/.claude/skills/project-setup/scripts/init.sh /path/to/your-project

# Cursor のみ
bash templates/.claude/skills/project-setup/scripts/init.sh /path/to/your-project --cursor-only
```

### 互換性

- **v3.x ユーザー**: パス検出により `.cursor/skills` のまま継続利用可能。移行は任意
- **新規ユーザー**: init デフォルトで `.claude/skills` に配置

詳細は [CHANGELOG.md](CHANGELOG.md) を参照してください。
