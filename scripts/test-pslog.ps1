<#
.SYNOPSIS
Runs the module's Pester suite and an end-to-end functional test script for pslog.
.DESCRIPTION
This script imports the `pslog` module, runs the Pester test folder, and performs a set
of functional checks (Set-PSLog, Write-PSLog across streams, Get-PSLog, Remove-PSLog, and cleanup).
It exits with non-zero on any failure so it can be used in CI.
#>

[CmdletBinding()]
param()

function Fail([string]$Message) {
    Write-Error $Message
    exit 1
}

function Assert($Condition, [string]$Message) {
    if (-not $Condition) {
        Write-Host "ASSERT FAILED: $Message"
        Write-Host "  Current values: LogFile=$($Global:LogFile), LogLevel=$($Global:LogLevel), TempLog=$TempLog"
        Fail $Message
    }
}

Write-Host "Importing pslog module..."
# script lives at ./scripts, module manifest lives at ./pslog/pslog.psd1
# Use nested Join-Path for PowerShell 5 compatibility
Import-Module (Join-Path (Join-Path (Join-Path $PSScriptRoot '..') 'pslog') 'pslog.psd1') -Force -ErrorAction Stop

Write-Host "Running unit tests (Pester)..."
try {
    # Use nested Join-Path for PowerShell 5 compatibility
    $pester = Invoke-Pester -Script (Join-Path (Join-Path $PSScriptRoot '..') 'pslog' 'Tests') -Output Detailed -PassThru -ErrorAction Stop
} catch {
    Fail "Pester run failed: $($_.Exception.Message)"
}

if ($pester.FailedCount -gt 0) { Fail "Pester reported failures: $($pester.FailedCount)" }

Write-Host "Running end-to-end functional checks..."

# Prepare temp paths
$TempRoot = $env:TEMP
if (-not $TempRoot) { $TempRoot = [System.IO.Path]::GetTempPath() }
$TempLog = Join-Path -Path $TempRoot -ChildPath "pslog_e2e_$((Get-Date).ToFileTime()).log"

try {
    # Ensure clean state
    Remove-Variable -Name LogFile -Scope Global -ErrorAction SilentlyContinue
    Remove-Variable -Name LogLevel -Scope Global -ErrorAction SilentlyContinue
    Remove-Variable -Name LogOnly -Scope Global -ErrorAction SilentlyContinue

    Write-Host "Test: Set-PSLog sets LogFile and LogLevel"
    Set-PSLog -LogFile $TempLog -LogLevel Information
    if ($Global:LogFile -ne $TempLog) {
        Write-Host "LogFile mismatch detected"
        Write-Host "  Global: [$($Global:LogFile)] (len=$($Global:LogFile.Length))"
        Write-Host "  Expected: [$TempLog] (len=$($TempLog.Length))"
        # show raw bytes for more visibility
        $gBytes = [System.Text.Encoding]::UTF8.GetBytes($Global:LogFile.ToString())
        $tBytes = [System.Text.Encoding]::UTF8.GetBytes($TempLog.ToString())
        Write-Host "  Global bytes: $($gBytes -join ' ')"
        Write-Host "  Expected bytes: $($tBytes -join ' ')"
        Fail "Global LogFile mismatch"
    }
    # ensure LogLevel is set and looks like a valid mapped numeric value
    Assert(($Global:LogLevel -ne $null) -and ($Global:LogLevel -is [int]) -and ($Global:LogLevel -ge 0) -and ($Global:LogLevel -le 4), "Global LogLevel not set to a valid value: $($Global:LogLevel)")

    Write-Host "Test: Write-PSLog writes pipeline lines to file"
    'first','second' | Write-PSLog -OutStream Information
    Assert((Test-Path $TempLog), "Log file was not created")
    $lines = Get-Content $TempLog
    Assert(($lines.Count -ge 2), "Expected at least two lines in logfile")

    Write-Host "Test: Write-PSLog handles enumerable and null items"
    @('a','b','c') | Write-PSLog -OutStream Information
    $countBefore = (Get-Content $TempLog).Count
    $null | Write-PSLog -OutStream Information
    $linesAfterNull = Get-Content $TempLog
    Assert(($linesAfterNull.Count -eq ($countBefore + 1)), "Null message did not produce a log line")

    Write-Host "Test: LogOnly suppresses console but writes file"
    $TempLog2 = Join-Path -Path $TempRoot -ChildPath "pslog_e2e_logonly_$((Get-Date).ToFileTime()).log"
    Set-PSLog -LogFile $TempLog2 -LogLevel Information -LogOnly
    $null = 'info1' | Write-PSLog -OutStream Information -InformationVariable infos -InformationAction SilentlyContinue
    Assert(($infos -eq $null), "Information stream was not suppressed by LogOnly")
    Assert((Test-Path $TempLog2), "logonly file was not created")

    Write-Host "Test: Get-PSLog returns expected properties"
    $state = Get-PSLog
    Assert(($state -is [psobject]), "Get-PSLog did not return an object")
    Assert((($state.LogFile -eq $TempLog2) -or ($state.LogFile -eq $TempLog)), "Get-PSLog LogFile mismatch")

    Write-Host "Test: Remove-PSLog returns previous values and clears them"
    Set-PSLog -LogFile $TempLog -LogLevel Debug -LogOnly
    $previous = Remove-PSLog
    Assert(($previous.LogFile -eq $TempLog), "Remove-PSLog did not return previous LogFile")
    Assert(((Get-Variable -Name LogFile -Scope Global -ErrorAction SilentlyContinue) -eq $null), "LogFile was not removed by Remove-PSLog")

    Write-Host "All functional checks passed. Cleaning up..."
} finally {
    # Cleanup logs
    Try { Remove-Item -Path $TempLog -ErrorAction SilentlyContinue -Force } catch {}
    Try { Remove-Item -Path $TempLog2 -ErrorAction SilentlyContinue -Force } catch {}
    Remove-Variable -Name LogFile -Scope Global -ErrorAction SilentlyContinue
    Remove-Variable -Name LogLevel -Scope Global -ErrorAction SilentlyContinue
    Remove-Variable -Name LogOnly -Scope Global -ErrorAction SilentlyContinue
}

Write-Host "pslog tests and checks completed successfully." -ForegroundColor Green
exit 0
