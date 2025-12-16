function Get-PSLog {
    <#
    .SYNOPSIS
    Show pslog global settings
    .DESCRIPTION
    Writes warnings if the global LogFile or LogLevel variables are not set.
    .EXAMPLE
    Get-PSLog
    #>    
    [CmdletBinding()]
    param ()

    try {
        Get-Variable LogFile -ErrorAction Stop
    } catch {
        Write-Warning "`$Global:LogFile not set"
    }

    try {
        Get-Variable LogLevel -ErrorAction Stop
    } catch {
        Write-Warning "`$Global:LogLevel not set"
    }
}
