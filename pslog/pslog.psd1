@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'pslog.psm1'

    # Version number of this module.
    ModuleVersion     = '1.0.0'

    # ID used to uniquely identify this module
    GUID              = 'd1a8b2c6-8f6a-4a69-9c76-3e8e2d6a4f12'

    # Author of this module
    Author            = 'billyhigdon'

    # Company or vendor of this module
    CompanyName       = 'billyhigdon'

    Copyright         = '(c) 2025 billyhigdon'

    # Description of the functionality provided by this module
    Description       = 'pslog: simple logging utilities for PowerShell'

    # Functions to export from this module. Keep this list explicit to avoid exporting internals.
    FunctionsToExport = @(
        'Get-PSLog',
        'Set-PSLog',
        'Write-PSLog',
        'Remove-PSLog'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData       = @{
        PSData = @{
            # Tags applied to this module
            Tags = @('Logging', 'Utilities')
        }
    }

}
