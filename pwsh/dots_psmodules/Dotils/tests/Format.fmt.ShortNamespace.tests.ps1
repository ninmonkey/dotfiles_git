beforeAll {
    $PSStyle.OutputRendering = 'ansi' # test explorer keeps removing this
    Import-Module dotils -force -Passthru -wa ignore -verbose:$false -Debug:$false
        | Join-String { $_.Name, $_.Version } | write-host -fore 'green'

    $PSStyle.OutputRendering = 'ansi' # test explorer keeps removing this
}
AfterAll {
    $PSStyle.OutputRendering = 'ansi' # test explorer keeps removing this
}

Describe 'Dotils.Fmt-ShortNamespace' {
    Context 'Minimum Static Tests' {
        it 'Piping [DirectoryInfo] -As [String: NameOfType]' {
            [IO.DirectoryInfo]$obj = Get-Item .
            $tinfo = $obj.GetType()
            $namespace_str = $tinfo.Namespace # is 'System.IO'
            $Options = @{
                StripNamespaces = 'System', 'System.IO'
            }
            $reason = 'ManuallyCraftedExample using -Options'
            $toPipe = 'System.IO.DirectoryInfo'

            $toPipe
                | Dotils.Format-ShortNamespace -MinCount 0 -options $Options
                | Should -BeExactly '' -Because $reason
            $toPipe
                | Dotils.Format-ShortNamespace -MinCount 1 -options $Options
                | Should -BeExactly 'IO' -Because $reason
        }
        it 'Piping [DirectoryInfo] -As [String: NameOfNamespace]' {
            [IO.DirectoryInfo]$obj = Get-Item .
            $tinfo = $obj.GetType()
            $namespace_str = $tinfo.Namespace # is 'System.IO'
            $Options = @{
                StripNamespaces = 'System', 'System.IO'
            }
            $reason = 'ManuallyCraftedExample using -Options'
            $toPipe = $Namespace_str

            $toPipe
                | Dotils.Format-ShortNamespace -MinCount 0 -options $Options
                | Should -BeExactly '' -Because $reason
            $toPipe
                | Dotils.Format-ShortNamespace -MinCount 1 -options $Options
                | Should -BeExactly 'IO' -Because $reason
        }

        it 'Piping [DirectoryInfo] -As [type]' {
            [IO.DirectoryInfo]$obj = Get-Item .
            $tinfo = $obj.GetType()
            $namespace_str = $tinfo.Namespace # is 'System.IO'
            $Options = @{
                StripNamespaces = 'System', 'System.IO'
            }
            $reason = 'ManuallyCraftedExample using -Options'
            $toPipe = $tinfo
            $toPipe # is [IO.DirectoryInfo].GetType()
                | Dotils.Format-ShortNamespace -MinCount 0 -options $Options
                | Should -BeExactly '' -Because $reason
            $toPipe
                | Dotils.Format-ShortNamespace -MinCount 1 -options $Options
                | Should -BeExactly 'IO' -Because $reason
        }
        it 'Piping [DirectoryInfo] -As [object]' {
            [IO.DirectoryInfo]$obj = Get-Item .
            $tinfo = $obj.GetType()
            $namespace_str = $tinfo.Namespace # is 'System.IO'
            $Options = @{
                StripNamespaces = 'System', 'System.IO'
            }
            $toPipe = $Obj
            $reason = 'ManuallyCraftedExample using -Options'
            $toPipe # is [IO.DirectoryInfo].GetType()
                | Dotils.Format-ShortNamespace -MinCount 0 -options $Options
                | Should -BeExactly '' -Because $reason
            $toPipe
                | Dotils.Format-ShortNamespace -MinCount 1 -options $Options
                | Should -BeExactly 'IO' -Because $reason
        }

    }
    Context 'using -MinCount' {
        beforeEach {
            $PSStyle.OutputRendering = 'ansi'
        }
        it 'Case <MinCount> <In> is <Expected>' -ForEach @(
            @{
                In = 'System.IO'
                StripNamespaces = @(
                    'System', 'System.IO'
                )
                MinCount = 1
                Expected = 'IO'
            }
            @{
                In = 'System.IO'
                StripNamespaces = @(
                    'System', 'System.IO'
                )
                MinCount = 9
                Expected = 'System.IO'
            }
            @{
                In = 'System.IO'
                StripNamespaces = @(
                    'System', 'System.IO'
                )
                MinCount = 0
                Expected = ''
            }
        ) {
            $Options = @{
                StripNamespaces = $StripNamespaces
            }
            $In | Dotils.Format-ShortNamespace -minCount $MinCount -Options $Options
            | Should -BeExactly $Expected
        }
    }

}
# $fn.a2.GetType() | Join-string { $_ -replace '\bSystem\.', ''}
# $fn.a2.GetType() | Fmt.ShortType
# $fn.a2 | Fmt.ShortType
