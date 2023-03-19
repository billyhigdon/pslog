function set-pslog {
    [CmdletBinding()]
    param (
        [ValidateScript({Test-Path (Split-Path -Parent $_)})]
        [string]$LogFile,

        [ValidateSet("Error","Warning","Information","Verbose","Debug")]
        [string]$LogLevel
    )
    
    if ($LogFile) {
        $Global:LogFile = $LogFile
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

function write-pslog {
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [psobject[]]$Message,

        [ValidateSet("Error","Warning","Information","Verbose","Debug")]
        [string]$OutStream = "Information"
    )

    $VerbosePreference="Continue"
    $InformationPreference="Continue"
    $DebugPreference="Continue"

    $LogLevels = @{
        Error       = 0
        Warning     = 1
        Information = 2
        Verbose     = 3
        Debug       = 4
    }

    try {
        if (!(Test-Path $Global:LogFile -ErrorAction Stop)) {
            try {
                New-Item $Global:LogFile -Force -ErrorAction Stop | Out-Null
            } catch {
                $_.Exception.Message
            }
        }
    } catch {
        throw "Global variable 'LogFile' does not exist.  Must run set-pslog first!"
    }
        
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "$TimeStamp [$($OutStream.ToLower())] $Message"

    if($Global:LogLevel -gt $LogLevels[$OutStream]) {
        & "Write-${OutStream}" $LogMessage
        try {
            Add-Content -Path $Global:LogFile -Value $LogMessage -ErrorAction Stop 
        } catch {
            $_.Exception.Message
        }
    }
}
