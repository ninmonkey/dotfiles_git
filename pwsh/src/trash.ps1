fit -namespace System.ComponentModel -InheritsType Attribute

fit -Namespace System.Reflection -InheritsType Attribute



function nin.MdTable.old {
    <#
    .SYNOPSIS
    takes text from the pipeline, usually a native command

    .DESCRIPTION
    Converts Output from Native Commands. Many are easy to parse columns, because they use \t delimiters

    .EXAMPLE
    An example
        $stdout ??= gh repo list
        nin.mdTable -InputText $Stdout

    .NOTES
    - [ ] currently first line is header. argument could skip that.

    # todo: steppable ?
    - [ ] Future: Support input as Objects, table from properties
    - [ ] Future: Support input as hashtables, table from key value pairs
    - [ ] check out how pipescript defines how its objects serialize, secifically to markdown files
    #>
    [Alias(
        # 'xl.Format.MdTableFromStdoutConsole',
        # 'nin.TableFromStdout',
        # 'xl.Tablify.Md.FromStdout'
    )]
    [CmdletBinding()]
    param(
        # raw text piped in
        # use? [AllowNull()]
        # [AllowEmptyCollection()]
        # [AllowEmptyString()]



        # I don't like this parameterset, is there a cleaner way?
        [Alias('InputLines')]
        [Parameter(Mandatory, ParameterSetName='FromParam', ValueFromPipeline)]
        [string[]]$PipelineText,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName='FromParam')]
        [Alias('InputObject')]
        [Parameter(Mandatory, Position = 0)]
        [string[]]$InputText,

        [switch]$NoHeader
    )
    begin {
        if ($NoHeader) { throw 'nyi: insert blank header, so the first record doesn''t become the header' }
        # todo: steppable ?
        # [Text.StringBuilder]$StrBuild = [String]::Empty
        [Collections.Generic.List[Object]]$Lines =@()

    }
    process {
        switch($PSCmdlet.ParameterSetName) {
            'FromParam' {
                # $Lines.AddRange( @($InputText) )
            }
            'FromPipeline' {
                $Lines.AddRange( @($PipelineText) )
            }
            default { throw 'ShouldNeverReach' }
        }
        # [void]$StrBuild.AppendJoin($InputText, "`n")
    }
    end {

        switch($PSCmdlet.ParameterSetName) {
            'FromParam' {
                $Lines.AddRange( @($PipelineText) )
            }
            'FromPipeline' {
                # $Lines.AddRange( @($InputText) )
            }
            default { throw 'ShouldNeverReach' }
        }

        $targetLines = $Lines -join "`n" -split '\r?\n'

        # $Parse = $StrBuild.ToString() -split "`n" | ForEach-Object {
        # $Lines = $InputText -join "`n" -split '\r?\n'
        $targetLines | ForEach-Object {
            # segments are columns
            $curLine = $_
            $Segments = $curLine -split '\t'
            $colCount = $segments.count
            $segments | Join-String -op '| ' -os ' |' -sep ' | '
            if ($IsFirst) {
                $IsFirst = $false
                @('-' * $colCount -join '' -split '') # column row
                | Join-String -sep ' | '
            }
        } | Join-String -sep "`n"


        return $Parse

    }
}
