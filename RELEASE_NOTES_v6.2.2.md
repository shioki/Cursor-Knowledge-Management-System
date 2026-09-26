# Release Notes — v6.2.2

**リリース日**: 2026-09-26
**Codename**: Quiet

v6.2.2 は、導入済みプロジェクトで `init.sh` / `init.ps1` を再実行したときの案内を直す修正版です。v6.2.0 以降で再実行が勧められる手順になったため、再実行のたびに出る不要な案内が目立つようになっていました。

## Fixed

- **登録済みの hooks まで追記を促していた**: `.cursor/hooks.json` と `.claude/settings.json` が既にあると、中身を見ずに「次のエントリを手動で追記してください」「手動で統合してください」と表示していました。案内どおりに追記すると、hooks が二重に登録され、同じフックが 2 回走ります。CKMS の hooks が登録済みならその旨だけを表示し、足りないものだけを案内します
- **`init.ps1` が失敗時に `skills/` の中へ入れ替え前のスキルを残していた**: `skills\<名前>.replacing.<GUID>` が残ると、同じ `name` のスキルとしてエージェントに読み込まれることがありました。`init.sh` と同じく `skills/` の外（`.ckms-replaced-*`）へ移します
- **再実行でも初回向けの「次のステップ」を表示していた**: 更新したときは、記録とプロジェクト固有のスキルを残したことと、退避先の場所を表示します

## Added

- **`validate.sh` が再実行の残骸を検出する**: 失敗・中断で残った `.ckms-incoming*`・`.ckms-replaced*`・`skills/*.replacing.*` を警告し、`skills.backup-*` の件数を表示します。`templates/.cursorignore` とチーム導入ガイドの `.gitignore` の例にも、一時ディレクトリの除外を足しました
- **project-setup スキルに更新手順**: エージェントが「CKMS を更新して」と頼まれたときにこのスキルを読むよう、`SKILL.md` に「導入済みプロジェクトの更新」を加え、`description` にも更新時に使う旨を入れました

## すでに hooks が二重になっている場合

以前の案内に従って追記していた場合は、`.cursor/hooks.json` と `.claude/settings.json` に同じコマンドが 2 回書かれていないか確認し、重複を 1 つにしてください。

## 関連

- [CHANGELOG.md](CHANGELOG.md)
- [導入済みプロジェクトの更新](docs/getting-started/updating.md)
- 前リリース: [v6.2.1](RELEASE_NOTES_v6.2.1.md)
