function Remove-PSLog {
    <#
    .SYNOPSIS
    Remove pslog module global settings

    .DESCRIPTION
    Removes any global variables set by the pslog module (LogFile, LogLevel, LogOnly)
    and returns an object describing the previous values.

    .EXAMPLE
    Remove-PSLog
    #>
    [CmdletBinding()]
    param ()

    $removed = [ordered]@{
        LogFile  = $null
        LogLevel = $null
        LogOnly  = $false
    }

    if (Get-Variable -Name LogFile -Scope Global -ErrorAction SilentlyContinue) {
        $removed.LogFile = $Global:LogFile
        Remove-Variable -Name LogFile -Scope Global -ErrorAction SilentlyContinue
    }

    if (Get-Variable -Name LogLevel -Scope Global -ErrorAction SilentlyContinue) {
        $removed.LogLevel = $Global:LogLevel
        Remove-Variable -Name LogLevel -Scope Global -ErrorAction SilentlyContinue
    }

    if (Get-Variable -Name LogOnly -Scope Global -ErrorAction SilentlyContinue) {
        $removed.LogOnly = [bool]$Global:LogOnly
        Remove-Variable -Name LogOnly -Scope Global -ErrorAction SilentlyContinue
    }

    return [PSCustomObject]$removed
}
