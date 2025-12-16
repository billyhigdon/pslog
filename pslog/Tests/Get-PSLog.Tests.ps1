BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..' 'pslog.psd1') -Force
}

Describe 'Get-PSLog' {

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
        if ($null -ne $TempLog -and (Test-Path $TempLog)) { 
            Remove-Item $TempLog -Force -ErrorAction SilentlyContinue 
        }

        if ($Global:LogFile) {
            Remove-Variable LogFile -Scope Global
        }
        if ($Global:LogLevel) {
            Remove-Variable LogLevel -Scope Global
        }
        $null = $TempLog
    }

    It 'writes warnings when LogFile and LogLevel are not set' {
        $null = Get-PSLog -WarningVariable warn -WarningAction SilentlyContinue
        ($warn.Count) | Should -Be 2
    }

    It 'does not write warnings when LogFile and LogLevel are set' {
        $TempRoot = $env:TEMP 
        
        if (-not $TempRoot) {
            $TempRoot = [System.IO.Path]::GetTempPath() 
        }

        $TempLog = Join-Path -Path $TempRoot -ChildPath "pslog_test_$((Get-Date).ToFileTime()).log"
        Set-PSLog -LogFile $TempLog -LogLevel Information

        $null = Get-PSLog -WarningVariable warn -WarningAction SilentlyContinue
        ($warn) | Should -BeNullOrEmpty
    }

}
