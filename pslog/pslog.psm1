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
        [ValidateSet("Error","Warning","Information","Verbose","Debug")]
        [string]$OutStream = "Information",

        [Parameter(Mandatory,ValueFromPipeline)]
        [psobject[]]$Message
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
        try {            
            set-pslog -LogFile "$home/pslog_$(get-date -Format FileDateTime)"
        } catch {
            throw "Global logfile location undefined.  Failed to set default at `$home"
        }
    }
        
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"


    if (!$Global:LogLevel) {
        set-pslog -LogLevel Information
    }

    if($Global:LogLevel -gt $LogLevels[$OutStream]) {
        try {
            if ($Message.count -gt 1) {
                $Message = $Message | Out-String
                # This doesn't work if I 'WRite-Infomration' - tech debt
                Write-Output $Message
                Add-Content -Path $Global:LogFile -Value "$TimeStamp [$($OutStream.ToLower())]" -ErrorAction Stop 
                Add-Content -Path $Global:LogFile -Value "$Message" -ErrorAction Stop 
            } else {

                & "Write-${OutStream}" $Message
                Add-Content -Path $Global:LogFile -Value "$TimeStamp [$($OutStream.ToLower())] $Message" -ErrorAction Stop 
            }
        } catch {
            $_.Exception.Message
        }
    }
}
