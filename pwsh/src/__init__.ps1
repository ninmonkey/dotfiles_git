[Console]::OutputEncoding = [Console]::InputEncoding = $OutputEncoding = [System.Text.UTF8Encoding]::new()
Import-Module Pansies
[PoshCode.Pansies.RgbColor]::ColorMode = 'Rgb24Bit'
[Console]::OutputEncoding | Join-String -op 'Console::OutputEncoding ' | Write-Verbose
$PSStyle.OutputRendering = 'ansi'

$base = Get-Item $PSScriptRoot
. (Get-Item -ea 'stop' (Join-Path $Base 'Build-ProfileCustomMembers.ps1'))
. (Get-Item -ea 'stop' (Join-Path $Base 'Invoke-MinimalInit.ps1'))



# important, the other syntax for UTF8 defaults to UTF8+BOM which
# breaks piping, like piping returning from FZF contains a BOM
# which actually causes a full exception when it's piped to Get-Item
#
# test:  Is the default Ctor the non-bom one?


Set-PSReadLineKeyHandler -Chord 'alt+enter' -Function AddLine