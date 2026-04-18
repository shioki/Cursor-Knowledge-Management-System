# project-setup: プロジェクトに知識管理システムを初期セットアップするスクリプト（Windows PowerShell, v5.0.0）
#
# Usage:
#   .\init.ps1 -TargetPath "C:\path\to\target-project"
#   .\init.ps1 -TargetPath "C:\path\to\target-project" -LegacyClaude
#   .\init.ps1 -TargetPath "C:\path\to\target-project" -CursorOnly
#   .\init.ps1 -TargetPath "C:\path\to\target-project" -WithAgentsMd
#
# パラメータ:
#   TargetPath    - ターゲットプロジェクトのパス（必須）
#   LegacyClaude  - .claude/skills に配置（v4.x 互換）
#   CursorOnly    - Cursor 専用モード（.cursor/skills に配置）
#   WithAgentsMd  - AGENTS.md テンプレートも同時にコピー
#
# デフォルト: .agents/skills に配置（Cursor 3.x / Claude Code / Codex 共用）

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$TargetPath,
    [Parameter(Mandatory = $false)]
    [switch]$LegacyClaude,
    [Parameter(Mandatory = $false)]
    [switch]$CursorOnly,
    [Parameter(Mandatory = $false)]
    [switch]$WithAgentsMd
)

$ErrorActionPreference = "Stop"

if ($LegacyClaude -and $CursorOnly) {
    Write-Error "エラー: -LegacyClaude と -CursorOnly は同時に指定できません"
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplatesAgentsDir = Resolve-Path (Join-Path $ScriptDir "..\..\..")
$TemplatesRoot = Split-Path -Parent $TemplatesAgentsDir
$TemplatesCursorDir = Join-Path $TemplatesRoot ".cursor"

if (-not (Test-Path -Path $TargetPath -PathType Container)) {
    Write-Error "エラー: ディレクトリが見つかりません: $TargetPath"
    exit 1
}

$TargetPath = Resolve-Path $TargetPath

if ($CursorOnly) {
    $BaseDir = ".cursor"
    $ModeLabel = "Cursor のみ (.cursor/)"
} elseif ($LegacyClaude) {
    $BaseDir = ".claude"
    $ModeLabel = "v4 互換 (.claude/)"
} else {
    $BaseDir = ".agents"
    $ModeLabel = "v5 共用 (.agents/)"
}

$SkillsDest = Join-Path $TargetPath "$BaseDir\skills"
$SessionsDest = Join-Path $TargetPath "$BaseDir\debug-sessions"
$ValidatePath = "$BaseDir\skills\project-setup\scripts\validate.sh"

Write-Host "=== Cursor Knowledge Management System セットアップ (v5.0.0) ==="
Write-Host "ターゲット: $TargetPath"
Write-Host "モード:     $ModeLabel"
if ($WithAgentsMd) {
    Write-Host "AGENTS.md:  含む"
} else {
    Write-Host "AGENTS.md:  含まない"
}
Write-Host ""

$SkillsDestParent = Split-Path -Parent $SkillsDest
if (-not (Test-Path $SkillsDestParent)) {
    New-Item -ItemType Directory -Path $SkillsDestParent -Force | Out-Null
}
Copy-Item -Path (Join-Path $TemplatesAgentsDir "skills") -Destination $SkillsDest -Recurse -Force
Write-Host "skills/ をコピーしました"

if (-not (Test-Path $SessionsDest)) {
    New-Item -ItemType Directory -Path $SessionsDest -Force | Out-Null
    New-Item -ItemType File -Path (Join-Path $SessionsDest ".gitkeep") -Force | Out-Null
    Write-Host "debug-sessions/ を作成しました"
}

$CursorDir = Join-Path $TargetPath ".cursor"
if (-not (Test-Path $CursorDir)) {
    New-Item -ItemType Directory -Path $CursorDir -Force | Out-Null
}
Copy-Item -Path (Join-Path $TemplatesCursorDir "commands") -Destination (Join-Path $CursorDir "commands") -Recurse -Force
Write-Host "commands/ をコピーしました"

$CursorignoreSrc = Join-Path $TemplatesRoot ".cursorignore"
if (Test-Path $CursorignoreSrc) {
    Copy-Item -Path $CursorignoreSrc -Destination (Join-Path $TargetPath ".cursorignore") -Force
    Write-Host ".cursorignore をコピーしました"
}

if ($WithAgentsMd) {
    $AgentsMdSrc = Join-Path $TemplatesRoot "AGENTS.md.template"
    $AgentsMdDest = Join-Path $TargetPath "AGENTS.md"
    if (-not (Test-Path $AgentsMdSrc)) {
        Write-Warning "AGENTS.md.template が見つかりません: $AgentsMdSrc"
    } elseif (Test-Path $AgentsMdDest) {
        Write-Host "情報: $AgentsMdDest は既に存在します（上書きしません）"
    } else {
        Copy-Item -Path $AgentsMdSrc -Destination $AgentsMdDest -Force
        Write-Host "AGENTS.md をコピーしました"
    }
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
    if ($LegacyClaude) {
        Write-Host "（Cursor と Claude Code で .claude/skills を共有利用できます）"
    } else {
        Write-Host "（Cursor 3.x / Claude Code / Codex で .agents/skills を共有利用できます）"
    }
}
