Write-Warning 'Add-DocstringMemberInfo: Not loading'
# check this out.

function __Add-DocstringMemberInfo {
    <#
    .synopsis
        Adds Extra docstring info on objects, then returns the result
    .description
        this version autocoerces to string
        an experiment. I'm not suggesting this is a good idea, or the way to do it.
    .example
        # in the future, a script extent property will auto-open in vs code
        # ConvertFrom-ScriptExtent might be implicitly called on ValueByPropertyName
        $SomeDir.__doc__ | ConvertFrom-ScriptExtent | code
    .notes
        future:

        - bug: currently '__doc__ | fw' is right, but '__doc__.toString()' is blank

        - auto-tag/link to related items?
    #>
    [Alias('__doc__')]
    [cmdletbinding(PositionalBinding = $False)]
    param(
        # Base object
        [Parameter(
            Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        # text to save
        [Alias('String', 'Text', 'Help')]
        [Parameter(Mandatory, Position = 0)]
        [string[]]$DocString,

        # tag listing
        [Parameter()]
        [ArgumentCompletions('Config', 'Dotfile', 'CommandLine', 'Ninmonkey.Console', 'Dev.Nin')]
        [string[]]$Tags,

        # Use Add-Member -Force
        [Parameter()][switch]$Force

        # include markdown?
        # [Parameter()][switch]$AsMarkdown,
    )

    # Name       = 'sdfsd'
    $docInfo = [ordered]@{
        PSTypeName = 'nin.MemberInfoDocstring'
        Text       = $DocString | Join-String -sep "`n"
        Tags       = $Tags #| Join-String -sep ', ' -SingleQuote
        # Url        = $null
        CreatedBy  = $PSCmdlet.MyInvocation.ScriptName | Get-Item
    }

    $docObj = [pscustomobject]$docInfo
    $docObj | Update-TypeData -DefaultDisplayProperty 'Text' -Force # doesn't fix .ToString()

    $addMember_splat = @{
        InputObject       = $InputObject
        NotePropertyName  = '__doc__'
        NotePropertyValue = $docObj
        PassThru          = $true
        Force             = $Force
    }


    $addMember_splat | format-dict | Write-Information
    $addMember_splat | format-dict | Write-Debug

    # if (! $AsMarkdown) {
    Add-Member @addMember_splat
    # }
}

# Export-ModuleMember -Function '__Add-DocstringMemberInfo' -Alias '__doc__'
