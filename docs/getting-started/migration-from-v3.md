# v3.x から v4.0.0 への移行ガイド

v3.x（`.cursor/skills`）で運用中のプロジェクトを v4.0.0（`.claude/skills`）に移行する手順です。

## 移行の必要性

v4.0.0 では以下が変更されています:

- **スキル配置**: `.cursor/skills/` → `.claude/skills/`（デフォルト）
- **デバッグセッション**: `.cursor/debug-sessions/` → `.claude/debug-sessions/`
- **Cursor + Claude Code 共用**: `.claude/` に配置すると両ツールで同一データを参照可能

## 既存プロジェクト（v3.x）について

**パス検出により、v3.x のままでも継続して動作します。** スクリプトは `.claude/skills` と `.cursor/skills` の両方を自動検出するため、移行は任意です。

## 移行オプション

### オプション A: 現状維持（移行しない）

`.cursor/skills` のまま利用を続ける場合、追加の作業は不要です。validate.sh も `.cursor/skills` を検出して検証します。

### オプション B: .claude/ に移行（推奨）

Cursor と Claude Code の両方で利用する場合、または今後の拡張を考える場合は `.claude/` への移行を推奨します。

#### 手順

1. **スキルを .claude にコピー**
```bash
# プロジェクトルートで実行
cp -r .cursor/skills .claude/skills
mkdir -p .claude/debug-sessions
```

2. **デバッグセッションの移動（存在する場合）**
```bash
if [ -d .cursor/debug-sessions ] && [ "$(ls -A .cursor/debug-sessions 2>/dev/null)" ]; then
  cp -r .cursor/debug-sessions/* .claude/debug-sessions/
  echo "デバッグセッションを .claude/debug-sessions にコピーしました"
fi
```

3. **動作確認**
```bash
bash .claude/skills/project-setup/scripts/validate.sh
```

4. **旧 .cursor/skills の削除（任意）**
   - 動作確認後、問題がなければ削除可能
   - `rm -rf .cursor/skills` で削除（バックアップ推奨）

### オプション C: 新規プロジェクトで init を使用

新規プロジェクトの場合は、init を実行するだけで v4 構成になります:

```bash
bash path/to/Cursor-Knowledge-Management-System/templates/.claude/skills/project-setup/scripts/init.sh /path/to/your-project
```

## Cursor のみで利用する場合

Claude Code を導入していない場合は、`--cursor-only` で従来どおり `.cursor/skills` に配置できます:

```bash
bash path/to/.../init.sh /path/to/your-project --cursor-only
```

既存の v3 プロジェクトをそのまま使い続けることも可能です。
