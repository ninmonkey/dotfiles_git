$impo_list = @(
    Impo Posh -PassThru
    Impo Dotils -force -PassThru -ea 'stop'
    Impo Nin.Posh -ea 'stop' -PassThru -Force
)
h1 'render1'
$impo_list
    | Join-String -prop {
        $_.Version, $_.Name
            | New-Text -fg 'gray60' -bg 'gray35'
            | Join-String -sep ' '
            | join.UL -Options @{ ULHeader =  @( (hr 1) ; Label "Import" $_.Name  ) | Join-String ; ULFooter  = (hr 0); }
    }

$propNames = @{
    CommandInfo = @(
    'SessionStateEntryVisibility', 'CommandType', 'Name', 'Definition', 'DisplayName', 'ModuleName', 'Module', 'ReferencedCommand', 'ResolvedCommand', 'ResolveCommandName', 'Source', 'Version', 'Visiblity'
    )

}


function Describe.Module {
    param(
        [Parameter(ValueFromPipeline)]
        [System.Management.Automation.PSModuleInfo]
        $Module
    )
    process {
        $Module | Select-Object Name, Version, Description

    }
}

h1 'describe'
$impo_list
| Describe.Module

h1 'group by query'
$query ??= [Ordered]@{
    All = @( Gcm -m 'Dotils'  )
}
$query.Is = @(
    # $query.All | ?
)
PropDump =
$Pkg =
    $query.All
    | Export-Excel -wo 'All' -PassThru -TableStyle Light1 -Title 'all'

$Pkg =
    $query.All
    | Select -Prop $propNames.CommandInfo
    | Export-Excel -wo 'All' -ExcelPackage $Pkg -PassThru -TableStyle Light1 -Title 'all'

Close-ExcelPackage -ExcelPackage $Pkg -show -SaveAs 

$x | Select @selectSplat
<#
example

Name                Reported                                                                       Value
----                --------                                                                       -----
CommandType         [CommandTypes]                                                                 Alias
Definition          [string]                                                            Dotils.Iter.Prop
DisplayName         [object]                                              .Iter.Prop -> Dotils.Iter.Prop
Module              [PSModuleInfo]                                                                dotils
ModuleName          [string]                                                                      dotils
Name                [string]                                                                  .Iter.Prop
Options             [ScopedItemOptions]                                                             None
OutputType          [ReadOnlyCollection<PSTypeName>]        …tion[Management.Automation.PSPropertyInfo]}
Parameters          [Dictionary<string, ParameterMetadata>] ….Management.Automation.ParameterMetadata]…}
ReferencedCommand   [CommandInfo]                                                       Dotils.Iter.Prop
RemotingCapability  [RemotingCapability]                                                      PowerShell
ResolvedCommand     [CommandInfo]                                                       Dotils.Iter.Prop
ResolvedCommandName [object]                                                            Dotils.Iter.Prop
Source              [string]                                                                      dotils
Version             [Version]                                                                        0.0
Visibility          [SessionStateEntryVisibility]                                                 Public

#>

$impo_list
    | Join-String -prop {
        $Name, $Version = $_.Name, $_.Version



        $_.Version, $_.Name
            | New-Text -fg 'gray60' -bg 'gray35'
            | Join-String -sep ' '
            | join.UL -Options @{ ULHeader =  @( (hr 1) ; Label $Name $Version ) | Join-String ; ULFooter  = (hr 0); }
    }
# | Join-String -f "`n    => " -P { $_.Name, $_.Version -join ': '}


# 0..4 | %{ 10 / 0 }
return
NinPosh.Write-ErrorRecency -WithoutSave -Debug
NinPosh.Write-ErrorRecency -WithoutSave -Debug

# import-module 'posh'
# # $Posh.Prompt.After({ WriteErrorRecency | New-Text -fg 'orange'|Join-String -f " {0} "})
# $Posh.Prompt.After({ WriteErrorRecency })



# Get-PSDrive
# Get-PSDrive | Group { $_.GetType() }

write-warning "this is supposed to be equivalent, but, it's not working right"
gci . | Nin.Posh.GroupBy.TypeName FullName | ft -AutoSize

#expected  result:
gci . | Group { $_ | Format-ShortTypeName }