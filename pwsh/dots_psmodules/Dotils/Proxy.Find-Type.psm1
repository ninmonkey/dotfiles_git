using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management

Import-Module 'ClassExplorer' -ea 'stop'

function Proxy.Find-Type {
    <#
    .synopsis
        main entry point to invoke Find-Type

    #>
    [CmdletBinding(DefaultParameterSetName = 'ByFilter')]
    param(
        [Parameter(Position = 1)]
        [Alias('ns')]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Namespace},

        [Parameter(ParameterSetName = 'ByName', Position = 0)]
        [Parameter(ParameterSetName = 'ByFilter')]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Alias('fn')]
        [ValidateNotNullOrEmpty()]
        [string]
        ${FullName},

        [Alias('Base', 'it')]
        [ValidateNotNull()]
        [ClassExplorer.ScriptBlockStringOrType]
        ${InheritsType},

        [Alias('int', 'ii')]
        [ValidateNotNull()]
        [ClassExplorer.ScriptBlockStringOrType]
        ${ImplementsInterface},

        [Alias('sig')]
        [ValidateNotNull()]
        [ClassExplorer.ScriptBlockStringOrType]
        ${Signature},

        [Alias('a')]
        [switch]
        ${Abstract},

        [Alias('s')]
        [switch]
        ${Static},

        [Alias('se')]
        [switch]
        ${Sealed},

        [Alias('i')]
        [switch]
        ${Interface},

        [Alias('vt')]
        [switch]
        ${ValueType},

        [Parameter(ParameterSetName = 'ByFilter', Position = 0)]
        [Parameter(ParameterSetName = 'ByName')]
        [ValidateNotNull()]
        [scriptblock]
        ${FilterScript},

        [Alias('IncludeNonPublic', 'F')]
        [switch]
        ${Force},

        [Alias('Regex', 're')]
        [switch]
        ${RegularExpression},

        [Parameter(ValueFromPipeline = $true)]
        [psobject]
        ${InputObject},

        [switch]
        ${Not},

        [Alias('map')]
        [hashtable]
        ${ResolutionMap},

        [Alias('as')]
        [ClassExplorer.AccessView]
        ${AccessView},

        [Alias('HasAttr', 'attr')]
        [ClassExplorer.ScriptBlockStringOrType]
        ${Decoration}

        # [Alias('SmartCase')]
        # [switch]$UsingSmartCase,
        # [switch]$WithoutWrapStars
    )
    begin {
        $Config = @{
            # CompareInsensitive = $True
            AlwaysWrapStars = -not $WithoutWrapStars
            CustomParamList = @(
                'UsingSmartCase'
                'WithoutWrapStars'
            )
        }
        $CompareInsensitive = -not $UsingSmartCase
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $newParams = [ordered]@{} + $PSBoundParameters
            # don't pass the new params along
            foreach($namesToRemove in @($Config.CustomParamList) ) {
                $newParams.Remove($namesToRemove)
            }

            $wrappedCmd = $ExecutionContext.InvokeCommand.
                GetCommand('ClassExplorer\Find-Type',
                [CommandTypes]::Cmdlet )

            if($Config.CompareInsensitive) {
                $FullNamePattern  = $FullNamePattern.ToLowerInvariant()
                $NamePattern      = $NamePattern.ToLowerInvariant()
                $NamespacePattern = $NamespacePattern.ToLowerInvariant()
            }
            if( $Config.AlwaysWrapStars ) {
                $FullNamePattern  = Format-WrapWildcards -LowerCase:$CompareInsensitive -Text $FullNamePattern
                $NamePattern      = Format-WrapWildcards -LowerCase:$CompareInsensitive -Text $NamePattern
                $NamespacePattern = Format-WrapWildcards -LowerCase:$CompareInsensitive -Text $NamespacePattern
            }

            if( $PSBoundParameters.ContainsKey('NamePattern' ) ) {
                $newParams.Name = $NamePattern
            }
            if( $PSBoundParameters.ContainsKey('FullNamePattern' ) ) {
                $newParams.FullName = $FullNamePattern
            }
            if( $PSBoundParameters.ContainsKey('NamespacePattern' ) ) {
                $newParams.Namespace = $NamespacePattern
            }
            'query: Name: {0}, Fullname {1}, Namespace {2}' -f @(
                $newParams.Name      ?? "`u{2400}"
                $newParams.FullName  ?? "`u{2400}"
                $newParams.Namespace ?? "`u{2400}"
            ) | write-verbose -verbose


            $newParams
                | ConvertTo-Json -Depth 5
                | Join-String -f "    {0}" -op "Invoking Find-Type: `n" -sep "`n"
                | Write-Information -infa 'continue'


            $scriptCmd = { & $wrappedCmd @newParams }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline(
                $myInvocation.CommandOrigin
            )
            $steppablePipeline.Begin( $PSCmdlet )
        }
        catch {
            throw
        }
    }

    process {
        try {
            $steppablePipeline.Process($_)
        }
        catch {
            throw
        }
    }

    end {
        try {
            $steppablePipeline.End()
        }
        catch {
            throw
        }
    }

    clean {
        if ($null -ne $steppablePipeline) {
            $steppablePipeline.Clean()
        }
    }
}

function Format-WrapWildcards {
    <#
    .synopsis
        originally stripped from <Dotils\Format-WrapWildcards>

        wrap wildcards, but don't double-star because that isn't valid
    .example
        WrapWild 'cat bat'   => '*cat bat*'
        WrapWild '*cat bat'  => '*cat bat*'
        WrapWild 'cat*bat'   => '*cat*bat*'
        WrapWild ''          => '*'
        WrapWild $Null       => '*'
    .example
        'cat bat' , '*cat bat', 'cat*bat' , '', $Null| %{
        [pscustomobject]@{
            Str = $_
            Rend = Format-WrapWildcards -Text $_
        }}
    .link
        Format-WrapWildcards
    .link
        Dotils.Format.WildCardPattern
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Text,

        [Alias('LowerCase', 'ToLower')]
        [switch]$ForceLowercase,
        [object]$Culture
    )
    if( [string]::IsNullOrEmpty( $Text ) ) {
        write-warning 'Text is empty'
        return '*'
    }

    $Text = # abusing ternary
        -not $ForceLowerCase ?
            $Text :
                ( $Culture ?
                    $Text.ToLower( $Culture ) :
                    $Text.ToLowerInvariant() )

    $FinalText = @(
        $Text.StartsWith('*') ? '' : '*'
        $Text
        $Text.EndsWith('*') ? '' : '*' ) -join ''

    return $FinalText
}

Export-ModuleMember -Function @(
    'Proxy.*'
) -Alias @(
    'Proxy.*'
)


# Format-WrapWildcards -LowerCase:$CompareInsensitive -Text $Null
# # Format-WrapWildcards -LowerCase:$CompareInsensitive -Text ''
# Format-WrapWildcards -LowerCase:$true -Text 'foo*'
# |write-warning
# Format-WrapWildcards -LowerCase:$false -Text 'foo*'
# |write-warning

# Proxy.Find-Type -name 'Xmlelement' | write-warning
