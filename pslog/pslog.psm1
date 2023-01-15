function set-pslog {
    [CmdletBinding()]
    param (
        [string]$LogFile,

        [ValidateSet("Error","Warning","Information","Verbose","Debug")]
        [string]$LogLevel
    )

    if (!$Global:LogFile) {
        $Global:Logfile = "$($env:TEMP)\$(Get-Date -Format FileDateTime)_pslog.log"
    }

    if ($LogFile) {
        $Global:LogFile = $LogFile
    }

    if (!$Global:LogLevel) {
        $Global:LogLevel = 3
    }

    if ($LogLevel) {
        $Global:LogLevel = switch($LogLevel) {
            "Error" {1}
            "Warning" {2}
            "Information" {3}
            "Verbose" {4}
            "Debug" {5}
        }
    }
}

function get-pslog {
    [CmdletBinding()]
    param (
    )

    Get-Variable LogFile
    Get-Variable LogLevel
}

function write-pslog {
    
    [CmdletBinding()]
    param (
        [ValidateSet("Error","Warning","Verbose","Debug","Information")]
        [string]$OutStream = "Information",
        [string]$Message
    )

    if (!(Test-Path $Global:LogFile)) {

        try {
            New-Item $Global:LogFile -Force -ErrorAction Stop | Out-Null
        } catch {
            $_.Exception.Message
        }
    }

    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "$TimeStamp [$($OutStream.ToLower())] $Message"
    switch($OutStream) {
        "Error" {if ($Global:LogLevel -gt 0) {
            Write-Error $LogMessage
            try {
                Add-Content -Path $Global:LogFile -Value $LogMessage -ErrorAction Stop
            } catch {
                $_.Exception.Message
            }
        }}
        "Warning" {if ($Global:LogLevel -gt 1) {
            Write-Warning $LogMessage
            try {
                Add-Content -Path $Global:LogFile -Value $LogMessage -ErrorAction Stop
            } catch {
                $_.Exception.Message
            }
        }}
        "Information"  {if ($Global:LogLevel -gt 2) {
            Write-Information $LogMessage -InformationAction Continue
            try {
                Add-Content -Path $Global:LogFile -Value $LogMessage -ErrorAction Stop
            } catch {
                $_.Exception.Message
            }
        }}
        "Verbose" {if ($Global:LogLevel -gt 3) {
            Write-Verbose $LogMessage -Verbose
            try {
                Add-Content -Path $Global:LogFile -Value $LogMessage -ErrorAction Stop
            } catch {
                $_.Exception.Message
            }
        }}
        "Debug"  {if ($Global:LogLevel -gt 4) {
            Write-Debug $LogMessage -Debug
            try {
                Add-Content -Path $Global:LogFile -Value $LogMessage -ErrorAction Stop
            } catch {
                $_.Exception.Message
            }
        }}
    }
}
