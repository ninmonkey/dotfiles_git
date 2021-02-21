
function Get-DotfilePath {
    [CmdletBinding(DefaultParameterSetName = 'GetOnePath')]
    [OutputType('System.String', [System.Collections.Hashtable])]
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

        # Returns metadata hashtable
        [Parameter()][switch]$PassThru,

        # Label or Id or Key
        [Alias('All')]
        [Parameter(
            Mandatory,
            ParameterSetName = 'ListAll')]
        [switch]$ListAll
    )


    process {
        switch ($PSCmdlet.ParameterSetName) {
            'GetOnePath' {
                if (!($_dotfilePath.Contains($Label))) {
                    Write-Error "KeyNotFound: '$Label'"
                    break
                }

                if ($PassThru) {
                    $_dotfilePath[$Label]
                } else {
                    $_dotfilePath[$Label].Path
                }
                break
            }
            # future: 'GetOnePathPipeline' {
            #     break
            # }
            { $ListAll -or 'ListAll' } {

                $_dotfilePath.getenumerator() | ForEach-Object {
                    [pscustomobject]$_.value
                }
                break
            }

            default { throw "Unhandled Parameterset: $($PSCmdlet.ParameterSetName)" }
        }

    }
}


