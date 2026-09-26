# init.ps1 の入れ替え中に Ctrl+C されたとき、元のスキルが戻ることを確かめる。
#
# Usage: pwsh -NoProfile -File scripts/smoke-init-ps-interrupt.ps1 -TargetPath C:\ckms-interrupt
#        （Windows PowerShell 5.1 では powershell -NoProfile -File ...）
#
# Ctrl+C はパイプラインの停止として届く。同じ停止を PowerShell.Stop() で起こす。
# Move-Item を関数で差し替え、新しいスキルを配置先へ置く直前で止めて待つ。
# 導入先のスキルはどかされ、まだ新しいスキルが無い状態になる。
# 日本語を含むため UTF-8（BOM 付き）で保存する。BOM が無いと 5.1 が ANSI として読む。

param(
    [Parameter(Mandatory = $true)]
    [string]$TargetPath
)

$ErrorActionPreference = "Stop"
$initPs1 = Join-Path $PSScriptRoot "..\skills\project-setup\scripts\init.ps1"
$initPs1 = (Resolve-Path -LiteralPath $initPs1).Path
$skillName = "knowledge-management"

New-Item -ItemType Directory -Force -Path $TargetPath | Out-Null
& $initPs1 -TargetPath $TargetPath -Yes -NoHooks -NoAgents | Out-Null
$skillDir = Join-Path $TargetPath ".agents\skills\$skillName"
$marker = Join-Path $skillDir "references\decisions\user-only.md"
Set-Content -LiteralPath $marker -Value "kept-user"

$paused = Join-Path ([System.IO.Path]::GetTempPath()) ("ckms-paused-" + [guid]::NewGuid().ToString("N"))

$runspace = [runspacefactory]::CreateRunspace()
$runspace.Open()
$runspace.SessionStateProxy.SetVariable("CkmsPausedFile", $paused)
$runspace.SessionStateProxy.SetVariable("CkmsPauseSkill", $skillName)

$setup = [powershell]::Create()
$setup.Runspace = $runspace
[void]$setup.AddScript({
    function global:Move-Item {
        param([string]$LiteralPath, [string]$Destination)
        $leaf = Split-Path -Leaf $LiteralPath
        $parentLeaf = Split-Path -Leaf (Split-Path -Parent $LiteralPath)
        if ($leaf -eq $global:CkmsPauseSkill -and $parentLeaf -like ".ckms-incoming-*") {
            Set-Content -LiteralPath $global:CkmsPausedFile -Value "paused"
            Start-Sleep -Seconds 300
        }
        Microsoft.PowerShell.Management\Move-Item -LiteralPath $LiteralPath -Destination $Destination
    }
})
$setup.Invoke() | Out-Null
$setup.Dispose()

$run = [powershell]::Create()
$run.Runspace = $runspace
[void]$run.AddCommand($initPs1).AddParameter("TargetPath", $TargetPath).AddParameter("Yes", $true).AddParameter("NoHooks", $true).AddParameter("NoAgents", $true)
$async = $run.BeginInvoke()

$deadline = (Get-Date).AddSeconds(180)
while (-not (Test-Path -LiteralPath $paused)) {
    if ($async.IsCompleted) { throw "init.ps1 finished before reaching the swap" }
    if ((Get-Date) -gt $deadline) { throw "init.ps1 did not reach the swap in time" }
    Start-Sleep -Milliseconds 200
}

# 止めた時点では、導入先のスキルはどかされているはず
if (Test-Path -LiteralPath $skillDir) { throw "expected $skillDir to be moved aside while paused" }

$run.Stop()
$stopped = $false
try {
    $run.EndInvoke($async) | Out-Null
} catch {
    $stopped = $true
}
Write-Host "init.ps1 output after stop:"
foreach ($record in $run.Streams.Information) { Write-Host "  $record" }
foreach ($record in $run.Streams.Error) { Write-Host "  [error] $record" }
$state = $run.InvocationStateInfo.State
$run.Dispose()
$runspace.Close()
Remove-Item -LiteralPath $paused -Force -ErrorAction SilentlyContinue

if ($state -ne "Stopped" -and -not $stopped) { throw "init.ps1 was not stopped (state: $state)" }
if (-not (Test-Path -LiteralPath (Join-Path $skillDir "SKILL.md"))) { throw "$skillName was not restored after the interrupt" }
if (-not (Test-Path -LiteralPath $marker)) { throw "user record was lost after the interrupt" }
$skillsDir = Split-Path -Parent $skillDir
$leftover = @(Get-ChildItem -LiteralPath $skillsDir -Directory -Filter "$skillName.replacing.*") +
    @(Get-ChildItem -LiteralPath (Split-Path -Parent $skillsDir) -Directory -Force -Filter ".ckms-replaced-*")
if ($leftover.Count -gt 0) { throw "pre-swap copy was left behind: $($leftover[0].FullName)" }
Write-Host "ok: interrupted swap restored $skillName (state: $state)"
