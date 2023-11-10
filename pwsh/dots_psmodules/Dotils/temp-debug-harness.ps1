import-module Dotils -PassThru
function dbg.Get-FunctionInfo { # to implement: 2023-10-02
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject
    )
    $resolveCommand = $InputObject | Resolve.Command
    $t = $resolveCommand # target
    $resolveAst = $t.ScriptBlock.Ast
    # $resolveAst =
    $meta = [ordered]@{
        PSTypeName = 'dotils.dbg.Get-FunctionInfo.'
        Type = $t | Format-ShortTypeName
        RawObj = $InputObject
        RawType  = $InputObject | Format-ShortTypeName
    }
    [pscustomobject]$Meta
}

@(
    'label' | dbg.Get-FunctionInfo
    'Join.UL' | Resolve.Command | dbg.Get-FunctionInfo
) | Ft

$TestIt = @{
    ThreeTo_FuncInfoDirect = $false
    ThreeTo_ResolveAst = $true
}
$defVerb = @{ Verbose = $true; Debug = $true }
if($testIt.ThreeTo_FuncInfoDirect ) {
    h1 'as SB'
    $t = Resolve.Command 'label'
    $t.ScriptBlock | dbg.Get-FunctionInfo

    h1 'as Ast'
    $t.ScriptBlock.Ast | dbg.Get-FunctionInfo

    h1 'as Object'
    $t | dbg.Get-FunctionInfo
}
$PSDefaultParameterValues['Dotils.Resolve.Ast:Verbose'] = $True
$PSDefaultParameterValues['Dotils.Resolve.Ast:Debug'] = $True
# $ErrorActionPreference = 'break'
if($testIt.ThreeTo_ResolveAst ) {
    h1 'as SB'
    $t = Resolve.Command 'label'
    $t.ScriptBlock | Dotils.Resolve.Ast

    h1 'as Ast'
    $t.ScriptBlock.Ast | Dotils.Resolve.Ast

    h1 'as Object'
    $t | Dotils.Resolve.Ast -ea 'ignore'
}
# $ErrorActionPreference = 'continue'

$TestIt | ft -AutoSize