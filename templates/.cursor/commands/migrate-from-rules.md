# v2.x（.cursor/rules）から本システムへの移行

v2.x の `.cursor/rules` 形式から v5.0.0 の Agent Skills + Commands 形式（本テンプレート）への移行を対話形式で支援します。

## `/migrate-from-rules` と `/migrate-to-skills` の違い

Cursor 2.4 以降には、組み込みの `/migrate-to-skills` コマンドがあります。両者の棲み分けは以下のとおりです。

| | `/migrate-to-skills`（Cursor 組み込み） | `/migrate-from-rules`（本システム） |
|---|----------------------------------------|---------------------------------------|
| **対象** | 動的ルール（`alwaysApply: false` かつ globs 無指定）、スラッシュコマンド | `.cursor/rules/*.mdc` と `.cursor/{knowledge,patterns,context,debug-log,improvements}.md` |
| **目的** | ルール/コマンドを **汎用スキル化** | **本システムの 7 スキル + 7 コマンド構成** への移行 |
| **データ転記** | なし（ルール → スキル変換のみ） | 旧データファイルを `references/` に取り込み |
| **バックアップ** | なし | `.cursor/backup-v2/` に自動バックアップ |

**使い分けの推奨:**

- 本テンプレートへ移行したい → `/migrate-from-rules`（このコマンド）
- 任意の `.mdc` ルールを一般的なスキルに変換したい → Cursor 組み込みの `/migrate-to-skills`
- 両方併用も可能（まず `/migrate-from-rules` で本システムに移行、残った独自ルールを `/migrate-to-skills` でスキル化）

## 手順

### Step 1: 旧構造の検出

以下のファイル・ディレクトリが存在するか確認してください:

- `.cursor/rules/` ディレクトリ（.mdc ファイル）
- `.cursor/knowledge.md`
- `.cursor/patterns.md`
- `.cursor/context.md`
- `.cursor/debug-log.md`
- `.cursor/improvements.md`

検出結果をユーザーに報告してください:
- 見つかった旧ルールの一覧
- 見つかった旧データファイルの一覧
- 各ファイルにユーザーデータが含まれているか（テンプレートのままか）

### Step 2: バックアップ

移行前に、検出した旧ファイルを `.cursor/backup-v2/` にバックアップしてください:

```
.cursor/backup-v2/
├── rules/          ← .cursor/rules/ のコピー
├── knowledge.md    ← .cursor/knowledge.md のコピー
├── patterns.md     ← .cursor/patterns.md のコピー
├── context.md      ← .cursor/context.md のコピー
├── debug-log.md    ← .cursor/debug-log.md のコピー
└── improvements.md ← .cursor/improvements.md のコピー
```

### Step 3: 新構造の確認

新しい skills/ と commands/ が既にコピーされているか確認してください。
まだの場合は、ユーザーにコピー方法を案内してください（v5 では `.agents/skills/` に配置するのが標準です）:

```bash
# Mac/Linux（v5: .agents/skills に配置）
cp -r path/to/templates/.agents/skills .agents/skills
cp -r path/to/templates/.cursor/commands .cursor/commands
mkdir -p .agents/debug-sessions
find .agents/skills -name "*.sh" -exec chmod +x {} \;
```

もしくは、init.sh / migrate-from-rules.sh の利用を推奨します:

```bash
bash path/to/templates/.agents/skills/project-setup/scripts/migrate-from-rules.sh /path/to/project
```

### Step 4: データの転記

旧データファイルにユーザーが記録した内容を、対応する新しい references/ ファイルに転記してください。

対応表（v5: `.agents/skills` に配置）:
| 旧ファイル | 新ファイル |
|-----------|-----------|
| `.cursor/knowledge.md` | `.agents/skills/knowledge-management/references/KNOWLEDGE_TEMPLATE.md` |
| `.cursor/patterns.md` | `.agents/skills/pattern-library/references/PATTERNS_TEMPLATE.md` |
| `.cursor/context.md` | `.agents/skills/project-context/references/CONTEXT_TEMPLATE.md` |
| `.cursor/debug-log.md` | `.agents/skills/debug-workflow/references/DEBUG_TEMPLATE.md` |
| `.cursor/improvements.md` | `.agents/skills/improvement-tracking/references/IMPROVEMENTS_TEMPLATE.md` |

転記の方針:
1. 旧ファイルの「ファイル概要」「使用方法」等のテンプレート説明部分は不要（新テンプレートに置き換え済み）
2. **ユーザーが実際に記録したデータのみ**を転記する
3. 新テンプレートの該当セクションに内容を配置する
4. 転記した内容をユーザーに確認してもらう

### Step 5: カスタムルールの移行

旧 `.cursor/rules/` にユーザーがカスタマイズした内容がある場合:

1. **team-standards.mdc のカスタマイズ**
   → `.agents/skills/team-standards/SKILL.md` の該当セクションに反映
2. **project-context.mdc のカスタマイズ**
   → `.agents/skills/project-context/SKILL.md` に反映
3. **独自ルール**
   → Cursor 組み込みの `/migrate-to-skills` で汎用スキル化を提案、または `.agents/skills/` に新しいスキルとして追加

各ルールの内容を確認し、適切な移行先を提案してください。

### Step 6: 旧ファイルの削除

すべてのデータ転記が完了したことをユーザーに確認した後、旧ファイルの削除を提案してください:

```bash
rm -rf .cursor/rules/
rm -f .cursor/knowledge.md .cursor/patterns.md .cursor/context.md
rm -f .cursor/debug-log.md .cursor/improvements.md
```

**必ずユーザーの確認を取ってから削除してください。**

### Step 7: 検証と完了

1. 構造の検証:
```bash
bash .agents/skills/project-setup/scripts/validate.sh
```

2. 動作確認の案内:
   - Cursor Settings > Rules でスキルが検出されること
   - チャットで `/` を入力してコマンドが表示されること

3. 移行サマリーを提示:
   - 移行したデータファイルの一覧
   - 移行したカスタムルールの一覧
   - バックアップの場所
   - 次のステップの推奨

## 注意事項

- **削除前に必ずバックアップを確認**してください
- データの転記は**ユーザーの確認を取りながら**進めてください
- テンプレートのままで実データがないファイルは転記不要です
- 移行が途中で中断しても、skills/ と rules/ は共存可能です
- 問題が発生した場合は `.cursor/backup-v2/` から復元できます
- v4.x（`.claude/skills`）からの移行は、`init.sh` デフォルト実行時に自動検出され、`.agents/skills` への移動が提案されます
