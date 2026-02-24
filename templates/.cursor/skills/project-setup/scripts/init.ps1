# project-setup: プロジェクトに知識管理システムを初期セットアップするスクリプト（Windows PowerShell）
#
# Usage: .\init.ps1 -TargetPath "C:\path\to\target-project"
#    または: .\init.ps1 "C:\path\to\target-project"
#
# 引数:
#   TargetPath - ターゲットプロジェクトのパス（必須）

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$TargetPath
)

$ErrorActionPreference = "Stop"

# このスクリプトの場所を基準にテンプレートルートを特定
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplatesCursorDir = Resolve-Path (Join-Path $ScriptDir "..\..\..")

if (-not (Test-Path -Path $TargetPath -PathType Container)) {
    Write-Error "エラー: ディレクトリが見つかりません: $TargetPath"
    exit 1
}

$TargetPath = Resolve-Path $TargetPath

Write-Host "=== Cursor Knowledge Management System セットアップ ==="
Write-Host "ターゲット: $TargetPath"
Write-Host ""

$CursorDir = Join-Path $TargetPath ".cursor"
if (-not (Test-Path $CursorDir)) {
    New-Item -ItemType Directory -Path $CursorDir -Force | Out-Null
}

# skills/ のコピー
Copy-Item -Path (Join-Path $TemplatesCursorDir "skills") -Destination (Join-Path $CursorDir "skills") -Recurse -Force
Write-Host "skills/ をコピーしました"

# commands/ のコピー
Copy-Item -Path (Join-Path $TemplatesCursorDir "commands") -Destination (Join-Path $CursorDir "commands") -Recurse -Force
Write-Host "commands/ をコピーしました"

# .cursorignore のコピー（テンプレートルートの 1 つ上 = templates の親）
$TemplatesRoot = Split-Path -Parent $TemplatesCursorDir
$CursorignoreSrc = Join-Path $TemplatesRoot ".cursorignore"
if (Test-Path $CursorignoreSrc) {
    Copy-Item -Path $CursorignoreSrc -Destination (Join-Path $TargetPath ".cursorignore") -Force
    Write-Host ".cursorignore をコピーしました"
}

Write-Host ""
Write-Host "=== セットアップ完了 ==="
Write-Host ""
Write-Host "次のステップ:"
Write-Host "  1. /update-context コマンドでプロジェクト基本情報を記入"
Write-Host "  2. /record-decision コマンドで最初の技術判断を記録"
Write-Host "  3. team-standards スキルをプロジェクトの規約に更新"
Write-Host ""
Write-Host "構造検証: Git Bash で bash .cursor/skills/project-setup/scripts/validate.sh を実行"
