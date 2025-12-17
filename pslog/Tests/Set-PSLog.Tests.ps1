BeforeAll {
    # Use nested Join-Path for PowerShell 5 compatibility
    Import-Module (Join-Path (Join-Path $PSScriptRoot '..') 'pslog.psd1') -Force
}

Describe "Set-PSLog" {

    $null = $TempLog

    BeforeEach {
        if ($Global:LogFile) {
            Remove-Variable LogFile -Scope Global
        }
        if ($Global:LogLevel) {
            Remove-Variable LogLevel -Scope Global
        }
        
        $null = $TempLog
    }

    AfterEach {
        if ($Global:LogFile) {
            Remove-Variable LogFile -Scope Global
        }
        if ($Global:LogLevel) {
            Remove-Variable LogLevel -Scope Global
        }

        $null = $TempLog
    }


    It "Should fail to set log file location to inaccessible location" {
        $TempLog = $([System.IO.Path]::GetTempPath()) | Join-Path -Child $(Get-Random) | Join-Path -Child $("pslog_test_$((Get-Date).ToFileTime()).log")
        { Set-PSLog -LogFile $TempLog } | Should -Throw
    }

    It "Should fail to allow invalid Log Level" {
        { Set-PSLog -LogLevel "Eror"} | Should -Throw
    }

    It "Should allow LogFile global variable to be set" {
        $TempRoot = $env:TEMP 
        
        if (-not $TempRoot) {
            $TempRoot = [System.IO.Path]::GetTempPath() 
        }

        $TempLog = Join-Path -Path $TempRoot -ChildPath "pslog_test_$((Get-Date).ToFileTime()).log"
        Set-PSLog -LogFile $TempLog

        $Global:LogFile | Should -Be $TempLog
    }

    It "Should allow LogLevel global variable to be set" {
        Set-PSLog -LogLevel Verbose

        $Global:LogLevel | Should -Be 3
    }

    It "Should allow both LogLevel and LogFile global variable to be set" {
        $TempRoot = $env:TEMP 
        
        if (-not $TempRoot) {
            $TempRoot = [System.IO.Path]::GetTempPath() 
        }

        $TempLog = Join-Path -Path $TempRoot -ChildPath "pslog_test_$((Get-Date).ToFileTime()).log"
        Set-PSLog -LogLevel Verbose -LogFile $TempLog

        $Global:LogLevel | Should -Be 3
        $Global:LogFile | Should -Be $TempLog
    }

    It 'should set LogOnly when the switch is passed' {
        Set-PSLog -LogOnly
        $Global:LogOnly | Should -BeTrue
        # clear for other tests
        Remove-Variable -Name LogOnly -Scope Global -ErrorAction SilentlyContinue
    }
}
