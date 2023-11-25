using namespace System.Collections.Generic

function Dotils.Fonts.ListImported {
    <#
    .notes
        # original
        gcm -ListImported
                | % Source | sort -Unique
                | Join-String -sep ', ' { '[ a: {0}, ]' -f $_ }
    #>
    "try: gcm 'dotils.font*'" | write-verbose
    Join-String -op 'Dotils.Fonts.psm1 => [ ' -os ' ] ' -sep ', ' -in @(
        # gcm -ListImported 'dotils.font*'
        gcm -m 'Dotils.Fonts'
            | Sort-Object -Unique Name
            | %{
                Join-String -in $_ -DoubleQuote -p Name
            }
    )
}
function Dotils.Fonts.Find-Font {
    [CmdletBinding()]
    param(
        [ArgumentCompletions(
            '(Join-Path $Env:SystemRoot "Fonts")'
        )]
        [string[]]$PathsToSearch
    )
    $config = @{
        SearchPaths =  [List[Object]]@(
            (Join-Path $Env:SystemRoot 'Fonts')
        )
    }
    if($PSBoundParameters.ContainsKey('PathsToSearch')) {
        $Config.SearchPaths.AddRange(@( $PathsToSearch ))

        $Config.SearchPaths = $Config.SearchPaths | Sort-Object -unique
    }
    $Config.SearchPaths
        | Join-String -sep ', ' -DoubleQuote
        | Join-String -op 'Searching Paths: '
        | Infa

    foreach($toSearch  in $Config.SearchPaths) {
        Dotils.Fonts.Get-FontInfo -SourceFolder $toSearch
    }

}

function Dotils.Fonts.Get-CompanyNames {
    <#
    .LINK
        https://learn.microsoft.com/en-us/dotnet/api/system.windows.media.glyphtypeface?view=windowsdesktop-8.0
    #>
    [OutputType('System.Windows.Media.GlyphTypeface')]
    [CmdletBinding()]
    param(
        [ArgumentCompletions(
            '"C:\Windows\Fonts\OUTLOOK.TTF"'
        )]
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('FullName', 'PSPath', 'Path')]
        [string[]]$FontPaths
    )
    Add-Type -AssemblyName PresentationCore | Out-Null
    [List[Object]]$FailedNames = @()
    foreach($Name in $FontPaths ) {
        try {
            [Windows.Media.GlyphTypeface]::new( $Name  )
        } catch {
            $failedNames.Add( $Name )
            Join-String -in $_ -op 'Dotils.Fonts.Get-CompanyNames:: [Windows.Media.GlyphTypeFace]::new( $_ ) error: '
            | write-warning

        }
    }


    $FailedNames
        | %{
            Join-String -in $_ -DoubleQuote
        }
        | Join-String -f "`n - {0}" -op 'Final failed names summary: '
        | Write-Verbose -verb


    #  gci (Join-Path $Env:SystemRoot "Fonts")
}

function Dotils.Fonts.Render-GlyphFaceNames {
    <#
    .EXAMPLE
        # run cached queries:

            . Dotils.Fonts.Render-GlyphFaceNames

        # or without cache

            Dotils.Fonts.Render-GlyphFaceNames
    #>
    $toSearch ??= Gci -Recurse (Join-Path $Env:SystemRoot "Fonts")
    $fonts ??= Dotils.Fonts.Get-CompanyNames $toSearch -ea 'ignore'
    $fonts
    | %{
            @(
                ''
                $_.FontUri | Join-String -f 'uri: {0}'
                $_.FamilyNames | Sort-Object -Unique | Join-String -sep ', '
                    | Join-String -op 'FamilyNames: '

                $blank = "`u{2400}"

                ($_)?.Style ?? $Blank
                    | Join-String -op 'Style: '
                ($_)?.Stretch ??  $Blank
                    | Join-String -op 'Stretch: '
                ($_)?.CopyRights ??  $Blank
                    | Join-String -op 'CopyRights: '


                ($_)?.DesignerUrls ?? $blank
                    | Join-String -op 'DesignerUrls: '
                ($_)?.DesignerNames ?? $Blank
                    | Join-String -op 'DesignerNames: '
                ''
                # Blank.Default -In $_ -Prop 'FamilyNames' -def "`u{2400}"
                #     | Join-String -sep ', ' -op 'FamilyNames: '
                # Blank.Default -In $_ -Prop 'Style' -def "`u{2400}"
                #     | Join-String -sep ', ' -op 'Style: '

                # Blank.Default -In $_ -Prop 'Stretch' -def "`u{2400}"
                #     | Join-String -sep ', ' -op 'Stretch: '

                # Blank.Default -In $_ -Prop 'Copyrights' -def "`u{2400}"
                #     | Join-String -sep ', ' -op 'Copyrights: '

                # Blank.Default -In $_ -Prop 'Descriptions' -def "`u{2400}"
                #     | Join-String -sep ', ' -op 'Descriptions: '

                # Blank.Default -In $_ -Prop 'DesignerUrls' -def "`u{2400}"
                #     | Join-String -sep ', ' -op 'DesignerUrls: '

                # $res | %{ (-not [string]::IsNullOrWhiteSpace( $_.Descriptions ) ? $_.Descriptions : "`u{2400}" ) | Join-String -op "`n=> " -os "`n" }

                # ( -not [string]::IsNullOrWhiteSpace( $_.Descriptions ) ? $_.Descriptions : "`u{2400}" )
                #     | Join-String -op "Descriptions: "

                # ($_)?.Descriptions ?? '😭'
                #     | Join-String -op 'Descriptions: '
            )
        | Join-String -sep "`n" }
    | Join-String -sep (hr 1)

    # $res | %{
    # $_ | Sort-Object FamilyNames -Unique | Join-String -sep ', ' FamilyNames
    # } | Join.UL
}


function Dotils.Fonts.Get-FontInfo {
    <#
    .SYNOPSIS
        foont metadata using shell
    .NOTES
        from: <https://stackoverflow.com/a/61309479/341744>
    #>
    [CmdletBinding()]
    [OutputType( 'PSObject' )]
    Param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$SourceFolder,
        [switch]$Recurse
    )
    write-warning 'NYI: stack overflow example does not run, code here to fix later, maybe because'

    return
    # > quote: Theo's answer, and doing some code modification, I made the discovery that there are different extended attributes depending on if the font is installed or not. Th
    # using a lookup hashtable to avoid localized field names
    $fontProperties = [ordered]@{
        0   = 'Name'
        1   = 'Size'
        2   = 'Type'
        20  = 'Author'
        21  = 'Title'
        25  = 'Copyright'
        33  = 'Company'
        34  = 'Description'
        164 = 'Extension'
        165 = 'FileName'
        166 = 'Version'
        194 = 'Path'
        196 = 'FileType'
        310 = 'Trademark'
    }
    $shell  = New-Object -ComObject "Shell.Application"
    $objDir = $shell.NameSpace($SourceFolder)
    $files  = Get-ChildItem -Path $SourceFolder -Filter '*.*' -File -Recurse:$Recurse

    foreach($file in $files) {
        $objFile   = $objDir.ParseName($file.Name)
        $mediaFile = $objDir.Items()
        $info    = [ordered]@{}
        $fontProperties.GetEnumerator() | ForEach-Object {
            $name  = $objDir.GetDetailsOf($mediaFile, $_.Name)
            if ( -not [string]::IsNullOrWhiteSpace( $name )) {
                $info[$_.Value] = $objDir.GetDetailsOf($objFile, $_.Name)
            }
        }
        [PsCustomObject]$info
    }

    $null = [Runtime.Interopservices.Marshal]::ReleaseComObject($objFile)
    $null = [Runtime.Interopservices.Marshal]::ReleaseComObject($objDir)
    $null = [Runtime.Interopservices.Marshal]::ReleaseComObject($shell)
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}

function Dotils.Fonts.List.Method1 {
    <#
    .EXAMPLE
        err -Clear && impo .\Dotils.Fonts.psm1 -Force -PassThru && Dotils.Fonts.ListImported

        err -Clear &&
            impo .\Dotils.Fonts.psm1 -Force -PassThru &&
            Dotils.Fonts.ListImported &&
            gcm -m Dotils.Fonts | ft -AutoSize
    .NOTES

        returns
            [Drawing.Text.InstalledFontCollection]

        which contains:
            [Drawing.FontFamily]

        System.Drawing.FontFamily
    .LINK
        https://learn.microsoft.com/en-us/dotnet/api/system.drawing.text.installedfontcollection?view=dotnet-plat-ext-8.0
    .link
        https://learn.microsoft.com/en-us/dotnet/api/system.drawing.fontfamily?view=dotnet-plat-ext-8.0
    .LINK
        https://learn.microsoft.com/en-us/dotnet/desktop/winforms/advanced/using-fonts-and-text?view=netframeworkdesktop-4.8
    #>
    [OutputType(
        '[System.Drawing.FontFamily[]]'
        # 'System.Object',
        # 'System.String'
    )]
    param()
    [Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
    'reading FontCollection...' | write-host -fg 'orange'

    $Collection = [Drawing.Text.InstalledFontCollection]::new()
    $one.IsStyleAvailable( [System.Drawing.FontStyle]::Bold )  | write-verbose

    return $Collection.Families

    # (New-Object ).Families
}

function Blank.Default {
    <#
    .SYNOPSIS
        sugar for: ( -not [string]::IsNullOrWhiteSpace( $_.Descriptions ) ? $_.Descriptions : "`u{2400}" )  | Join-String -op "Descriptions: "
    #>
    param(
        [Parameter(Mandatory)]
        [object]$InputObject,

        [Parameter(Mandatory)]
        [string]$Property,

        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [ArgumentCompletions(
            '"`u{2400}"',
            "'Default'"
        )]
        [string]$DefaultValue
    )
    $t = $InputObject
    $Value? = ( $InputObject )?[ $Property ]

    if( [String]::IsNullOrEmpty( $Value? ) ) {
        return $DefaultValue
    }
    return $Value?
}

Export-ModuleMember -Function @(
    # 'Dotils.GetCommand.ListImported'
    # 'Dotils.GetCommand.ListImported'
    'Dotils.Fonts.*'
) -Alias @(
    'Dotils.Fonts.*'
) -Variable @(
    'Dotils.Fonts.*'
)
