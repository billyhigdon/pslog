function Get-PSLog {
    <#
    .SYNOPSIS
    Show pslog global settings
    .DESCRIPTION
    .EXAMPLE
    Get-PSLog
    #>    
    [CmdletBinding()]
    param ()
    $hasLogFile = $false
    $hasLogLevel = $false
    $hasLogOnly = $false

    try {
        Get-Variable LogFile -Scope Global -ErrorAction Stop | Out-Null
        $hasLogFile = $true
    } catch {
    }

    try {
        Get-Variable LogLevel -Scope Global -ErrorAction Stop | Out-Null
        $hasLogLevel = $true
    } catch {
    }

    try {
        Get-Variable LogOnly -Scope Global -ErrorAction Stop | Out-Null
        $hasLogOnly = $true
    } catch {

    }

    # Return a simple object describing the current state for programmatic inspection
    [PSCustomObject]@{
        LogFile  = if ($hasLogFile) {
            $Global:LogFile
        } else {
            $null 
        }
        LogLevel = if ($hasLogLevel) {
            $Global:LogLevel 
        } else {
            $null 
        }
        LogOnly  = if ($hasLogOnly) {
            [bool]$Global:LogOnly
        } else { 
            $false
        }
    }
}
