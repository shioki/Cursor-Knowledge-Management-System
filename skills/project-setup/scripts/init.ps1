# project-setup: プロジェクトに知識管理システムを初期セットアップするスクリプト（Windows PowerShell, v6.0.0）
#
# Usage:
#   .\init.ps1 -TargetPath "C:\path\to\target-project"
#   .\init.ps1 -TargetPath "C:\path\to\target-project" -Yes
#   .\init.ps1 -TargetPath "C:\path\to\target-project" -LegacyClaude
#   .\init.ps1 -TargetPath "C:\path\to\target-project" -CursorOnly
#   .\init.ps1 -TargetPath "C:\path\to\target-project" -WithAgentsMd -NoHooks
#
# パラメータ:
#   TargetPath    - ターゲットプロジェクトのパス（必須）
#   Yes           - すべての確認に yes と答える（非対話環境・CI 向け）
#   LegacyClaude  - .claude/skills に配置（v4.x 互換）
#   CursorOnly    - Cursor 専用モード（.cursor/skills に配置）
#   WithAgentsMd  - AGENTS.md テンプレートも配置（既存は保持）
#   NoHooks       - hooks を配置しない
#   NoAgents      - subagent を配置しない
#
# デフォルト: .agents/skills に配置（Cursor / Claude Code / Codex 共用）
#
# 注意: 知識管理スクリプト（*.sh）の実行には Git Bash または WSL が必要です。

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$TargetPath,
    [Parameter(Mandatory = $false)]
    [switch]$Yes,
    [Parameter(Mandatory = $false)]
    [switch]$LegacyClaude,
    [Parameter(Mandatory = $false)]
    [switch]$CursorOnly,
    [Parameter(Mandatory = $false)]
    [switch]$WithAgentsMd,
    [Parameter(Mandatory = $false)]
    [switch]$NoHooks,
    [Parameter(Mandatory = $false)]
    [switch]$NoAgents
)

$ErrorActionPreference = "Stop"

if ($LegacyClaude -and $CursorOnly) {
    Write-Error "エラー: -LegacyClaude と -CursorOnly は同時に指定できません"
    exit 1
}

# 確認プロンプト。-Yes 指定時、または非対話環境では待たない。
function Confirm-Overwrite {
    param([string]$Prompt)

    if ($Yes) { return $true }
    if (-not [Environment]::UserInteractive) {
        Write-Host "  非対話環境のためスキップします（上書きするには -Yes を指定してください）"
        return $false
    }
    $reply = Read-Host "  $Prompt (y/N)"
    return ($reply -match '^[Yy]$')
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceSkills = Resolve-Path (Join-Path $ScriptDir "..\..")
$SourceRoot = Split-Path -Parent $SourceSkills
$SourceHooks = Join-Path $SourceRoot "hooks"
$SourceAgents = Join-Path $SourceRoot "agents"
$SourceTemplates = Join-Path $SourceRoot "templates"

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
    $ModeLabel = "共用 (.agents/)"
}

$SkillsDest = Join-Path $TargetPath "$BaseDir\skills"
$SessionsDest = Join-Path $TargetPath "$BaseDir\debug-sessions"
$ValidatePath = "$BaseDir\skills\project-setup\scripts\validate.sh"

Write-Host "=== Cursor Knowledge Management System セットアップ (v6.0.0) ==="
Write-Host "ターゲット: $TargetPath"
Write-Host "モード:     $ModeLabel"
Write-Host ("hooks:      " + $(if ($NoHooks) { "配置しない" } else { "配置する" }))
Write-Host ("subagent:   " + $(if ($NoAgents) { "配置しない" } else { "配置する" }))
Write-Host ("AGENTS.md:  " + $(if ($WithAgentsMd) { "配置する" } else { "配置しない" }))
Write-Host ""

# skills/
$CopySkills = $true
if (Test-Path $SkillsDest) {
    Write-Host "警告: $SkillsDest は既に存在します"
    if (Confirm-Overwrite "上書きしますか?") {
        Remove-Item -Path $SkillsDest -Recurse -Force
    } else {
        Write-Host "  skills/ のコピーをスキップしました"
        $CopySkills = $false
    }
}
if ($CopySkills) {
    $SkillsDestParent = Split-Path -Parent $SkillsDest
    if (-not (Test-Path $SkillsDestParent)) {
        New-Item -ItemType Directory -Path $SkillsDestParent -Force | Out-Null
    }
    Copy-Item -Path $SourceSkills -Destination $SkillsDest -Recurse -Force
    Write-Host "skills/ をコピーしました"
}

if (-not (Test-Path $SessionsDest)) {
    New-Item -ItemType Directory -Path $SessionsDest -Force | Out-Null
    New-Item -ItemType File -Path (Join-Path $SessionsDest ".gitkeep") -Force | Out-Null
    Write-Host "debug-sessions/ を作成しました"
}

$CursorDir = Join-Path $TargetPath ".cursor"

# agents/（subagent は Cursor が .cursor/agents から読み込む）
if (-not $NoAgents) {
    if (-not (Test-Path $SourceAgents)) {
        Write-Host "情報: 配布元に agents/ が無いためスキップします"
    } else {
        $AgentsDest = Join-Path $CursorDir "agents"
        if (-not (Test-Path $AgentsDest)) {
            New-Item -ItemType Directory -Path $AgentsDest -Force | Out-Null
        }
        Get-ChildItem -Path $SourceAgents -Filter "*.md" | ForEach-Object {
            $dest = Join-Path $AgentsDest $_.Name
            $write = $true
            if (Test-Path $dest) {
                Write-Host "警告: $dest は既に存在します"
                $write = Confirm-Overwrite "上書きしますか?"
            }
            if ($write) {
                Copy-Item -Path $_.FullName -Destination $dest -Force
                Write-Host "subagent を配置しました: $dest"
            }
        }
    }
}

# hooks/
if (-not $NoHooks) {
    if (-not (Test-Path $SourceHooks)) {
        Write-Host "情報: 配布元に hooks/ が無いためスキップします"
    } else {
        $HooksDest = Join-Path $CursorDir "hooks"
        if (-not (Test-Path $HooksDest)) {
            New-Item -ItemType Directory -Path $HooksDest -Force | Out-Null
        }
        Copy-Item -Path (Join-Path $SourceHooks "*.sh") -Destination $HooksDest -Force
        Write-Host "hooks スクリプトを配置しました: $HooksDest"

        $HooksJson = Join-Path $CursorDir "hooks.json"
        if (Test-Path $HooksJson) {
            Write-Host "情報: $HooksJson は既に存在します（上書きしません）"
            Write-Host "      次のエントリを手動で追記してください:"
            Write-Host '        "sessionStart": [{ "command": ".cursor/hooks/inject-knowledge-index.sh" }]'
            Write-Host '        "afterFileEdit": [{ "command": ".cursor/hooks/log-activity.sh" }]'
        } else {
            $HooksConfig = @'
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      {
        "command": ".cursor/hooks/inject-knowledge-index.sh",
        "timeout": 10
      }
    ],
    "afterFileEdit": [
      {
        "command": ".cursor/hooks/log-activity.sh",
        "timeout": 5
      }
    ],
    "stop": [
      {
        "command": ".cursor/hooks/suggest-record.sh",
        "timeout": 10,
        "loop_limit": 1
      }
    ]
  }
}
'@
            Set-Content -Path $HooksJson -Value $HooksConfig -Encoding UTF8
            Write-Host "hooks.json を作成しました: $HooksJson"
        }
        Write-Host "注意: hooks スクリプトの実行には Git Bash または WSL が必要です"
    }
}

# .cursorignore
$CursorignoreSrc = Join-Path $SourceTemplates ".cursorignore"
if (Test-Path $CursorignoreSrc) {
    $CursorignoreDest = Join-Path $TargetPath ".cursorignore"
    $write = $true
    if (Test-Path $CursorignoreDest) {
        Write-Host "警告: $CursorignoreDest は既に存在します"
        $write = Confirm-Overwrite "上書きしますか?"
    }
    if ($write) {
        Copy-Item -Path $CursorignoreSrc -Destination $CursorignoreDest -Force
        Write-Host ".cursorignore をコピーしました"
    } else {
        Write-Host "  .cursorignore のコピーをスキップしました"
    }
}

# AGENTS.md
if ($WithAgentsMd) {
    $AgentsMdSrc = Join-Path $SourceTemplates "AGENTS.md.template"
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
Write-Host "  1. /update-context でプロジェクト基本情報を記入"
Write-Host "  2. /record-decision で最初の技術判断を記録"
Write-Host "  3. team-standards スキルをプロジェクトの規約に更新"
Write-Host ""
Write-Host "構造検証: Git Bash で bash $ValidatePath を実行"
Write-Host ""
if ($CursorOnly) {
    Write-Host "（.cursor/skills は Cursor のみが読み込みます）"
} elseif ($LegacyClaude) {
    Write-Host "（Cursor と Claude Code で .claude/skills を共有利用できます）"
} else {
    Write-Host "（Cursor / Claude Code / Codex で .agents/skills を共有利用できます）"
}
