Write-Warning 'WARNING: ㏒ [CollectDotfiles.original.psm1]'
<#
    section: Private
#>
$private = @(
    'module_variables'
)

foreach ($file in $private) {
    if (Test-Path ("{0}\private\{1}.ps1" -f $psscriptroot, $file)) {
    } else {
        Write-Error "Import: private: failed: private: $File"
    }
    . ("{0}\private\{1}.ps1" -f $psscriptroot, $file)
}

$public = @(
    # misc
    'Get-DotfilePath'
    'Add-DotfilePath'
    'New-DotfilePathRecord'
    'Start-DotfileCollect'
    'Set-DotfileRoot'
    'Reset-DotfilePath'
)

<#
    section: public
#>
foreach ($file in $public) {
    if (Test-Path ("{0}\public\{1}.ps1" -f $psscriptroot, $file)) {
    } else {
        Write-Error "Import: failed: public: $File"
    }
    . ("{0}\public\{1}.ps1" -f $psscriptroot, $file)
}

$functionsToExport = @(
    'Get-DotfilePath'
    'Add-DotfilePath'
    'New-DotfilePathRecord'
    'Start-DotfileCollect'
    'Set-DotfileRoot'
    'Reset-DotfilePath'
)
Export-ModuleMember -Function $functionsToExport

$aliasesToExport = @(

)
Export-ModuleMember -Alias $aliasesToExport
