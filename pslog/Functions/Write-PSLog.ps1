function Write-PSLog {
    <#
    .SYNOPSIS
    Write a message to console and/or appends to the pslog logfile

    .DESCRIPTION
    Writes a timestamped message to the console using the corresponding Write-* stream
    and appends the message to the configured logfile if the set log level permits it.

    .PARAMETER OutStream
    Error, Warning, Information, Verbose, Debug

    .PARAMETER Message
    The message to write (accepts pipeline input).
    
    .EXAMPLE
    'Hello' | Write-PSLog -OutStream Information
    #>
    
    [CmdletBinding()]
    param (
        [ValidateSet('Error','Warning','Information','Verbose','Debug')]
        [string]$OutStream = 'Information',

        [Parameter(ValueFromPipeline)]
        [psobject]$Message
    )

    Begin {
        $VerbosePreference='Continue'
        $InformationPreference='Continue'
        $DebugPreference='Continue'

        $LogLevels = @{
            Error       = 0
            Warning     = 1
            Information = 2
            Verbose     = 3
            Debug       = 4
        }
    }

    Process {
        $items = @()
        if ($null -eq $Message) {
            $items = @()
        } elseif ($Message -is [System.Collections.IEnumerable] -and -not ($Message -is [string])) {
            $items = $Message
        } else {
            $items = @($Message)
        }

        foreach ($item in $items) {
            $TimeStamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            $LogMessage = "$TimeStamp [$($OutStream.ToLower())] $($item | Out-String)".TrimEnd("`r`n")

            if (!$Global:LogLevel) {
                Set-PSLog -LogLevel Information
            }

            if ($Global:LogLevel -ge $LogLevels[$OutStream]) {
                switch ($OutStream) {
                    'Error'       { Write-Error -Message $LogMessage }
                    'Warning'     { Write-Warning $LogMessage }
                    'Information' { Write-Information -MessageData $LogMessage -InformationAction Continue }
                    'Verbose'     { Write-Verbose $LogMessage }
                    'Debug'       { Write-Debug $LogMessage }
                }

                try {
                    if (-not $Global:LogFile) {
                        $tempLogFile = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "pslog_$(Get-Date -Format FileDateTime)"
                        Set-PSLog -LogFile $tempLogFile
                    }

                    $parent = Split-Path -Parent $Global:LogFile
                    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
                    $LogMessage | Add-Content -Path $Global:LogFile -Encoding UTF8 -ErrorAction Stop
                } catch {
                    Write-Error $_.Exception.Message
                }
            }
        }
    }
}
