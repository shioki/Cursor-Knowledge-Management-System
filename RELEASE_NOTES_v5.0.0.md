# Release Notes — v5.0.0

**Release Date**: 2026-04-18
**Codename**: Knowledge Management Plugin

## 概要

v5.0.0 は、Cursor 3.x の新機能（Plugins / `.agents/skills/` 公式ディレクトリ / AGENTS.md）、Microsoft APM、GitHub CLI の `gh skill` に対応したメジャーリリースです。本リポジトリを **「配布可能な Cursor Plugin」** に格上げし、4 つの配布経路（手動 init / Cursor Marketplace / gh skill / APM）でインストール可能になりました。

## ハイライト

### 1. Cursor Plugin 化

- [.cursor-plugin/plugin.json](.cursor-plugin/plugin.json) を追加し、Cursor Marketplace に提出可能な構成に
- ローカルテスト手順とマーケットプレイス提出手順を新規ドキュメントにまとめました

### 2. `.agents/skills/` 正規化

- Cursor 3.x / Claude Code / Codex 公式サポートの `.agents/skills/` を正規ディレクトリに昇格
- `templates/.claude/skills/` → `templates/.agents/skills/` に移動
- `.claude/skills/` と `.cursor/skills/` は後方互換として引き続き検出（`_skill-base.sh` の優先順: `.agents` > `.claude` > `.cursor`）

### 3. gh skill 対応

- 全 7 つの SKILL.md に `license: MIT` と `metadata.tags` を追加
- 以下のように個別スキルを GitHub CLI 経由でインストール可能:
  ```bash
  gh skill install shioki/Cursor-Knowledge-Management-System knowledge-management --agent cursor --pin v5.0.0
  ```
- `npm run skill:publish` で `gh skill publish` を実行するラッパーを追加

### 4. Microsoft APM 対応

- [apm.yml](apm.yml) を追加
- 利用側プロジェクトの `apm.yml` から、パッケージ全体または個別スキルを依存宣言可能:
  ```yaml
  dependencies:
    apm:
      - shioki/Cursor-Knowledge-Management-System#v5.0.0
  ```

### 5. AGENTS.md テンプレート

- ルート用 (`templates/AGENTS.md.template`) と、ネスト用サンプル (`templates/AGENTS.md.nested-example.md`) を同梱
- `init.sh --with-agents-md` で同時配置可能

### 6. Immutable release 対応

- `scripts/release.sh` を刷新。バージョン整合性チェック（plugin.json / apm.yml）、`docs:check` 実行、`gh skill publish` 連携、immutable release 有効化のアナウンスを追加
- `--dry-run` / `--skip-skill-publish` フラグを新設

## 破壊的変更

| 項目 | 以前 (v4.x) | 今回 (v5.0.0) |
|-----|-----------|--------------|
| 正規スキルディレクトリ | `templates/.claude/skills/` | `templates/.agents/skills/` |
| init デフォルト出力 | `<target>/.claude/skills/` | `<target>/.agents/skills/` |
| デバッグセッション既定 | `.claude/debug-sessions/` | `.agents/debug-sessions/`（`.claude` / `.cursor` もフォールバック検出） |
| `templates/.cursor/skills/` | v4 互換フォルダ | **非推奨** (`DEPRECATED.md` 同梱) |
| `compatibility` フィールド | `Cursor, Claude Code` | `Cursor 3.x, Claude Code, Codex` |

## 新しい/更新されたファイル

### 新規
- `.cursor-plugin/plugin.json`
- `apm.yml`
- `templates/AGENTS.md.template`
- `templates/AGENTS.md.nested-example.md`
- `templates/.cursor/skills/DEPRECATED.md`
- `scripts/check-plugin-manifest.mjs`
- `docs/advanced/plugin-development.md`
- `docs/reference/marketplace-submission.md`
- `docs/reference/gh-skill-integration.md`
- `docs/reference/apm-integration.md`
- `docs/getting-started/agents-md-guide.md`
- `RELEASE_NOTES_v5.0.0.md`

### 移動/変更
- `templates/.claude/skills/` → `templates/.agents/skills/`（すべての SKILL.md / scripts / references を含む）
- `templates/.agents/skills/project-setup/scripts/init.sh` — `--legacy-claude` / `--with-agents-md` フラグ追加
- `templates/.agents/skills/project-setup/scripts/init.ps1` — 同上の PowerShell 版
- `templates/.agents/skills/project-setup/scripts/validate.sh` — `.agents/skills` 優先、`license` フィールドチェック
- `templates/.agents/skills/project-setup/scripts/_skill-base.sh` — 検出順の刷新
- `templates/.agents/skills/project-setup/scripts/migrate-from-rules.sh` — v5 仕様、`--legacy-claude` / `--cursor-only` 追加
- `templates/.cursor/commands/migrate-from-rules.md` — `/migrate-to-skills` との棲み分け追記
- `scripts/check-skill-structure.mjs` — 走査対象と `license` / `metadata` チェック
- `scripts/release.sh` — immutable release / `gh skill publish` 連携
- `package.json` — `plugin:check`, `skill:publish` スクリプト追加
- `README.md` / `CHANGELOG.md` — 配布経路 4 種を明文化

## 移行ガイド

### v4.x → v5.0.0

プロジェクトごとの既存スキル配置を `.agents/skills/` に移行するには、以下のいずれか:

#### 方法 1: `init.sh` 自動移行（推奨）

```bash
cd /path/to/Cursor-Knowledge-Management-System
bash templates/.agents/skills/project-setup/scripts/init.sh /path/to/your-project
```

`.claude/skills/` が検出されると、以下の対話プロンプトが表示されます:

```
検出: /path/to/your-project/.claude/skills が存在します（v4.x 配置）
v5.0.0 のデフォルト配置は .agents/skills です。
  [m] .claude/skills を .agents/skills に移動してから上書き
  [k] .claude/skills を維持し、.agents/skills にも新規配置（両方読み込まれます）
  [c] キャンセル
選択 (m/k/c) [m]:
```

`m` を選ぶと自動で `mv` されます。`k` を選ぶと `.agents/skills` に新規配置され、既存の `.claude/skills` と併存します。

#### 方法 2: 手動

```bash
cd /path/to/your-project
mv .claude/skills .agents/skills
[ -d .claude/debug-sessions ] && mv .claude/debug-sessions .agents/debug-sessions
rmdir .claude 2>/dev/null || true
```

#### 方法 3: v4 互換維持

```bash
bash templates/.agents/skills/project-setup/scripts/init.sh /path/to/your-project --legacy-claude
```

### v3.x / v2.x → v5.0.0

- v2.x（`.cursor/rules`）からの移行は `/migrate-from-rules` コマンド or `templates/.agents/skills/project-setup/scripts/migrate-from-rules.sh` を使用
- v3.x（`.cursor/skills`）は `--cursor-only` モードで同等に運用可能。`.agents/skills` 配置に切り替える場合は方法 2 と同様の `mv` を実施

## スコープ外

以下は v5.0.0 では対応しませんでした:

- セルフホスト型クラウドエージェント対応（本システムは静的スキル提供のため対象外）
- Bugbot 学習ルール連携（別プロダクト領域）
- Canvas / Design Mode / 音声入力 / タイルレイアウトの機能実装（IDE 機能であり本テンプレートに影響なし）
- Team Marketplace のテナント申請（リポジトリ側でなく利用者側の作業）

## 既知の制限

- Cursor Marketplace 提出にあたっては、手動セキュリティレビューが必要です。提出コード自体は準備済みですが、審査申請は別タスクとなります（[docs/reference/marketplace-submission.md](docs/reference/marketplace-submission.md) 参照）
- APM / gh skill はまだ新しいツールであり、CI 統合は今後のアップデートで段階的に強化します
- `.cursor/skills/` の SKILL.md は内容が `.agents/skills/` と完全同期されていません（非推奨フォルダのため）。正規ソースは常に `.agents/skills/` を参照してください

## 貢献者への感謝

v5.0.0 の方向性にフィードバックをくださった利用者の皆さまに感謝します。

---

**変更の完全なリスト**: [CHANGELOG.md](CHANGELOG.md)
**前回リリース**: [RELEASE_NOTES_v4.0.0.md](RELEASE_NOTES_v4.0.0.md)
