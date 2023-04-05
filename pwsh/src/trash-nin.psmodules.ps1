function workingTrash {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description
    .EXAMPLE
        gh repo list
        | nin.MdFromOutput

        gh repo list
        | nin.MdFromOutput
    .Example

        gh repo list
        | nin.MdFromOutput
        | code -

    .EXAMPLE
        "a`tb`nze`tf"
        | nin.MdFromOutput

    .EXAMPLE
        Pwsh>   "a`tb`nze`tf"
                | nin.MdFromOutput

        out:
            | a | b |
            | ze | f |

    .NOTES
    General notes
        (future) could auto-export using a nice viewer
        'rainbowcsv' looks decent

        or as '.md' then table formatting
    #>
    # quick hack until I  get parameter sets in a better state
    # $Stdout = $Input -join "`n" -split '\r?\n'
    $isFirst = $true

    $render = $stdout -split '\r?\n' | ForEach-Object {
    # $render = $stdout | ForEach-Object {
        $curStr = $_
        $Segments = $_ -split '\t'
        $colCount = $segments.count
        $segments | Join-String -op '| ' -os ' |' -sep ' | '
        if ($IsFirst) {
            $IsFirst = $false
            @('-' * $colCount -join '' -split '') # column row
            | Join-String -sep ' | '
        }
    }
    $render
    | Join-String -sep "`n"


}