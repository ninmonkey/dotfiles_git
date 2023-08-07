# function t.Simplify.PropertyTypes.iter1 {
#     <#
#     .SYNOPSIS
#     maybe name it Format because it renders short names?
#     #>
#     [Alias('t.Simplify.Props')]
#     $InputObject = $Input
#     $query = $InputObject | Find-Member

#     $query
#     | select Name, DeclaringType, ReflectedType, PropertyType
#     | %{ $row = $_
#         $row | Add-Member -ea 0 -force -PassThru -NotePropertyMembers @{
#             Declare = $_.DeclaringType | Format-ShortTypeName
#             Reflect = $_.ReflectedType | Format-ShortTypeName
#             Property = $_.PropertyType | Format-ShortTypeName
#             DisplayString = $_.DisplayString
#         }
#     }
# }

throw 'finish my sketch'
'Others still wip
    .Summarize.SharedProperties
    .Summarize.CollectionSharedProperties
    .Excel.Write.Sheet.Name
    .Join-Str.Alias
    .Iter.Text
    .Iter.Enumerator
    .Summarize.CollectionSharedProperties
    .Iter.Prop
'

| write-host -back 'darkred'


$obj = Set-Alias 'abc' -Value 'CountOf' -PassThru



function t.Simplify.PropertyTypes {
    <#
    .SYNOPSIS
    maybe name it Format because it renders short names?
    #>
    [Alias('t.Simplify.Props')]
    $InputObject = $Input
    $query = @(
        $InputObject | Find-Member )

    # [Collections.Generic.List[Object]]$propsToModify = @(
    [string[]]$propsToModify = @(
        'DeclaringType'
        'ReflectedType'
        'PropertyType'
        # 'DisplayString'
    # Name, DeclaringType, ReflectedType, PropertyType
    )

    $selectSplat = @{
        ErrorAction = 'ignore'
        Property = '*'
        # Property = $propsToModify, '*'
    }

    $query
    | select @selectSplat
    | %{
        $row = $_
        $newValues = [ordered]@{}
        foreach($propName in $propsToModify) {
            $newValues[ $propName ] =
                $row.$PropName | Format-ShortTypeName
        }
        $newValues  | json
        $newValues  | ft
        $row
            | Add-Member -ea 0 -force -PassThru -NotePropertyMembers $NewValues

        # $row | Add-Member -ea 0 -force -PassThru -NotePropertyMembers @{
        #     Declare = $_.DeclaringType | Format-ShortTypeName
        #     Reflect = $_.ReflectedType | Format-ShortTypeName
        #     Property = $_.PropertyType | Format-ShortTypeName
        #     DisplayString = $_.DisplayString
        # }
    }

}


$obj | t.Simplify.PropertyTypes