Import-Module -Verbose -Force "$PSScriptRoot/powershell/collect_dotfiles/CollectDotfiles.psd1"
# now: Simply invoke module / and / or configure
h1 'collect_dotfiles.ps1'

h1 'config'

Get-DotfilePath -ListAll | ForEach-Object getenumerator
| ForEach-Object value | Format-HashTable -Title 'item' #SingleLine
