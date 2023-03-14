
function Start-DotfileCollect {
    <#
    .synopsis
        super rough sketch of automated dotfiles backing up script
    .description
        .
    .example

    .notes
        .
    #>
    param (

    )


    # h1 'Section: Powershell'
    # Start-DotfileCollect
    # h1 'Section: VS Code'
    # h1 'Done'
    Add-DotfilePath 'vscode' 'vscode/.auto_export'

    Get-DotfilePath -All
    Get-DotfilePath 'root'


}
