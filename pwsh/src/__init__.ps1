if($global:__nin_enableTraceVerbosity) { "⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; }[Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>
$PSStyle.OutputRendering = [Management.Automation.OutputRendering]::Ansi # wip dev,nin: todo:2022-03 # Keep colors when piping Pwsh in 7.2

[Console]::OutputEncoding = [Console]::InputEncoding = $OutputEncoding = [System.Text.UTF8Encoding]::new()

'Encoding: [Console Input/Output: {0}, {1}, $OutputEncoding: {2}]' -f @(
    # alternate:  @( [Console]::OutputEncoding, [Console]::InputEncoding, $OutputEncoding ) -replace 'System.Text', ''
    @(  [Console]::OutputEncoding, [Console]::InputEncoding, $OutputEncoding | ForEach-Object WebName )
) | Write-Verbose -Verbose

$base = Get-Item $PSScriptRoot
. (Get-Item -ea 'continue' (Join-Path $Base 'Build-ProfileCustomMembers.ps1'))
. (Get-Item -ea 'continue' (Join-Path $Base 'Invoke-MinimalInit.ps1'))
. (Get-Item -ea 'continue' (Join-Path $Base 'autoloadNow_butRefactor.ps1'))


Import-Module 'Pansies'
[PoshCode.Pansies.RgbColor]::ColorMode = 'Rgb24Bit'


# important, the other syntax for UTF8 defaults to UTF8+BOM which
# breaks piping, like piping returning from FZF contains a BOM
# which actually causes a full exception when it's piped to Get-Item
#
# test:  Is the default Ctor the non-bom one?


Set-PSReadLineKeyHandler -Chord 'alt+enter' -Function AddLine

if($global:__nin_enableTraceVerbosity) { "⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`"" | Write-Warning; } [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>