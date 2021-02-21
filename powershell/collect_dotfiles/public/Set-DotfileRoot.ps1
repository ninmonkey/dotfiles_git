function Set-DotfileRoot {
    param(
        # Full path for root
        [Parameter(Mandatory, Position = 0)]
        [string]$Path
    )

    $Item = Get-Item -ea stop $Path
    $_dotfilePath['Root'].FullPath = $Item
}
