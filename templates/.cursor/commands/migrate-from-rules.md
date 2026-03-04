# v2.x（.cursor/rules）からの移行

v2.x の `.cursor/rules` 形式から v4.0.0 の Agent Skills + Commands 形式への移行を対話形式で支援します。

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
まだの場合は、ユーザーにコピー方法を案内してください（v4 は migrate-from-rules.sh または init.sh の利用を推奨）:

```bash
# Mac/Linux（v4: .claude/skills に配置）
cp -r path/to/templates/.claude/skills .claude/skills
cp -r path/to/templates/.cursor/commands .cursor/commands
mkdir -p .claude/debug-sessions
find .claude/skills -name "*.sh" -exec chmod +x {} \;
```

### Step 4: データの転記

旧データファイルにユーザーが記録した内容を、対応する新しい references/ ファイルに転記してください。

対応表（v4: .claude/skills に配置）:
| 旧ファイル | 新ファイル |
|-----------|-----------|
| `.cursor/knowledge.md` | `.claude/skills/knowledge-management/references/KNOWLEDGE_TEMPLATE.md` |
| `.cursor/patterns.md` | `.claude/skills/pattern-library/references/PATTERNS_TEMPLATE.md` |
| `.cursor/context.md` | `.claude/skills/project-context/references/CONTEXT_TEMPLATE.md` |
| `.cursor/debug-log.md` | `.claude/skills/debug-workflow/references/DEBUG_TEMPLATE.md` |
| `.cursor/improvements.md` | `.claude/skills/improvement-tracking/references/IMPROVEMENTS_TEMPLATE.md` |

転記の方針:
1. 旧ファイルの「ファイル概要」「使用方法」等のテンプレート説明部分は不要（新テンプレートに置き換え済み）
2. **ユーザーが実際に記録したデータのみ**を転記する
3. 新テンプレートの該当セクションに内容を配置する
4. 転記した内容をユーザーに確認してもらう

### Step 5: カスタムルールの移行

旧 `.cursor/rules/` にユーザーがカスタマイズした内容がある場合:

1. **team-standards.mdc のカスタマイズ**
   → `.claude/skills/team-standards/SKILL.md` の該当セクションに反映

2. **project-context.mdc のカスタマイズ**
   → `.claude/skills/project-context/SKILL.md` に反映

3. **独自ルール**
   → 新しいスキルとして `.claude/skills/` に作成を提案

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
bash .claude/skills/project-setup/scripts/validate.sh
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
