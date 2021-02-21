Import-Module -Verbose -Force "$PSScriptRoot/powershell/collect_dotfiles/CollectDotfiles.psd1"
# now: Simply invoke module / and / or configure
h1 'collect_dotfiles.ps1'
# Set-DotfileRoot $PSScriptRoot -Verbose # or '.' ?
Set-DotfileRoot '.'

h1 'config'

Add-DotfilePath 'vscode-snippets' 'vscode/.auto_export/snippets'

h1 'ListAll'
Get-DotfilePath -ListAll