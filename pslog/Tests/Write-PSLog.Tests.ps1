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

    It 'when LogOnly is set, suppresses console output but still writes to logfile' {
        $TempLog = Join-Path -Path $TempRoot -ChildPath "pslog_logonly_$((Get-Date).ToFileTime()).log"
        Set-PSLog -LogFile $TempLog -LogLevel Information -LogOnly

        # capture warning and information streams
        $null = 'info1' | Write-PSLog -OutStream Information -InformationVariable infos -InformationAction SilentlyContinue
        ($infos) | Should -BeNullOrEmpty

        $null = 'warn1' | Write-PSLog -OutStream Warning -WarningVariable warns -WarningAction SilentlyContinue
        ($warns) | Should -BeNullOrEmpty

        # the file should still contain the entries
        Test-Path $TempLog | Should -BeTrue
        (Get-Content $TempLog -Raw) | Should -Match 'info1'
        (Get-Content $TempLog -Raw) | Should -Match 'warn1'
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

    It 'handles enumerable messages correctly' {
        $TempLog = Join-Path -Path $TempRoot -ChildPath "pslog_test_$((Get-Date).ToFileTime()).log"
        Set-PSLog -LogFile $TempLog -LogLevel Information

        @('lineA','lineB','lineC') | Write-PSLog -OutStream Information

        (Get-Content $TempLog).Count | Should -Be 3
    }

    It 'handles null message input without error' {
        $TempLog = Join-Path -Path $TempRoot -ChildPath "pslog_test_$((Get-Date).ToFileTime()).log"
        Set-PSLog -LogFile $TempLog -LogLevel Information

        { $null | Write-PSLog -OutStream Information } | Should -Not -Throw

        # when the only pipeline input is $null, it should still be written and the logfile created
        Test-Path $TempLog | Should -BeTrue
        (Get-Content $TempLog).Count | Should -Be 1
        (Get-Content $TempLog -Raw) | Should -Match '\[information\]'
    }

}
