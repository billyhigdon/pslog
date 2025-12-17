<#
Module loader for pslog

This file dot-sources all function scripts under the `Functions` directory and
exports the public functions. Implementation details live in `Functions/*.ps1`.
#>

# Use $PSScriptRoot to locate module files
$Script:ModuleRoot = $PSScriptRoot

# Dot-source all functions
Get-ChildItem -Path (Join-Path $Script:ModuleRoot 'Functions') -Filter '*.ps1' -File | ForEach-Object {
    . $_.FullName
}

# Optionally dot-source private helpers if you add them later
if (Test-Path (Join-Path $Script:ModuleRoot 'Private')) {
    Get-ChildItem -Path (Join-Path $Script:ModuleRoot 'Private') -Filter '*.ps1' -File | ForEach-Object {
        . $_.FullName
    }
}

# Explicitly export the public functions (also listed in the manifest)
Export-ModuleMember -Function 'Get-PSLog','Set-PSLog','Write-PSLog','Remove-PSLog'

