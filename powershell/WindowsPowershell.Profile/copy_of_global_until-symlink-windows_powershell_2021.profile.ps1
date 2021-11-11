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
$__warn = $false
function Warn {
    [cmdletbinding()]
    [Alias('Warn🛑')]
    param(
        [AllowEmptyCollection()]
        [AllowNull()]
        [Alias('Message', 'Warn')]
        [Parameter(Position = 0, ValueFromPipeline)]
        [object]$InputObject
    )
    process {
        # if (! $__ninConfig.debug.GlobalWarn) {
        if ($null -eq $InputObject) {
            return
        }
        if ($__ninConfig.debug.GlobalWarn ?? $__warn) {
            if ($InputObject) {
                $InputText | Write-Warning        
            }
            return 
        }
    }
}
Warn🛑 "run --->>>> '$PSCommandPath'"

# if ($__ninConfig.debug.GlobalWarn) {
Warn🛑 "run --->>>> '$PSCommandPath' :: 1"
"First? '{0}'" -f @(
    $($___nin_cache)?.FirstLoad ?? '$null' ) | Warn🛑
    
if (! $___nin_cache.FirstLoad ) {
    Warn🛑 'ALREADY LOADED.....'
    # return
    Warn🛑 '     (currently enabling continuation anyway)'
}
# }

Warn🛑 "run --->>>> '$PSCommandPath' :: 2"
## first load stuff
# $env:PSModulePath += ';', (Get-Item 'C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell' )
# $env:PSModulePath += ';', (gi 'C:\Users\cppmo_000\SkyDrive\Documents\2021')
$env:PSModulePath += ';', (Get-Item 'C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Modules')

Warn🛑 "run --->>>> '$PSCommandPath' :: 3"


if ($OneDrive.Enable_MyDocsBugMapping) {
    $Env:Nin_Dotfiles = "$Env:UserProfile\SkyDrive\Documents\2021\dotfiles_git"
    . (Get-Item -ea stop "${Env:Nin_Dotfiles}\powershell\Nin-CurrentUserAllHosts.ps1")
    # C:\Users\cppmo_000\Documents\2021\dotfiles_git\powershell\Nin-CurrentUserAllHosts.ps1
    Warn🛑 'OneDrive: MyDocsBugMapping: Enabled.'
} else {
    # dotsource or symlink
    $Env:Nin_Dotfiles ??= "$Env:UserProfile\Documents\2021\dotfiles_git"
    . (Get-Item -ea stop "${Env:Nin_Dotfiles}\powershell\Nin-CurrentUserAllHosts.ps1")
}

Import-Module dev.nin # no?

Warn🛑 "run --->>>> '$PSCommandPath' :: 4"
$___nin_cache.FirstLoad
| Join-String -op 'FirstRun? '
# |  write-color darkgreen
| Warn🛑

$___nin_cache.FirstLoad = $false
