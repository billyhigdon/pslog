function set-pslog {
    [CmdletBinding()]
    param (
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
        Write-Output "`$Global:LogFile not set"
    }

    try {
        Get-Variable LogLevel -ErrorAction Stop
    } catch {
        Write-Output "`$Global:LogLevel not set"
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
<#
[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
[Alias('DisplayName','Name')]
[string[]]$Message
)

#>
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

        if (!(Test-Path $Global:LogFile)) {

        try {
            New-Item $Global:LogFile -Force -ErrorAction Stop | Out-Null
        } catch {
            $_.Exception.Message
        }
    }

    #$test = @($Message | ForEach-Object {$_}).count
    $test = $Message | fl

    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "$TimeStamp [$($OutStream.ToLower())] $test"
    #$LogMessage = "$TimeStamp [$($OutStream.ToLower())] $Message"
    
    # $requestedLogLevel = [LogLevels]$OutStream


    if($Global:LogLevel -gt $LogLevels[$OutStream]) {
        & "Write-${OutStream}" $LogMessage
        try {
            Add-Content -Path $Global:LogFile -Value $LogMessage -ErrorAction Stop 
        } catch {
            $_.Exception.Message
        }
    }
}
