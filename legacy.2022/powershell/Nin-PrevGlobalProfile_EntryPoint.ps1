
# $p = "$Env:UserProfile\SkyDrive\Documents\2021\dotfiles_git"
# if (Test-Path $P) {
#     . $p
#     return
# }


$p = . (Get-Item -ea stop "${Env:Nin_Dotfiles}\powershell\Nin-CurrentUserAllHosts.ps1")
. $P







<#
- future
- [ ] migrate '㏒' to minimal logging

- ㏒
#>
"$Env:UserProfile\SkyDrive\Documents\2021\dotfiles_git"
Write-Warning 'WARNING: ㏒ [docs/powershell/profile.ps1] -> Nin-CurrentUserAllHosts'
. (Get-Item -ea stop "${Env:Nin_Dotfiles}\powershell\Nin-CurrentUserAllHosts.ps1")


# new: fixes error from vscode's entry point
$Env:PSModulePath = @(
    'C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github\'
    $Env:PSModulePath

) -join ';'
Import-Module ninmonkey.console
Import-Module dev.nin

return
Set-Alias '___addPSModulePath' '___addPSModulePath_old'
function ___addPSModulePath_old {
    # prevents extra whitespace,
    # for example this inserts unwanted whitespace because no join
    # prevents extra space
    param( [string]$InputPath )
    $Env:PSModulePath += @(
        Get-Item $InputPath #always GI ? not?
    ) | Join-String -sep ';' -op ';'

    $InputPath | Join-String -sep ',' -op 'Added Path[s] '
}

function Add-PSModulePath {
    <#
    .synopsis
        wraps some validation when adding to Env:PSModulePath
    .example
        PS> cd 'c:\foo\bar'
        PS> Add-PSModulePath '.'
            Added Path: 'c:\foo\bar'

        PS> Add-PSModulePath 'c:\foo\bar'
            Skipped Path: 'c:\foo\bar' # duplicate

        PS> Add-PSModulePath 'c:\broken\bar'

            Added Path[s] 'c:\broken\bar'' ( does not exist )
    .example
        PS> Add-PSModulePath 'c:\does\not\exist'

            Added Path[s] 'c:\currentPath\stuff' ( does not exist )

        PS> Add-PSModulePath 'c:\does\not\exist' -Strict

            FilepathNotExistingError: 'path does not exist'
    .notes
        Do I care about the parent? if yes, this family: [System.Environment]::ExpandEnvironmentVariables('%PSModulePath%')
    #>
    # [Alias('___addPSModulePath')]
    [cmdletbinding()]
    param(
        # full or relative path, default resolves using 'get-item'
        [Alias('Path')]
        [Parameter(Mandatory, Position = 0)]
        [string]$InputPath,

        # strit requires ppath
        [switch]$Strict
        # [switch]$SkipTestValidPath,
    )
    #   $Env:PSModulePath += #@(
    #        Get-Item $InputPath #always GI ? not?
    #    ) | Join-String -sep ';' -op ';'

    Write-Error 'was wip, not srue if it should be alone or module'
    return

    $sourcePath = Get-Item -ea silentlyContinue $InputPath
    $splat_AddPath = @{
        Separator    = ''
        OutputPrefix = 'Added Path[s] '
    }

    Join-String 'Added Path[s] ' -os $InputPath | Write-Debug
    Join-String 'Added Path[s] ' -os $InputPath | Write-Verbose
    Join-String @splat_AddPath -os $InputPath | Write-Verbose

    if ($Strict) {
        Write-Error

    }


    $curVar = $env:PSModulePath


    Join-String -sep '' -op 'Added Path[s] ' -os $InputPath | Write-Verbose
}

# try {

___addPSModulePath 'G:\2021-github-downloads\dotfiles\SeeminglyScience\PowerShell'

Write-Warning 'WARNING: ㏒ [docs/powershell/profile.ps1] -> seemSci'

$pathSeem = Get-Item 'G:\2021-github-downloads\dotfiles\SeeminglyScience\PowerShell'

if ($pathSeem) {
    # Import-Module pslambda
    Write-Warning $PathSeem
    (Join-Path $PathSeem 'Utility.psm1')
    Import-Module (Get-Item (Join-Path $PathSeem 'Utility.psm1'))
    # Update-TypeData -PrependPath (Join-Path $PathSeem 'profile.types.ps1xml')
    # Update-FormatData -PrependPath (Join-Path $PathSeem 'profile.format.ps1xml')
    # # Import-Module (Join-Path $PathSeem 'Utility.psm1') #-Force
}



# too early, causes error on vscode or missing on vs code
# Import-Module ninmonkey.console
# Import-Module dev.nin

#$Env:PSG:\2021-github-downloads\dotfiles\SeeminglyScience\PowerShell

#'G:\2021-github-downloads\dotfiles\SeeminglyScience\PowerShell'
# $Env:PSModulePath += ';', 'C:\nin_temp' -join ''
# this should be the very first file loaded
#try {


# Import-Module Utility #-ea stop

# Import-Module Dev.Nin
# Import-Module ninmonkey.console

Write-Warning 'WARNING: ㏒ [docs/powershell/profile.ps1]'
# Import-Module Dev.nin ; '㏒: import dev.nin' | write-color magenta | write-warning

$OneDrive ??= @{
    Enable_MyDocsBugMapping = $true
}
# $global:__dupCounter ??= [ordered]@{} # this *should* work
if ($null -eq $global:__dupCounter) {
    $global:__dupCounter = [ordered]@{} # should be redundant
}


# $state[ $Key ] = ( $state[$Key] ?? 0 ) + 1
function __countDuplicateLoad {
    # future: Maybe capture pairs of @{ loadCount; datetime when }
    # doesn't capture scope right IIRC

    param(
        [switch]$List,

        # override auto detected name
        [ALias('Name')]
        [Parameter(Position = 0)]
        [string]$KeyName
    )


    $global:____snap ??= @()
    $global:____snap += @(
        # __captureContext # ask SeeminglyScience how to actually grab context?
    )

    # c-tor
    if ($null -eq $global:__dupCounter) {
        Write-Warning "🦘should never reach '$PSCommandPath'"
        $global:__dupCounter = [ordered]@{}
        $global:__dupCounter['ShouldNever'] = ($global:__dupCounter['ShouldNever'] ?? 0) + 1
    }
    $state = $global:__dupCounter
    [string]$Key = $PSCommandPath # no 'gi' here, for speed

    if ($List) {
        return $state
    }

    if ($null -eq $key) {
        Write-Warning "!!🦘!!should never reach '$PSCommandPath'"
        $key = 'null'
    }

    $Key = $KeyName

    if (! $State.Contains($Key)) {
        $state[$key] = 0
    }

    # if($state.co)
    $Value = $state[$Key]
    $state[ $Key ] = $Value + 1
    # $state[ $Key ] = (  ?? 0 ) + 1
}

# __countDuplicateLoad
# write-warning "㏒ [sky/docs/powershell/Microsoft.VSCode_profile.ps1] -> is NoOp"


#>
if ($true) {
    #$__ninConfig.Import.SeeminglyScience) {
    # refactor: temp test to see if it loads right
    Write-Warning 'WARNING: ㏒ [docs/powershell/profile.ps1] -> seemSci'
    Write-Warning 'WARNING: ㏒ [docs/powershell/profile.ps1] -> seemSci'
    $pathSeem = Get-Item 'G:\2021-github-downloads\dotfiles\SeeminglyScience\PowerShell'
    if ($pathSeem) {
        Import-Module pslambda
        Import-Module (Get-Item -ea stop (Join-Path $PathSeem 'Utility.psm1'))
        Update-TypeData -PrependPath (Join-Path $PathSeem 'profile.types.ps1xml')
        Update-FormatData -PrependPath (Join-Path $PathSeem 'profile.format.ps1xml')
        # Import-Module (Join-Path $PathSeem 'Utility.psm1') #-Force
    }
}

Write-Warning 'WARNING: ㏒ [docs/powershell/profile.ps1] -> Dev.nin'
# Import-Module Dev.nin -ea stop

# '㏒: import dev.nin' | Write-Color magenta | Write-Warning
# Import-Module Dev.Nin

$env:PSModulePath += ';', (Get-Item "$Env:UserProfile\SkyDrive\Documents\PowerShell\Modules" -ea continue) -join ''
if ($OneDrive.Enable_MyDocsBugMapping) {
    $Env:Nin_Dotfiles = "$Env:UserProfile\SkyDrive\Documents\2021\dotfiles_git"
    Write-Warning 'WARNING: ㏒ [docs/powershell/profile.ps1] -> Nin-CurrentUserAllHosts'
    . (Get-Item -ea stop "${Env:Nin_Dotfiles}\powershell\Nin-CurrentUserAllHosts.ps1")
} else {
    # dotsource or symlink
    $Env:Nin_Dotfiles ??= "$Env:UserProfile\Documents\2021\dotfiles_git"
    Write-Warning 'WARNING: ㏒ [docs/powershell/profile.ps1] -> Nin-CurrentUserAllHosts'
    . (Get-Item -ea stop "${Env:Nin_Dotfiles}\powershell\Nin-CurrentUserAllHosts.ps1")
}

# return
if ($false -and $EnableOldGlobal) {
    $___nin_cache ??= @{
        FirstLoad = $true
    }
    $OneDrive ??= @{
        Enable_MyDocsBugMapping = $true

    }

    # $PSDefaultParameterValues['Dev.Nin\_VSCode-VEnv:Write-Information'] = 'Continue'
    # if ($___nin_cache) {
    #     $___nin_cache.FirstLoad = $false
    # }\
    #
    # $__ninConfig['debug'] ??= $__ninConfig['debug'] ?? @{ GlobalWarn = $true }

    $___nin_cache.FirstLoad = $false

}

# } catch {

#     "top level bad: $_"
# }
