
function Get-DotfilePath {
    [CmdletBinding(DefaultParameterSetName = 'GetOnePath')]
    <#
    .description
        read saved values
    .notes
        returns either [hashtable] if -All
        else returns FullPath as string
    #>
    param(
        # Label or Id or Key
        [Parameter(
            Mandatory, Position = 0,
            ParameterSetName = 'GetOnePath')]
        [string]$Label,
        # [Parameter(
        #     Mandatory, ValueFromPipeline,
        #     ParameterSetName = 'GetOnePathPipeline')]

        # Label or Id or Key
        [Alias('All')]
        [Parameter(
            Mandatory,
            ParameterSetName = 'ListAll')]
        [switch]$ListAll


        # # Label Directory Name
        # [Parameter(Mandatory, Position = 1)]
        # [string]$Path
    )

    # future: allow labels from pipeline

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'GetOnePath' {
                if (!($_dotfilePath.Contains($Label))) {
                    Write-Error "KeyNotFound: '$Label'"
                    break
                }

                # $_dotfilePath[$Label].FullPath | ForEach-Object tostring
                $_dotfilePath[$Label]
                break
            }
            # 'GetOnePathPipeline' {
            #     break
            # }
            { $ListAll -or 'ListAll' } {
                $_dotfilePath
                break
            }

            default { throw "Unhandled Parameterset: $($PSCmdlet.ParameterSetName)" }
        }

    }

    # $FullPath = Join-Path $_dotfilePath.BasePath $Path
    # $Item = Get-Item -ea continue $Path # continue or stop?

    # $_dotfilePath.Add( $Label, $Path )
}


