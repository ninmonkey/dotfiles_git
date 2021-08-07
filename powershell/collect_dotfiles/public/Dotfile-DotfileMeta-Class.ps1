class DotfileMeta {
    [string]$Label
    [string]$Path
    [string[]]$Tag
    <#
    file verses directory ?
    include children logic?
    #>

    DotfileMeta([string]$Label, [string]$Path, [string[]]$Tag) {
        $this.Label = $Label
        $this.Path = $Path
        $this.Tag = $Tag
    }

    [string]ToString() {
        return ('{0}|{1}|{2}' -f $this.Label, $this.Path, $this.Tags)
    }
}

<#
    section: Private
#>
$_collectConfig = @{

}

$splat_Optional = @{
    ErrorAction = 'stop'
}

$_dotfiles = @{}
# $_dotfiles = @{



function Add-DotfileAlias {
    <#
    .synopsis
        maps keys (string) to filepaths
    .description
        .
    .example

    .notes

    #>
    param (
        # Docstring
        [Parameter(Mandatory, Position = 0)]
        [object]$ParameterName
    )
    begin {}
    process {}
    end {}
}
$Plist.User_Code = Get-Item @splat_Optional -Path "$env:AppData\Code\User"
$Plist.User_CodeInsider = Get-Item @splat_Optional "$env:AppData\Code - Insiders\User"
$Plist.Dot_Code = Get-Item @splat_Optional "$Env:Nin_Dotfiles\vscode\User\nin10\Code"

$Plist.User_Code = Get-Item @splat_Optional "$env:AppData\Code\User"
$Plist.User_CodeInsider = Get-Item @splat_Optional "$env:AppData\Code - Insiders\User"
$Plist.Home_Code = Get-Item @splat_Optional "$Env:Nin_Dotfiles\vscode\User\nin10\Code"
$Plist.Home_CodeInsider = Get-Item @splat_Optional "$Env:Nin_Dotfiles\vscode\User\nin10\Code - Insiders"
