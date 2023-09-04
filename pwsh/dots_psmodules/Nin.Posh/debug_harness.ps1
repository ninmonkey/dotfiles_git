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
$query = [Ordered]@{
    All = @( Gcm -m 'Dotils'  )
    | %{
        $curRecord = $_
        $curRecord
            | Add-Member -force -PassThru -ea 'ignore' -NotePropertyMembers @{
                DefinitionAbbr =
                    $curRecord.Definition.ToString() -join "`n" -replace '\r?\n', '␊'
                    | Dotils.ShortString.Basic -maxLength 140
                ParametersAbbr =
                    ($curRecord)?.Parameters.Keys
                        | Sort-Object -Unique
                            | Join-String -sep "`n┟┝ "
                ParametersAbbrSingleLine =
                    ($curRecord)?.Parameters.Keys
                        | Sort-Object -Unique
                            | Join-String -sep ', '
            }
        $curRecord
    }
}
$query.Is = @(
    # $query.All | ?
)
write-warning 'insert: should be rename or alias property Definition to keep default views'
# PropDump =
$SelectProps_splat = @{
    ErrorAction = 'ignore'
    Property = '*'
    ExcludeProperty = @(
        'Definition', 'Parameters'
    )
}

$Pkg =
    $query.All
        | Select @SelectProps_splat
        | Export-Excel -wo 'All' -PassThru -TableStyle Light1 -Title 'all'
    # | %{

    #     $o = [PSObject]::new()
    #     $o.psobject.Properties.Add([Management.Automation.PSNoteProperty]::new('a','b'))
    #     $o.psobject.Properties.Add([Management.Automation.PSNoteProperty]::new('c','d'))
    #     $o
    # }

$Pkg =
    $query.All
    | Select -Prop $propNames.CommandInfo
    | Select @SelectProps_splat
    | Export-Excel -wo 'All2' -ExcelPackage $Pkg -PassThru -TableStyle Light1 -Title 'all'


$mySheet = $pkg.Workbook.Worksheets['All']
$myTab = $mySheet.Tables | Select -first 1
$myCol =
    $myTab.Columns | ? Name -eq 'ParametersAbbrSingleLine'


<#
from docs

    Set-ExcelColumn -Worksheet $ws -Heading "WinsToFastLaps"  -Value {"=E$row/C$row"} -Column 7 -AutoSize -AutoNameRange
    Set-ExcelColumn -Worksheet $ws -Heading "Link" -Value {"https://en.wikipedia.org" + $worksheet.cells["B$Row"].value  }  -AutoSize

#>
# $colFmt = Set-ExcelColumn -ExcelPackage $pkg -WorksheetName 'all' -Column 'ParametersAbbrSingleLine' -Width 64 -WrapText  -pass
$colFmt = Set-ExcelColumn -ExcelPackage $Pkg -Worksheet $mySheet -heading 'ShortedDef' -value {"=E$row"} -Column $MyCol.Id -AutoSize -AutoNameRange -pass
# -ExcelPackage $pkg -WorksheetName 'all' -Column 'ParametersAbbrSingleLine' -Width 64 -WrapText  -pass





$myCol | iot2 -NotSkipMost
$myTab.Columns|ft

$mySheet
    | join-string Name -sep ', '
    | Dotils.Write-DimText | Join-String -op 'Sheets: '
$myTab.Columns
    | join-string Name -sep ', '
    | Dotils.Write-DimText | Join-String -op 'ColsOnSheet: '


# Close-ExcelPackage -ExcelPackage $Pkg -show -SaveAs
Close-ExcelPackage -ExcelPackage $Pkg -show


<#
example

Name                Reported                                                                       Value
----                --------                                                                       -----
CommandType         [CommandTypes]                                                                 Alias
Definition          [string]                                                            Dotils.Iter.Prop
DisplayName         [object]                                              .Iter.Prop -> Dotils.Iter.Prop
Module              [PSMo   duleInfo]                                                                dotils
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
Version             [Version]                                                                         0.0
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
# | Join-String -f "`n    => " -P { $_.Name, $_.Version -join ':$ '}


# 0..4 | %{ 10 / 0 }
close-ExcelPackage $Pkg -ea 'ignore'
# return
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