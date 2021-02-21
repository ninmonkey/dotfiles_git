<#
    section: Private
#>
$private = @(
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
    # console formatting
    'Get-DotfilePath'
    'Add-DotfilePath'


)
Export-ModuleMember -Function $functionsToExport

$aliasesToExport = @(

)
Export-ModuleMember -Alias $aliasesToExport
