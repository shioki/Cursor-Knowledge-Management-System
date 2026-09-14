# project-setup: プロジェクトに知識管理システムを初期セットアップするスクリプト（Windows PowerShell, v6.1.1）
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
#   NoClaudeBridge - .claude/skills への橋渡し（Claude Code 用）を作らない
#
# デフォルト: .agents/skills に配置。Cursor はこれをそのまま読み、Claude Code は
# .agents/skills を標準では探索しないため、.claude/skills にシンボリックリンク
# （権限が無い環境ではコピー）で橋渡しする。
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
    [switch]$NoAgents,
    [Parameter(Mandatory = $false)]
    [switch]$NoClaudeBridge
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

Write-Host "=== Cursor Knowledge Management System セットアップ (v6.1.1) ==="
Write-Host "ターゲット: $TargetPath"
Write-Host "モード:     $ModeLabel"
Write-Host ("hooks:      " + $(if ($NoHooks) { "配置しない" } else { "配置する" }))
Write-Host ("subagent:   " + $(if ($NoAgents) { "配置しない" } else { "配置する" }))
Write-Host ("AGENTS.md:  " + $(if ($WithAgentsMd) { "配置する（CLAUDE.md も作成）" } else { "配置しない" }))
if (-not $CursorOnly -and -not $LegacyClaude) {
    Write-Host ("Claude Code 橋渡し (.claude/skills): " + $(if ($NoClaudeBridge) { "作成しない" } else { "作成する" }))
}
Write-Host ""

# 既存 .claude/skills の検出と移行提案（v4.x 配置からの移行。デフォルトモードのみ）
if (-not $CursorOnly -and -not $LegacyClaude) {
    $LegacyClaudeSkills = Join-Path $TargetPath ".claude\skills"
    if ((Test-Path $LegacyClaudeSkills) -and -not (Test-Path $SkillsDest)) {
        Write-Host "検出: $LegacyClaudeSkills が存在します（v4.x 配置）"
        Write-Host "v6 のデフォルト配置は .agents/skills です。"
        if (Confirm-Overwrite ".claude/skills を .agents/skills へ移動しますか?") {
            $AgentsDirForMove = Join-Path $TargetPath ".agents"
            if (-not (Test-Path $AgentsDirForMove)) {
                New-Item -ItemType Directory -Path $AgentsDirForMove -Force | Out-Null
            }
            Move-Item -Path $LegacyClaudeSkills -Destination $SkillsDest -Force
            $LegacyDebugSessions = Join-Path $TargetPath ".claude\debug-sessions"
            if (Test-Path $LegacyDebugSessions) {
                Move-Item -Path $LegacyDebugSessions -Destination $SessionsDest -Force
            }
            Write-Host "  .claude/skills を .agents/skills に移動しました"
        } else {
            Write-Host "  両方の配置を維持します（.claude/skills と .agents/skills の両方が読み込まれます）"
        }
        Write-Host ""
    }
}

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

# .claude/skills への橋渡し（Claude Code 用）
# シンボリックリンクの作成には管理者権限または開発者モードが必要な場合がある。
# 失敗した場合はコピーにフォールバックする（自動追従はしない）。
$ClaudeDir = Join-Path $TargetPath ".claude"
if (-not $CursorOnly -and -not $LegacyClaude -and -not $NoClaudeBridge) {
    $ClaudeSkillsDest = Join-Path $ClaudeDir "skills"
    # Test-Path はリンク先が存在しない（壊れた）シンボリックリンクに対して False を
    # 返すため、Get-Item -Force でエントリ自体の有無を見る（init.sh の
    # `[ -e X ] || [ -L X ]` と同じ判定にする）。
    if (Get-Item -Path $ClaudeSkillsDest -Force -ErrorAction SilentlyContinue) {
        Write-Host "情報: $ClaudeSkillsDest は既に存在します（変更しません）"
    } else {
        if (-not (Test-Path $ClaudeDir)) {
            New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
        }
        try {
            New-Item -ItemType SymbolicLink -Path $ClaudeSkillsDest -Target $SkillsDest -ErrorAction Stop | Out-Null
            Write-Host "Claude Code 用に .claude/skills を作成しました（$SkillsDest へのシンボリックリンク）"
        } catch {
            Copy-Item -Path $SkillsDest -Destination $ClaudeSkillsDest -Recurse -Force
            Write-Host "警告: シンボリックリンクを作成できなかったため .claude/skills をコピーしました"
            Write-Host "      このコピーは自動追従しません。$SkillsDest を更新したら再実行してください"
            Write-Host "      （管理者権限または開発者モードでシンボリックリンクが作成できます）"
        }
    }
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

        # Claude Code 用 hooks（.agents 配置かつ橋渡しが有効な場合のみ）
        $SourceClaudeHooks = Join-Path $SourceHooks "claude-code"
        if (-not $CursorOnly -and -not $LegacyClaude -and -not $NoClaudeBridge -and (Test-Path $SourceClaudeHooks)) {
            # ソースの構造（hooks/_hook-lib.sh を hooks/claude-code/*.sh が ../ で参照）を
            # そのまま維持して配置する（symlink は使わない）。
            $ClaudeHooksDest = Join-Path $ClaudeDir "hooks"
            $ClaudeHooksClaudeCodeDest = Join-Path $ClaudeHooksDest "claude-code"
            if (-not (Test-Path $ClaudeHooksClaudeCodeDest)) {
                New-Item -ItemType Directory -Path $ClaudeHooksClaudeCodeDest -Force | Out-Null
            }
            Copy-Item -Path (Join-Path $SourceHooks "_hook-lib.sh") -Destination $ClaudeHooksDest -Force
            Copy-Item -Path (Join-Path $SourceClaudeHooks "*.sh") -Destination $ClaudeHooksClaudeCodeDest -Force
            Write-Host "Claude Code 用 hooks スクリプトを配置しました: $ClaudeHooksDest"

            $ClaudeSettings = Join-Path $ClaudeDir "settings.json"
            $ClaudeSettingsSrc = Join-Path $SourceTemplates ".claude\settings.json.template"
            if (Test-Path $ClaudeSettings) {
                Write-Host "情報: $ClaudeSettings は既に存在します（上書きしません）"
                Write-Host "      hooks / permissions を手動で統合してください: $ClaudeSettingsSrc"
            } elseif (Test-Path $ClaudeSettingsSrc) {
                Copy-Item -Path $ClaudeSettingsSrc -Destination $ClaudeSettings -Force
                Write-Host "settings.json を作成しました: $ClaudeSettings"
            }
        }
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

    # Claude Code は AGENTS.md を自動では読まないため、import 一行だけの
    # CLAUDE.md を置いて橋渡しする（本文は複製しない）。
    $ClaudeMdDest = Join-Path $TargetPath "CLAUDE.md"
    if (Test-Path $ClaudeMdDest) {
        Write-Host "情報: $ClaudeMdDest は既に存在します（上書きしません）"
        Write-Host "      AGENTS.md を読ませるには '@AGENTS.md' の行を追加してください"
    } else {
        Set-Content -Path $ClaudeMdDest -Value "@AGENTS.md" -Encoding UTF8
        Write-Host "CLAUDE.md を作成しました（@AGENTS.md を import）"
    }
}

# .sh スクリプトに実行権限を付与する。Copy-Item は git が記録している実行ビット
# （100755）を引き継がないため、Git Bash があれば chmod で明示的に付与する。
# 無ければ手動で実行する手順を案内する。
$BashExe = $null
$bashCmd = Get-Command bash.exe -ErrorAction SilentlyContinue
if ($bashCmd) {
    $BashExe = $bashCmd.Source
} elseif (Test-Path "C:\Program Files\Git\bin\bash.exe") {
    $BashExe = "C:\Program Files\Git\bin\bash.exe"
}
$PosixTarget = ($TargetPath -replace '\\', '/')
if ($BashExe) {
    & $BashExe -lc "find '$PosixTarget' -name '*.sh' -exec chmod +x {} \;" 2>$null
    Write-Host "スクリプトに実行権限を付与しました（Git Bash 経由）"
} else {
    Write-Host "情報: Git Bash が見つからないため実行権限の自動付与をスキップしました"
    Write-Host "      Git Bash または WSL で次を実行してください:"
    Write-Host "        find '$PosixTarget' -name '*.sh' -exec chmod +x {} \;"
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
} elseif ($NoClaudeBridge) {
    Write-Host "（Cursor / Codex は .agents/skills を読み込みます。Claude Code 用の橋渡しは -NoClaudeBridge で無効化されています）"
} else {
    Write-Host "（Cursor は .agents/skills を、Claude Code は .claude/skills 経由の橋渡しで読み込みます。Codex は .agents/skills を直接読みます）"
}
