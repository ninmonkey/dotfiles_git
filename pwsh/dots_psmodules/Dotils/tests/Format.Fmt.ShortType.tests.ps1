beforeAll {
    Import-Module dotils -force -Passthru -wa 'ignore' -verbose:$false | Join-String { $_.Name, $_.Version } | write-host -fore 'green'
    $PSStyle.OutputRendering = 'ansi' # test explorer keeps removing this
}
AfterAll {
    $PSStyle.OutputRendering = 'ansi' # test explorer keeps removing this
}

Describe 'Dotils.Fmt-ShortType' {
    afterEach {
        $PSStyle.OutputRendering = 'ansi' # test explorer keeps removing this
    }
    beforeEach {
        $PSStyle.OutputRendering = 'ansi' # test explorer keeps removing this
    }
    Context 'Static tests as <Template>'  {
        It '<Template> Expected: <Expected> from <In>' -ForEach @(
            @{
                In = [Dictionary[string,int]]::new()
                Template = 'FullName'
                StripNamespaces = @()
                MinNamespaceCrumbCount = 2
                Expected = '[Collections.Generic.Dictionary`2<String, Int32>]'
                # $dint  | Dotils.Format-ShortType -Template FullName -Options @{ StripNamespaces = @() } -MinNamespaceCrumbCount 2
                # $dint  | Dotils.Format-ShortType -Template FullName -Options @{ StripNamespaces = @() } -MinNamespaceCrumbCount 0
            }
            @{
                In = [Dictionary[string,int]]::new()
                Template = 'FullName'
                StripNamespaces = @()
                MinNamespaceCrumbCount = 2
                Expected = '[Collections.Generic.Dictionary`2<String, Int32>]'
            }
            @{
                In = [Dictionary[string,int]]::new()
                Template = 'Name'
                StripNamespaces = @()
                MinNamespaceCrumbCount = 2
                Expected = '[Dictionary`2<String, Int32>]'
            }
            # $dint  | Dotils.Format-ShortType -Template Name -MinNamespaceCrumbCount 2
        ) {
            $In | Dotils.Format-ShortType -Template $Template -MinNamespaceCrumbCount $MinNamespaceCrumbCount -Options @{ StripNamespaces = $StripNamespaces }
            | SHould -beExactly $Expected

        }
    }
    it 'Old Case <Expected>' -ForEach @(
        @{
            In = [System.Collections.Generic.List[IO.DirectoryInfo]]$files = @( gci . -Directory )
            Expected = 'Collections.Generic.List`1[IO.DirectoryInfo]'
        }
    ) {
        $In | Dotils.Format-ShortType -MinNamespaceCrumbCount 0
            | Should -BeExactly '[DirectoryInfo]'
        $In | Dotils.Format-ShortType -MinNamespaceCrumbCount 1
            | Should -BeExactly '[IO.DirectoryInfo]'
        $In | Dotils.Format-ShortType -MinNamespaceCrumbCount 99
            | Should -BeExactly '[System.IO.DirectoryInfo]'
        # $In.GetType() | Dotils.Fmt.ShortType | Should -BeExactly $Expected
        # $In | Dotils.Fmt.ShortType | Should -BeExactly $Expected

    }
}

# $fn.a2.GetType() | Join-string { $_ -replace '\bSystem\.', ''}
# $fn.a2.GetType() | Fmt.ShortType
# $fn.a2 | Fmt.ShortType
