BeforeAll {
    Import-Module $PSScriptRoot/pslog.psm1 -Force
    if ($Global:LogFile) {
        Remove-Variable LogFile -Scope Global
    }
    if ($Global:LogLevel) {
        Remove-Variable LogLevel -Scope Global
    }
}

Describe "write-pslog with no configurations defined" {
    It "Should throw if no global `$LogFile has been defined." {
       { write-pslog "test" } | Should -Throw "Global variable 'LogFile' does not exist.  Must run set-pslog first!"
    }
}

Describe "set-pslog functionality" {
    It "Should fail to set log file location to inaccessible location" {
        { set-pslog -LogFile "FAKEDIRECTORY/test.txt" } | Should -Throw
    }

    It "Should fail to allow invalid Log Level" {
        { set-pslog -LogLevel "Eror"} | Should -Throw
    }
}
