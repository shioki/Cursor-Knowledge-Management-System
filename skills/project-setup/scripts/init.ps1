# project-setup: プロジェクトに知識管理システムを初期セットアップするスクリプト（Windows PowerShell, v6.2.2）
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
#   NoBackup      - 再実行時に skills/ の退避を作らない
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
    [switch]$NoClaudeBridge,
    [Parameter(Mandatory = $false)]
    [switch]$NoBackup
)

# 再実行時に置き換えない利用者データ（skills/ からの相対パス）。
# _skill-base.sh の ckms_preserved_dirs / ckms_preserved_files と同じ内容に保つ。
$CkmsPreservedDirs = @(
    "knowledge-management/references/decisions"
    "pattern-library/references/patterns"
    "improvement-tracking/references/improvements"
)
$CkmsPreservedFiles = @(
    "knowledge-management/references/KNOWLEDGE_TEMPLATE.md"
    "pattern-library/references/PATTERNS_TEMPLATE.md"
    "improvement-tracking/references/IMPROVEMENTS_TEMPLATE.md"
    "project-context/references/CONTEXT_TEMPLATE.md"
    "debug-workflow/references/DEBUG_TEMPLATE.md"
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

Write-Host "=== Cursor Knowledge Management System セットアップ (v6.2.2) ==="
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

# BOM 無しの UTF-8 で書く。Windows PowerShell 5.1 の Set-Content -Encoding UTF8 は
# BOM を付け、hooks.json の JSON 読み込みや CLAUDE.md の @import を壊す。
function Write-CkmsUtf8([string]$Path, [string]$Text) {
    $encoding = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Text, $encoding)
}

function Join-CkmsRel([string]$Base, [string]$Rel) {
    $path = $Base
    foreach ($part in ($Rel -split '/')) {
        if ($part) { $path = Join-Path $path $part }
    }
    return $path
}

# シンボリックリンクかジャンクションか。OneDrive のクラウドファイルなども
# 再解析点の属性を持つため、属性だけでは判定しない。
function Test-CkmsLink($Item) {
    if (-not ($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) { return $false }
    return @('SymbolicLink', 'Junction') -contains [string]$Item.LinkType
}

# リンク先のパス。相対パスはリンクのあるディレクトリから解決する。
function Get-CkmsLinkTarget($Item) {
    foreach ($prop in @('LinkTarget', 'Target')) {
        $member = $Item.PSObject.Properties[$prop]
        if ($null -eq $member) { continue }
        $value = $member.Value
        if ($value -is [array]) { $value = $value | Select-Object -First 1 }
        if (-not $value) { continue }
        $target = ([string]$value) -replace '^\\\?\?\\', ''
        if (-not [System.IO.Path]::IsPathRooted($target)) {
            $target = [System.IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $Item.FullName) $target))
        }
        return $target
    }
    return $null
}

# シンボリックリンク / ジャンクションを、同じ種類・同じリンク先で作り直す。
# Copy-Item はリンクをたどって中身をコピーするため、共有先へのリンクが
# 実ディレクトリに変わってしまう。
function Copy-CkmsLink($Item, [string]$To) {
    $target = Get-CkmsLinkTarget $Item
    if (-not $target) { throw "リンク先を読めません: $($Item.FullName)" }
    $type = if ([string]$Item.LinkType -eq 'Junction') { 'Junction' } else { 'SymbolicLink' }
    New-Item -ItemType $type -Path $To -Target $target | Out-Null
}

# リンクをたどらずに削除する。Windows PowerShell 5.1 の Remove-Item -Recurse は、
# 中にあるジャンクションやシンボリックリンクの先まで消すことがある。
function Remove-CkmsTree([string]$Path) {
    if (-not $Path) { return }
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if (-not $item) { return }
    if (Test-CkmsLink $item) {
        $item.Delete()
        return
    }
    if ($item.PSIsContainer) {
        foreach ($child in @(Get-ChildItem -LiteralPath $Path -Force)) {
            Remove-CkmsTree $child.FullName
        }
    }
    Remove-Item -LiteralPath $Path -Recurse -Force
}

# From の中身を To に重ねる。同じパスは From が優先。リンクはリンクのまま置く。
function Copy-CkmsOverlay([string]$From, [string]$To) {
    if (-not (Test-Path -LiteralPath $To)) {
        New-Item -ItemType Directory -Path $To -Force | Out-Null
    }
    foreach ($child in @(Get-ChildItem -LiteralPath $From -Force)) {
        $target = Join-Path $To $child.Name
        if (Test-CkmsLink $child) {
            Remove-CkmsTree $target
            Copy-CkmsLink $child $target
        } elseif ($child.PSIsContainer) {
            Copy-CkmsOverlay $child.FullName $target
        } else {
            Copy-Item -LiteralPath $child.FullName -Destination $target -Force
        }
    }
}

function Copy-CkmsPreserved([string]$SkillName, [string]$FromRoot, [string]$ToRoot, [switch]$Overlay) {
    foreach ($rel in ($CkmsPreservedDirs + $CkmsPreservedFiles)) {
        $prefix = "$SkillName/"
        if (-not $rel.StartsWith($prefix)) { continue }
        $inner = $rel.Substring($prefix.Length)
        $from = Join-CkmsRel $FromRoot $inner
        # Test-Path はリンク切れを False にするため、Get-Item で存在を見る。
        $fromItem = Get-Item -LiteralPath $from -Force -ErrorAction SilentlyContinue
        if (-not $fromItem) { continue }
        $to = Join-CkmsRel $ToRoot $inner
        $isLink = Test-CkmsLink $fromItem
        if ($Overlay -and $fromItem.PSIsContainer -and -not $isLink) {
            Copy-CkmsOverlay $from $to
            continue
        }
        $parent = Split-Path -Parent $to
        if ($parent -and -not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        Remove-CkmsTree $to
        if ($isLink) {
            Copy-CkmsLink $fromItem $to
        } elseif ($fromItem.PSIsContainer) {
            Copy-CkmsOverlay $from $to
        } else {
            Copy-Item -LiteralPath $from -Destination $to -Force
        }
    }
}

function Update-CkmsSkill([System.IO.DirectoryInfo]$SrcDir) {
    $name = $SrcDir.Name
    $dest = Join-Path $SkillsDest $name
    if (-not (Test-Path -LiteralPath $dest)) {
        Copy-Item -LiteralPath $SrcDir.FullName -Destination $dest -Recurse -Force
        Write-Host "  追加: $name"
        return
    }
    $srcSkill = Join-Path $SrcDir.FullName "SKILL.md"
    $destSkill = Join-Path $dest "SKILL.md"
    if ((Test-Path -LiteralPath $destSkill) -and (Test-Path -LiteralPath $srcSkill)) {
        $srcHash = (Get-FileHash -LiteralPath $srcSkill -Algorithm SHA256).Hash
        $destHash = (Get-FileHash -LiteralPath $destSkill -Algorithm SHA256).Hash
        if ($srcHash -ne $destHash) {
            if ($script:SkillsBackup) {
                $previousSkill = Join-Path (Join-Path $script:SkillsBackup $name) "SKILL.md"
                Write-Host "  警告: $name/SKILL.md は配布元と異なります（版の更新でも、カスタマイズでも起きます）。新しい内容で置き換えます。カスタマイズしていた場合は $previousSkill から戻してください"
            } else {
                Write-Host "  警告: $name/SKILL.md は配布元と異なります。新しい内容で置き換えます（-NoBackup のため退避していません）"
            }
        }
    }
    $stage = Join-Path ([System.IO.Path]::GetTempPath()) ("ckms-" + [guid]::NewGuid().ToString("N"))
    $incoming = $null
    $replacedOld = $null
    New-Item -ItemType Directory -Path $stage -Force | Out-Null
    try {
        Copy-CkmsPreserved $name $dest $stage
        # 導入先と同じ親に置き、別ボリュームの Move-Item を避ける。
        $incoming = Join-Path (Split-Path -Parent $SkillsDest) (".ckms-incoming-" + [guid]::NewGuid().ToString("N"))
        New-Item -ItemType Directory -Path $incoming -Force | Out-Null
        $assembled = Join-Path $incoming $name
        Copy-Item -LiteralPath $SrcDir.FullName -Destination $assembled -Recurse -Force
        Copy-CkmsPreserved $name $stage $assembled -Overlay
        # どかし先は skills/ の外に作る。中に残ると、失敗したとき同じ name の
        # スキルとして読み込まれる。
        $replacedBox = Join-Path (Split-Path -Parent $SkillsDest) (".ckms-replaced-" + [guid]::NewGuid().ToString("N"))
        New-Item -ItemType Directory -Path $replacedBox -Force | Out-Null
        $replacedOld = Join-Path $replacedBox $name
        $swapped = $false
        try {
            Move-Item -LiteralPath $dest -Destination $replacedOld
            Move-Item -LiteralPath $assembled -Destination $dest
            $swapped = $true
        } finally {
            # 失敗でも Ctrl+C でも通る（Ctrl+C では catch は走らない）。
            # 配置先が空なら、入れ替え前のスキルを戻す。
            if (-not $swapped -and -not (Test-Path -LiteralPath $dest) -and (Test-Path -LiteralPath $replacedOld)) {
                try {
                    Move-Item -LiteralPath $replacedOld -Destination $dest
                    $replacedOld = $null
                    Write-Host "  $name を入れ替え前に戻しました"
                } catch {
                    Write-Host "エラー: 入れ替え前のスキルを戻せません: $replacedOld"
                }
            }
            # 戻せたとき、または最初の Move-Item が失敗したときは空で残る
            if (-not $swapped -and (Test-Path -LiteralPath $replacedBox) -and
                -not (Get-ChildItem -LiteralPath $replacedBox -Force)) {
                Remove-Item -LiteralPath $replacedBox -Force
            }
        }
        Remove-CkmsTree $replacedBox
        Remove-CkmsTree $stage
        Remove-CkmsTree $incoming
        Write-Host "  更新: $name"
    } catch {
        Write-Host "エラー: $name の置き換えに失敗しました。利用者データの退避先: $stage"
        if ($incoming -and (Test-Path -LiteralPath $incoming)) {
            Write-Host "      組み立て済みのコピー: $incoming"
        }
        if ($replacedOld -and (Test-Path -LiteralPath $replacedOld)) {
            Write-Host "      入れ替え前のスキル: $replacedOld"
            if (Test-Path -LiteralPath $dest) {
                Write-Host "      配置先 $dest を削除してから、入れ替え前のスキルをそこへ移動してください。"
            } else {
                Write-Host "      入れ替え前のスキルを配置先 $dest へ移動してください。"
            }
        } else {
            Write-Host "      導入先は変更していません。"
            if (-not $incoming) {
                Write-Host "      表示した退避先は途中までのコピーです。"
            }
        }
        throw
    }
}

# シンボリックリンクをたどった実パス。Resolve-Path はリンクを解決しない。
function ConvertTo-CkmsPhysicalPath([string]$Path) {
    $current = (Resolve-Path -LiteralPath $Path).Path
    $root = [System.IO.Path]::GetPathRoot($current)
    $remainder = $current.Substring($root.Length)
    $built = $root
    foreach ($part in ($remainder -split '[\\/]' | Where-Object { $_ })) {
        $built = if ($built.EndsWith('\') -or $built.EndsWith('/')) { "$built$part" } else { Join-Path $built $part }
        if (-not (Test-Path -LiteralPath $built)) { return $current }
        $item = Get-Item -LiteralPath $built -Force
        if (-not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) { continue }
        $target = $null
        foreach ($prop in @('ResolvedTarget', 'LinkTarget', 'Target')) {
            $member = $item.PSObject.Properties[$prop]
            if ($null -eq $member) { continue }
            $value = $member.Value
            if ($value -is [array]) { $value = $value | Select-Object -Last 1 }
            if ($value) { $target = [string]$value; break }
        }
        if (-not $target) { continue }
        if (-not [System.IO.Path]::IsPathRooted($target)) {
            $target = [System.IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $item.FullName) $target))
        }
        $built = $target
    }
    return $built
}

# skills/
# 初回は配布元をそのまま置く。再実行は配布元にあるスキルだけを置き換え、
# 記録・テンプレート・配布元に無いスキルは残す。
$script:SkillsBackup = $null
# 最後の案内を分けるため、skills/ をどう扱ったかを残す（new / updated / skipped / link）
$SkillsState = 'new'
$pluginManifest = Join-Path $SourceRoot ".cursor-plugin\plugin.json"
if (-not (Test-Path -LiteralPath $pluginManifest)) {
    Write-Host "警告: 配布元が CKMS リポジトリではありません: $SourceRoot"
    Write-Host "      別プロジェクトの init.ps1 を使うと、その記録が導入先に入ります。"
    Write-Host "      CKMS リポジトリの init.ps1 を使ってください。"
}
$skillsItem = Get-Item -LiteralPath $SkillsDest -Force -ErrorAction SilentlyContinue
if ($skillsItem) {
    if ($skillsItem.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        Write-Host "情報: $SkillsDest はシンボリックリンクです（変更しません）"
        $SkillsState = 'link'
    } else {
        $sourceReal = (ConvertTo-CkmsPhysicalPath ([string]$SourceSkills)).TrimEnd('\', '/')
        $destReal = (ConvertTo-CkmsPhysicalPath $SkillsDest).TrimEnd('\', '/')
        if ($sourceReal -eq $destReal) {
            Write-Error "エラー: 配布元と導入先が同じディレクトリです: $destReal`nCKMS リポジトリの init.ps1 を、導入先のパスを引数にして実行してください。"
            exit 1
        }
        $skillDirs = @(Get-ChildItem -LiteralPath $SourceSkills -Directory)
        Write-Host "情報: $SkillsDest は既に存在します"
        Write-Host ("  CKMS の {0} スキルを置き換えます。decisions/ patterns/ improvements/ と *_TEMPLATE.md、プロジェクト固有のスキルは残します。" -f $skillDirs.Count)
        if (Confirm-Overwrite "続行しますか?") {
            if (-not $NoBackup) {
                $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
                $script:SkillsBackup = "$SkillsDest.backup-$stamp"
                $backupN = 0
                while (Test-Path -LiteralPath $script:SkillsBackup) {
                    $backupN++
                    $script:SkillsBackup = "$SkillsDest.backup-$stamp-$backupN"
                }
                try {
                    Copy-Item -LiteralPath $SkillsDest -Destination $script:SkillsBackup -Recurse -Force
                } catch {
                    Write-Host "エラー: バックアップの作成に失敗しました: $script:SkillsBackup"
                    Write-Host "      作りかけのため削除します。"
                    if (Test-Path -LiteralPath $script:SkillsBackup) {
                        try {
                            Remove-CkmsTree $script:SkillsBackup
                        } catch {
                            Write-Host "      削除できませんでした: $script:SkillsBackup"
                        }
                    }
                    throw
                }
                Write-Host "  バックアップ: $script:SkillsBackup"
            }
            foreach ($skillDir in $skillDirs) {
                Update-CkmsSkill $skillDir
            }
            foreach ($existing in @(Get-ChildItem -LiteralPath $SkillsDest -Directory)) {
                $sourceMatch = Join-Path $SourceSkills $existing.Name
                if (-not (Test-Path -LiteralPath $sourceMatch)) {
                    Write-Host "  情報: $($existing.Name) は配布元に無いので残しました"
                }
            }
            Write-Host "skills/ を更新しました"
            $SkillsState = 'updated'
        } else {
            Write-Host "  skills/ の更新をスキップしました"
            $SkillsState = 'skipped'
        }
    }
} else {
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
            # 登録済みのエントリまで追記を促すと、再実行のたびに hooks が二重になる。
            # 無いものだけ案内する。
            $hasSessionHook = Select-String -LiteralPath $HooksJson -SimpleMatch '.cursor/hooks/inject-knowledge-index.sh' -Quiet
            $hasEditHook = Select-String -LiteralPath $HooksJson -SimpleMatch '.cursor/hooks/log-activity.sh' -Quiet
            if ($hasSessionHook -and $hasEditHook) {
                Write-Host "情報: $HooksJson は既に存在し、CKMS の hooks は登録済みです（上書きしません）"
            } else {
                Write-Host "情報: $HooksJson は既に存在します（上書きしません）"
                Write-Host "      次のエントリを手動で追記してください:"
                if (-not $hasSessionHook) { Write-Host '        "sessionStart": [{ "command": ".cursor/hooks/inject-knowledge-index.sh" }]' }
                if (-not $hasEditHook) { Write-Host '        "afterFileEdit": [{ "command": ".cursor/hooks/log-activity.sh" }]' }
            }
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
            Write-CkmsUtf8 $HooksJson ($HooksConfig + "`n")
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
                $settingsMissing = @(
                    'session-start.sh', 'post-tool-use-log-activity.sh', 'stop-suggest-record.sh' |
                        Where-Object { -not (Select-String -LiteralPath $ClaudeSettings -SimpleMatch ".claude/hooks/claude-code/$_" -Quiet) }
                )
                if ($settingsMissing.Count -eq 0) {
                    Write-Host "情報: $ClaudeSettings は既に存在し、CKMS の hooks は登録済みです（上書きしません）"
                } else {
                    Write-Host "情報: $ClaudeSettings は既に存在します（上書きしません）"
                    Write-Host ("      未登録の hooks: " + ($settingsMissing -join ' '))
                    Write-Host "      hooks / permissions を手動で統合してください: $ClaudeSettingsSrc"
                }
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
    if (Test-Path $CursorignoreDest) {
        $srcHash = (Get-FileHash -LiteralPath $CursorignoreSrc -Algorithm SHA256).Hash
        $destHash = (Get-FileHash -LiteralPath $CursorignoreDest -Algorithm SHA256).Hash
        if ($srcHash -eq $destHash) {
            Write-Host "情報: $CursorignoreDest は既に存在します（上書きしません）"
        } else {
            Write-Host "情報: $CursorignoreDest は既に存在し、配布元と差分があります（上書きしません）"
        }
        # v6.1.1 以前の .cursorignore には退避先の除外が無い。再実行で作る
        # skills.backup-*/ が索引に入り、古い記録が検索に混じる。
        if (-not (Select-String -LiteralPath $CursorignoreDest -Pattern 'skills\.backup-' -Quiet)) {
            Write-Host "  再実行の退避先を索引から外すため、次の行を $CursorignoreDest に追加してください:"
            Select-String -LiteralPath $CursorignoreSrc -Pattern 'skills\.backup-' | ForEach-Object { Write-Host "    $($_.Line)" }
        }
    } else {
        Copy-Item -Path $CursorignoreSrc -Destination $CursorignoreDest -Force
        Write-Host ".cursorignore をコピーしました"
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
        Write-CkmsUtf8 $ClaudeMdDest "@AGENTS.md`n"
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
if ($SkillsState -eq 'new') {
    Write-Host "次のステップ:"
    Write-Host "  1. /update-context でプロジェクト基本情報を記入"
    Write-Host "  2. /record-decision で最初の技術判断を記録"
    Write-Host "  3. team-standards スキルをプロジェクトの規約に更新"
    Write-Host ""
} elseif ($SkillsState -eq 'updated') {
    Write-Host "CKMS のスキルを更新しました。記録とプロジェクト固有のスキルは残しています。"
    if ($script:SkillsBackup) {
        Write-Host "  更新前の skills/: $script:SkillsBackup"
        Write-Host "  SKILL.md の警告が出たスキルをカスタマイズしていた場合は、ここから戻してください。不要になったら削除してかまいません。"
    }
    Write-Host ""
}
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
