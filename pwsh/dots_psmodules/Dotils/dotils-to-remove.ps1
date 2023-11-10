function Dotils.to.EnvVarPath.Fancy  {
    <#
    .SYNOPSIS
    .notes
        future: auto grab PSPath, turn into
    .EXAMPLE
        Pwsh7🐒>  $query
            | Dotils.to.EnvVarPath QuoteNL

        "${Env:LOCALAPPDATA}\Microsoft\SQL Server Management Studio\18.0_IsoShell\1033\"
        "${Env:LOCALAPPDATA}\Microsoft\SQL Server Management Studio\18.0_IsoShell\1033\ResourceCache.dll"

        Pwsh7🐒>  $query
            | Dotils.to.EnvVarPath Pwsh.Block

        gi "${Env:LOCALAPPDATA}\Microsoft\SQL Server Management Studio\18.0_IsoShell\1033\"
        gi "${Env:LOCALAPPDATA}\Microsoft\SQL Server Management Studio\18.0_IsoShell\1033\ResourceCache.dll"
        Pwsh7🐒>  $query
                | Dotils.to.EnvVarPath Pwsh.SingleLine

        (gi "${Env:LOCALAPPDATA}\Microsoft\SQL Server Management Studio\18.0_IsoShell\1033\")
        (gi "${Env:LOCALAPPDATA}\Microsoft\SQL Server Management Studio\18.0_IsoShell\1033\ResourceCache.dll")
    .example
        PS> $paths = 'C:\Users\cppmo_000\Microsoft\Power BI Desktop Store App\CertifiedExtensions', 'C:\Users\cppmo_000\AppData\Local\Microsoft\Power BI Desktop\CertifiedExtensions'

        PS> $paths | .to.envVarPath | Set-Clipboard -PassThru

        ${Env:USERPROFILE}\Microsoft\Power BI Desktop Store App\CertifiedExtensions
        ${Env:LOCALAPPDATA}\Microsoft\Power BI Desktop\CertifiedExtensions
    #>
    [Alias('.to.envVarPath')]
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [ValidateSet(
            'QuoteNL', 'Pwsh.Block', 'Pwsh.SingleLine', 'Pwsh.Array', 'Pwsh.List')]
        [string]$OutputFormat = 'QuoteNL',

        # Also save to clipboard
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,


        [Alias('cl', 'clip')]
        [switch]$CopyToClipboard,

        [Alias('Config', 'Kwargs')]
        [ArgumentCompletions(
            '@{ JoinSeparator = "`n" ; JoinStringFormat = ''gi "{0}"'' }'
        )]
        [hashtable]$Options = @{}
    )
    begin {
        $potentialOptions = gci env:
            | Dotils.Is.DirectPath
            | sort-Object{ $_.Value.Length } -Descending -Unique
        $defaults = @{
            PassThru = $true
            DirectoryAsForwardSlash = $true
            JoinSeparator = ', '
            JoinStringFormat = '"{0}"'
            JoinStringPrefix = ''
            JoinStringSuffix = ''
        }
        switch($OutputFormat){
            'QuoteNL' {
                $defaults.JoinSeparator = ', '
                $defaults.JoinStringFormat = '"{0}"'
            }
            { $OutputFormat -in @('Pwsh.List', 'Pwsh.Array') } {
                $defaults.JoinSeparator = "`n"
                $defaults.JoinStringFormat = 'gi "{0}"'
                $defaults.JoinStringPrefix = '@( '
                $defaults.JoinStringSuffix = ' )'
            }
            'Pwsh.Block' {
                $defaults.JoinSeparator = "`n"
                $defaults.JoinStringFormat = 'gi "{0}"'
            }
            'Pwsh.JoinPath' {
                # $defaults.JoinSeparator = "`n"
                $defaults.JoinStringFormat = '(Join-path $Variable "/foo/bar/rest")'
            }
            'Pwsh.SingleLine' {
                $defaults.JoinSeparator = "; "
                $defaults.JoinStringFormat = '(gi "{0}")'
            }
             default {
                write-warning "UnhandledOutputFormat: $Switch"
                $defaults.JoinSeparator = ', '
                $defaults.JoinStringFormat = '"{0}"'
                # no-op
            }
        }
        $defaults | Json | Join-String -op '$defaults = [ ' -os "`n]" -sep "`n" | Write-debug

        $Config = nin.MergeHash -other $Options -BaseHash $defaults
        $defaults | Json | Join-String -op '$config = [ ' -os "`n]" -sep "`n" | Write-debug
        [string]$accumLines = ''
    }
    process {
        # assume real for now
        $curInput = Get-Item -ea 'ignore' -LiteralPath $_
        $asStr = $curInput.FullName ?? $curInput.ToString()

        foreach($item in $potentialOptions){
            $pattern = [Regex]::escape( $item.Value )
            if($asStr -match $Pattern) {
                $prefixTemplate = '${{Env:{0}}}' -f $Item.Key
                $render = $asStr -replace $Pattern, $prefixTemplate
                @{
                    template = $prefixTemplate
                    render = $render
                    pattern = $pattern
                    asStr = $asStr
                } | Json | Join-String -sep "`n" | Write-debug


                # switch($OutputFormat){
                #     'QuoteNL' {
                #         # $render = $render
                #         # | Join-String -f '"{0}"' -Separator ', '
                #     }
                #     'Pwsh.Block' {
                #         $render = $render
                #         | Join-String -f 'gi "{0}"' -sep "`n"
                #     }

                # }

                ## assert
                #   do I actually need to use expandstring?
                $resolveItem = Get-Item -ea 'ignore' $render
                # $resolveItem.FullName -eq $curInput.Fullname
                #     | Join-String -op 'IsValidAnswer? '
                #     | write-verbose

                $joinStr_splat = @{
                    FormatString = $Config.JoinStringFormat
                    Separator = $Config.JoinStringFormat
                }
                $render = $render | Join-String @joinStr_splat
                if( test-path ($resolveItem) )  {
                    $accumLines +=
                    return
                }
                # $accumLines += $joinStr_splat.Separator
            }
        }
    }
     end {
        $accumLines = $accumLines
            | Join-String -op $Config.JoinStringPrefix -os $Config.JoinStringSuffix


        if($CopyToClipboard) {
            $accumLines
                | Set-Clipboard -PassThru:( $Config.PassThru )
            return
        }

        return $accumLines
            | Join-String -sep "`n"
     }

}

