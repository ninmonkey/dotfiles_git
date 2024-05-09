@'





2023-10-31

## grab some

- [ ] style question: <H:\data\2023\pwsh\topost - example formatting comparisons.md>

- [ ] <C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Microsoft.VSCode_profile.ps1>
    - clean up import order
- [ ] <H:\data\2023\web.js\web.js - sketch 2023-09\pwsh\FindFiles.ps1>
- [ ] <H:\data\2023\dotfiles.2023\pwsh\src\__init__.ps1>
- [ ] <H:\data\2023\web.js\QuickRefs\structureSketch\src\QuickRefs.Md\QuickRefs.Md.psm1>
- [ ] <H:\data\2023\dotfiles.2023\pwsh\disabled.Microsoft.PowerShell_profile.ps1>
    - promptForScreenshot, etc

- [ ] <H:\data\2023\dotfiles.2023\pwsh\profile.ps1>
    - move to dotils

- [ ] <H:\data\2023\dotfiles.2023\pwsh\profile-save-snippets-but-disabled-from-autorun.ps1>
    - maybe some not yet saved funcs

- [ ] <C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\profile.ps1>
    - extract any wanted imports

- [ ] <C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Microsoft.VSCode_profile.ps1>
'@

$array = @(1,2,3,4,5)
$allEvenValues = [array]::FindAll($array, [Predicate[int]]{param($v) $v % 2 -eq 0})
$array -join ', '
$allEvenValues -join ', '
hr

filter .fmtx { $_ -as 'int' | % tostring x }



throw 'scratch belolow'

$name = 'bob'; $name = $Null
$username = 'jen'
   -not [string]::IsNullOrEmpty( $Name ) ? $Name : $null ??
   -not [string]::IsNullOrEmpty( $username ) ? $username : $null ?? 'ShouldNeverReachIfValidated'

   $resolvedName =
      ( [string]::IsNullOrEmpty( $Name )     ? $null : $Name )     ??
      ( [string]::IsNullOrEmpty( $userName ) ? $Null : $userName ) ?? 'ShouldNeverReachIfValidated'

   $resolvedName =
      ( [string]::IsNullOrEmpty( $Name )     ? $null : $Name )     ??
      ( [string]::IsNullOrEmpty( $userName ) ? $Null : $userName ) ?? 'ShouldNeverReachIfValidated'


<# super text
'123456789' -replace '[1-3]', {
    param($m)
    return '-'
}
return

function N2Supc {
    param(
        [ValidateRange(0,9)][int]$N
    )
    "`u{2070}$N"
}
@(
    'there are '
    (N2Supc 3)
    2354
    ' thing[s]'
) | Join-String


return
function .fmt.Super {
    param( [int]$N )
    if( $N -lt 0 -or $N -gt 9 ) { return }

    # [Text.Rune]::new( 0x2070 + $N ) # for PS7
    if($)
    [Char]::ConvertFromUtf32( 0x2070 + $n ) # for PS5
}

0..100 | %{
   .fmt.Super $_
} | Join-String -sep ''
#>

<#
wrap binary

function doStuff0 {

    # [Alias('gh')]
    param(

    )
    dynamicParam {
        $baseCommand =
        if (-not $script:gh) {
            $script:gh =
            $executionContext.SessionState.InvokeCommand.GetCommand('gh', 'Application')
            $script:gh
        }
        else {
            $script:gh
        }
        $IncludeParameter = @()
        $ExcludeParameter = @()

    }
    begin {
        'ABOUT TO CALL GH'
        gh repo list
    }
    end {
        'JUST CALLED GH'
    }
}

doStuff0 'foo'

#>