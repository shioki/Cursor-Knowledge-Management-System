# project-setup: プロジェクトに知識管理システムを初期セットアップするスクリプト（Windows PowerShell）
#
# Usage: .\init.ps1 -TargetPath "C:\path\to\target-project"
#    または: .\init.ps1 -TargetPath "C:\path\to\target-project" -CursorOnly
#
# 引数:
#   TargetPath - ターゲットプロジェクトのパス（必須）
#   CursorOnly - Cursor 専用モード（.cursor/skills に配置。未指定時は .claude/skills に配置して共有）

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$TargetPath,
    [Parameter(Mandatory = $false)]
    [switch]$CursorOnly
)

$ErrorActionPreference = "Stop"

# このスクリプトの場所を基準にテンプレートルートを特定
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplatesClaudeDir = Resolve-Path (Join-Path $ScriptDir "..\..\..")
$TemplatesRoot = Split-Path -Parent $TemplatesClaudeDir
$TemplatesCursorDir = Join-Path $TemplatesRoot ".cursor"

if (-not (Test-Path -Path $TargetPath -PathType Container)) {
    Write-Error "エラー: ディレクトリが見つかりません: $TargetPath"
    exit 1
}

$TargetPath = Resolve-Path $TargetPath

Write-Host "=== Cursor Knowledge Management System セットアップ (v4.0.0) ==="
Write-Host "ターゲット: $TargetPath"
if ($CursorOnly) {
    Write-Host "モード: Cursor 専用 (.cursor/)"
    $SkillsDest = Join-Path $TargetPath ".cursor\skills"
    $SessionsDest = Join-Path $TargetPath ".cursor\debug-sessions"
    $ValidatePath = ".cursor\skills\project-setup\scripts\validate.sh"
} else {
    Write-Host "モード: 共有 (.claude/)"
    $SkillsDest = Join-Path $TargetPath ".claude\skills"
    $SessionsDest = Join-Path $TargetPath ".claude\debug-sessions"
    $ValidatePath = ".claude\skills\project-setup\scripts\validate.sh"
}
Write-Host ""

# skills/ のコピー（テンプレートは .claude/skills から）
$SkillsDestParent = Split-Path -Parent $SkillsDest
if (-not (Test-Path $SkillsDestParent)) {
    New-Item -ItemType Directory -Path $SkillsDestParent -Force | Out-Null
}
Copy-Item -Path (Join-Path $TemplatesClaudeDir "skills") -Destination $SkillsDest -Recurse -Force
Write-Host "skills/ をコピーしました"

# debug-sessions/ の作成
if (-not (Test-Path $SessionsDest)) {
    New-Item -ItemType Directory -Path $SessionsDest -Force | Out-Null
    New-Item -ItemType File -Path (Join-Path $SessionsDest ".gitkeep") -Force | Out-Null
    Write-Host "debug-sessions/ を作成しました"
}

# commands/ のコピー（Cursor 専用、両モード共通）
$CursorDir = Join-Path $TargetPath ".cursor"
if (-not (Test-Path $CursorDir)) {
    New-Item -ItemType Directory -Path $CursorDir -Force | Out-Null
}
Copy-Item -Path (Join-Path $TemplatesCursorDir "commands") -Destination (Join-Path $CursorDir "commands") -Recurse -Force
Write-Host "commands/ をコピーしました"

# .cursorignore のコピー
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
Write-Host "構造検証: Git Bash で bash $ValidatePath を実行"
if (-not $CursorOnly) {
    Write-Host ""
    Write-Host "（Cursor と Claude Code の両方でスキルを利用できます）"
}
