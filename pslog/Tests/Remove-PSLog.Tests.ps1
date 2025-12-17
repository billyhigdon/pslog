BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..' 'pslog.psd1') -Force
}

Describe 'Remove-PSLog' {

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
    }

    AfterEach {
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

    It 'removes global variables that were set and returns their previous values' {
        $TempLog = Join-Path -Path $TempRoot -ChildPath "pslog_test_$((Get-Date).ToFileTime()).log"
        Set-PSLog -LogFile $TempLog -LogLevel Verbose -LogOnly

        $res = Remove-PSLog

        $res.LogFile | Should -Be $TempLog
        $res.LogLevel | Should -Be 3
        $res.LogOnly | Should -BeTrue

        # ensure they were actually removed
        (Get-Variable -Name LogFile -Scope Global -ErrorAction SilentlyContinue) | Should -BeNullOrEmpty
        (Get-Variable -Name LogLevel -Scope Global -ErrorAction SilentlyContinue) | Should -BeNullOrEmpty
        (Get-Variable -Name LogOnly -Scope Global -ErrorAction SilentlyContinue) | Should -BeNullOrEmpty
    }

    It 'is safe to call when no globals are set' {
        $null = Remove-PSLog
        # should not throw and should return nulls/defaults
        $res = Remove-PSLog
        $res.LogFile | Should -BeNullOrEmpty
        $res.LogLevel | Should -BeNullOrEmpty
        $res.LogOnly | Should -BeFalse
    }

}
