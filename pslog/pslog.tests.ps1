BeforeAll {
    Import-Module $PSScriptRoot/pslog.psm1 -Force
    if ($Global:LogFile) {
        Remove-Variable LogFile -Scope Global
    }
    if ($Global:LogLevel) {
        Remove-Variable LogLevel -Scope Global
    }
}

Describe "set-pslog functionality" {
    It "Should fail to set log file location to inaccessible location" {
        { set-pslog -LogFile "FAKEDIRECTORY/test.txt" } | Should -Throw
    }

    It "Should fail to allow invalid Log Level" {
        { set-pslog -LogLevel "Eror"} | Should -Throw
    }

    It "Should allow LogFile global variable to be set" {
        set-pslog -LogFile "$home/test-log-file.log"
        $Global:LogFile | Should -Be "$home/test-log-file.log"
    }

    It "Should allow LogLevel global variable to be set" {
        set-pslog -LogLevel Verbose
        $Global:LogLevel | Should -Be "4"
    }

    It "Should allow both LogLevel and LogFile global variable to be set" {
        set-pslog -LogLevel Verbose -LogFile "$home/test-log-file.log"
        $Global:LogLevel | Should -Be "4"
        $Global:LogFile | Should -Be "$home/test-log-file.log"
    }

    AfterEach {
        if ($Global:LogFile) {
            Remove-Variable LogFile -Scope Global
        }
        if ($Global:LogLevel) {
            Remove-Variable LogLevel -Scope Global
        }
    }
}
