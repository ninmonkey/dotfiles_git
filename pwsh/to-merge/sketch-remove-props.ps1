# $pslist | s * -First 1 | ForEach-Object {

function nancy.doc {
    throw '
synopsis: just
    make Get-Help -Param * better
    make "foo | Ho" => Get-Help -Online
'
}
function nancy.Help {
    <#
    .SYNOPSIS
        1] nancy.Filter.GetCommand, 2] generates Fzf list, 3] invokes get-help -example/online,
    .notes
        4] this can either pipe names to fzf /w doc synopsis descriptions

    #>
    throw @'
    # pretty print, like
        ls .
        |
        | sort Verb, Name
        | ft -group Verb -auto
'@
}
function nancy.Filter.GetCommand {
    <#
    .SYNOPSIS
        sugar to regex or filter commands
    .notes

    .example
    #>
    param(
        #
        [Alias('Name')]
        [Parameter(Mandatory, Position = 0)]
        [string[]]$CommandNamePatterns,

        [ArgumentCompletions(
            "'Verb', 'Name'",
            "'Module', 'Name'",
            "'Name', 'Verb'"
        )]
        [object[]]$SortBy = @('Verb', 'Name'),

        # not regex? opt out.
        [switch]$AsWildcard
        # ? $LiteralCommandName
    )
    if ($AsWildcard) { throw 'NYI' }


    # name only if literal Get-Command -Name
    Get-Command | Where-Object {
        foreach ($regex in $CommandNamePatterns) {
            if ($_.Name -match $regex) { return $true }
        }
        $false
    }
    | Sort-Object -prop $SortBy
}

function Format-StripEmptyProperty {
    <#
    .SYNOPSIS
        this physically mutates objects, similar to select-object's ability
    #>
    [Alias('F-se')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [object[]]$InputObject
    )
    process {
        foreach ($Obj in $InputObject) {

        }
    }
}

'🔴early exit. Left off, cat attack
left off
- [ ] file is to make excel sheet wrap by name func


- [ ]  nin.propsBy
    - [ ] enumerate over properties by types
    - [ ] 2nd func does filter by
- [ ] FSE mutates to make visuals cleaner, per-object, not by property name/type


📚  H:\data\2023\dotfiles.2023\pwsh\to-merge\sketch-remove-props.ps1/2ec8cb95-1024-4bb9-8c81-e92b0068a676
'
| Write-Warning
# return
function nin.propsBy {
    <#
    .SYNOPSIS
        sugar to enumerate different styles of properties
    .NOTES
        future: more advanced searching to choose some property member types
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('PSObject', 'FindMember', 'GetMember', 'Custom')]
        [Parameter(Mandatory, position = 0)]
        [string]$EnumerationKind,

        #  FilterByModifier should maybe be extracted to a command itself
        # to make this, pre-filter, more widely useful.
        [ArgumentCompletions(
            'NotBlank', 'NotNull',

            'NotNumeric', 'NotText', # after coercing, its not text
            'NotString', 'NotStringType' # now by type, or append the word type?
        )]
        [string[]]$FilterByModifier,

        [Parameter(Mandatory, position = 1, ValueFromPipeline)]
        [object]$InputObject
    )
    begin {
        [Collections.Generic.List[Object]]$OriginalPropertyNames = @()
    }
    process {
        switch ($EnumerationKind) {
            'PSObject' {
                $OriginalPropertyNames = @( $InputObject.PsObject.Properties )
            }
            'FindMember' {
                Throw 'NYI'
            }
            'GetMember' {
                Throw 'NYI'

            }
            'Custom' {
                Throw 'user override of names: NYI'
            }

            default { throw "UnhandledEnumerationKind: $EnumerationKind" }
        }
        'nin.propsBy:  ⎣ Type: {0}, Element: {1}  EnumerationKind: {2}, FilterByModifier: {3}⎦' -f @(
            $InputObject.GetType().Name
            @( $InputObject )[0]?.GetType().Name ?? '<none>'
            $EnumerationKind
            $FilterByModifier | Join-String -sep ', ' -SingleQuote
        )

        [Collections.Generic.List[Object]]$FinalFilteredProps = @(
            $OriginalPropertyNames | ForEach-Object {
                $curProperty = $_


                $shouldIgnore = $false
                if ( $curProperty.Name -match 'standard|exit' ) { $null = 0 }
                foreach ($Filter in $FilterByModifier) {

                    switch ($EnumerationKind) {
                        'TrueNull' {
                            if ( $null -eq $curProp.Value ) {
                                $shouldIgnore = $true
                            }
                            'nin.propsBy: ⎣{0}: {1}⎦' -f @(
                                $switch
                                $shouldIgnore
                            ) | Write-Verbose
                        }
                        'NotNull' {
                            if ( [string]::IsNullOrEmpty( $curProp.Value ) ) {
                                $shouldIgnore = $true
                            }
                            'nin.propsBy: ⎣{0}: {1}⎦' -f @(
                                $switch
                                $shouldIgnore
                            ) | Write-Verbose
                        }
                        'NotBlank' {
                            if ( [string]::IsNullOrWhiteSpace( $curProp.Value.ToString() )) {
                                $shouldIgnore = $True
                            }
                            if ( [string]::IsNullOrEmpty( $curProp.Value ) ) {
                                $shouldIgnore = $true
                            }
                            'nin.propsBy: ⎣{0}: {1}⎦' -f @(
                                $switch
                                $shouldIgnore
                            ) | Write-Verbose
                            # $SelectedProps
                            # | Where-Object { -not [string]::IsNullOrEmpty( $_.Value ) }
                            # | Format-Table

                        }
                        default { 'WIP/NYI UnhandledFilter: Filter to be Refactored out?' }
                    }
                    $shouldIgnore | Write-Verbose
                }
                # 'testProp: ShouldIgnore? {0}: {1}' -f @(
                'nin.propsBy => Ignore? {0}: {1}' -f @(
                    $curProperty.Name
                    $shouldIgnore
                ) | Write-Verbose
                if ($ShouldIgnore) { return }
                $curProperty
            }
        )
        $InputObject | Select-Object -prop $FinalFilteredProps.Name

        $OriginalPropertyNames.Name | Sort-Object -Unique
        | Join-String -sep ', ' -op 'nin.propsBy => OriginalNames = '
        | Write-Verbose
        $FinalFilteredProps.Name | Sort-Object -Unique
        | Join-String -sep ', ' -op 'nin.propsBy => FilteredNames = '
        | Write-Verbose
    }
    end { }
}
$plist = $null
$pslist ??= Get-Process | Get-Random -Count 10
$one = $pslist | s -first 1
$one | fime -MemberType Property
hr
$one | Format-List * -Force
hr
$one | Format-StripEmptyProperty


$t2 = Get-Item .

$t2 | nin.propsBy PSObject

hr
$t2 | Select-Object * | Format-List * -Force
hr
$t2 | Select-Object * | Format-StripEmptyProperty | Format-List * -Force

hr

$t2 | Format-List -Force *
hr
$t2 | nin.propsBy PSObject -Verbose -FilterByModifier NotBlank | Format-List -Force *

@'
try
    $one | nin.propsBy PSObject -FilterByModifier NotBlank
'@

