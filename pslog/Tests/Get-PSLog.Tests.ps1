BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..' 'pslog.psd1') -Force
}

Describe 'Get-PSLog' {

    BeforeAll {
        $TempRoot = [System.IO.Path]::GetTempPath() 
    }

    AfterAll {
        $null = $TempRoot
    }

    BeforeEach {
        if ($Global:LogFile) {
            Remove-Variable LogFile -Scope Global 
        }
        if ($Global:LogLevel) {
            Remove-Variable LogLevel -Scope Global 
        }
        if ($Global:LogOnly) {
            Remove-Variable LogOnly -Scope Global 
        }
        $null = $TempLog
    }

    AfterEach {
        if ($null -ne $TempLog -and (Test-Path $TempLog)) { 
            Remove-Item $TempLog -Force -ErrorAction SilentlyContinue 
        }

        if ($Global:LogFile) {
            Remove-Variable LogFile -Scope Global
        }
        if ($Global:LogLevel) {
            Remove-Variable LogLevel -Scope Global
        }
        if ($Global:LogOnly) {
            Remove-Variable LogOnly -Scope Global 
        }
        $null = $TempLog
    }

    It 'reports LogOnly when the switch is set' {
        Set-PSLog -LogOnly
        $res = Get-PSLog
        $res.LogOnly | Should -BeTrue
    }

    It 'reports the current global LogFile and LogLevel' {
        $TempLog = Join-Path -Path $TempRoot -ChildPath "pslog_test_$((Get-Date).ToFileTime()).log"
        Set-PSLog -LogFile $TempLog -LogLevel Information
        $res = Get-PSLog
        $res.LogFile | Should -Be $TempLog
        $res.LogLevel | Should -Be 2
    }

    It 'reports nulls/defaults when no globals are set' {
        $res = Get-PSLog
        $res.LogFile | Should -BeNullOrEmpty
        $res.LogLevel | Should -BeNullOrEmpty
        $res.LogOnly | Should -BeFalse
    }

    It 'is safe to call when no globals are set' {
        $null = Get-PSLog
        # should not throw
    }

    It 'is safe to call when only one global is set' {
        Set-PSLog -LogLevel Warning
        $null = Get-PSLog
        Remove-Variable LogLevel -Scope Global

        $TempLog = Join-Path -Path $TempRoot -ChildPath "pslog_test_$((Get-Date).ToFileTime()).log"
        Set-PSLog -LogFile $TempLog
        $null = Get-PSLog
    }

    It 'returns a PSCustomObject with the expected properties' {
        $res = Get-PSLog
        $res | Should -BeOfType 'System.Management.Automation.PSCustomObject'
        $res.PSObject.Properties.Name | Should -Contain 'LogFile'
        $res.PSObject.Properties.Name | Should -Contain 'LogLevel'
        $res.PSObject.Properties.Name | Should -Contain 'LogOnly'
    }

    It 'works correctly when LogOnly is set without LogFile or LogLevel' {
        Set-PSLog -LogOnly
        $res = Get-PSLog
        $res.LogOnly | Should -BeTrue
        $res.LogFile | Should -BeNullOrEmpty
        $res.LogLevel | Should -BeNullOrEmpty
    }

}
