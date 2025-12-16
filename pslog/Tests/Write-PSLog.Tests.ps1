BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..' 'pslog.psd1') -Force
}

Describe 'Write-PSLog' {

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

    It 'sets a default LogLevel when LogLevel is unset' {
        "testmessage" | Write-PSLog -OutStream Information

        $Global:LogLevel | Should -Not -BeNullOrEmpty
    }

    It 'writes pipeline messages to the configured log file' {

        $TempLog = Join-Path -Path $TempRoot -ChildPath "pslog_test_$((Get-Date).ToFileTime()).log"
        Set-PSLog -LogFile $TempLog -LogLevel Information

        'line1','line2' | Write-PSLog -OutStream Information

        Test-Path $TempLog | Should -BeTrue
        (Get-Content $TempLog -Raw) | Should -Match 'line1'
        (Get-Content $TempLog -Raw) | Should -Match 'line2'
    }

    It 'emits a warning when OutStream is Warning' {
        $null = 'warnme' | Write-PSLog -OutStream Warning -WarningVariable warn -WarningAction SilentlyContinue
        ($warn.Count) | Should -BeGreaterThan 0
    }

    It 'processes each pipeline input as a separate write' {

        $TempLog = Join-Path -Path $TempRoot -ChildPath "pslog_test_$((Get-Date).ToFileTime()).log"
        Set-PSLog -LogFile $TempLog -LogLevel Debug

        1..3 | ForEach-Object { "msg$_" } | Write-PSLog -OutStream Information

        (Get-Content $TempLog).Count | Should -Be 3
    }

    It 'respects log level threshold' {
        $TempLog = Join-Path -Path $TempRoot -ChildPath "pslog_test_$((Get-Date).ToFileTime()).log"
        Set-PSLog -LogFile $TempLog -LogLevel Warning
        'info' | Write-PSLog -OutStream Information
        Test-Path $TempLog | Should -BeFalse
        'warn' | Write-PSLog -OutStream Warning
        (Get-Content $TempLog) | Should -Match 'warn'
    }

    It 'creates default logfile when none set' {
        'hi' | Write-PSLog -OutStream Information
        $Global:LogFile | Should -Not -BeNullOrEmpty
        Test-Path $Global:LogFile | Should -BeTrue
}


}
