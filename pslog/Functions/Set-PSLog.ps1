function Set-PSLog {
    <#
    .SYNOPSIS
    Configure pslog global settings

    .DESCRIPTION
    Sets the global variables used by the pslog module: the logfile path and the log level.

    .PARAMETER LogFile
    Path to the log file. Must be a path whose parent directory exists.

    .PARAMETER LogLevel
    Log level to use. Valid values: Error, Warning, Information, Verbose, Debug

    .EXAMPLE
    Set-PSLog -LogFile "$home/pslog.log" -LogLevel Information
    # Sets the global logfile and log level
    #>
    [CmdletBinding()]
    param (
        [ValidateScript({Test-Path (Split-Path -Parent $_)}, ErrorMessage='Invalid path')]
        [string]$LogFile,

        [ValidateSet('Error','Warning','Information','Verbose','Debug')]
        [string]$LogLevel
    )

    if ($LogFile) {
        $Global:LogFile = $LogFile
    }

    if ($LogLevel) {
        # Use 0-based severity where higher number = more verbose
        $Global:LogLevel = switch($LogLevel) {
            'Error' { 0 }
            'Warning' { 1 }
            'Information' { 2 }
            'Verbose' { 3 }
            'Debug' { 4 }
        }
    }
}
