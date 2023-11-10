<#
expected:
├── dots_psmodules
│   ├── Dotils
│   │   ├── Dotils.psm1
│   │   ├── builld.ps1
│   │   ├── maybe-attributes.ps.md
│   │   ├── quick buffer.md
│   │   ├── readme.first-script-analyzers.md
│   │   ├── readme.todo.md
│   │   └── tests
│   │       ├── Format-ShortString.tests.ps1
│   │       └── Operators.Is.tests.ps1
│   ├── Nin.Posh
│   │   ├── .vscode
│   │   │   ├── Nin.Posh.code-snippets
│   │   │   └── launch.json
│   │   ├── Nin.Posh.psd1
│   │   ├── Nin.Posh.psm1



System
  |> Component
  |> Component
  ┟
#>

$Uni = @{
    Bar_Hypen = '─'
    Bar_Right = '─'
    Bar_Down = '│'
    Bar_UpRightDown = '├'
    Bar_UpRight = '└'
    DirectCopy = '─', '│', '├'
}
nin.MergeHash -Base $Uni -OtherHash @{ 'cat' = 4}

function renderNode {
    param(
        [int]$depth = 0,
        [string]$Token
    )
    $indentBar  = $Uni.Bar_Right * $depth * 2 -join ''
    # $indentBar  = '-' * $depth * 2 -join ''
    $prefix = $Uni.Bar_UpRightDown
    # Join-String -inp $Token -f "`n${indentBar}{0}"
    # Join-String -inp $Token -f "`n${prefix}${indentBar}{0}"
    "${prefix}${indentBar}${token}"
}

hr
@(
    '├── {0}' -f 'dots_psmodules'  -replace ' ', $Uni.Bar_Hypen
    '|  ├─ {0}' -f 'Dotils'# -replace '├', $Uni.Bar_UpRight
    '|  ├─ {0}' -f 'Dotils' -replace '├', $Uni.Bar_UpRight
    '|    ├─ {0}' -f 'Dotils'  -replace '├', $Uni.Bar_UpRight
) -join "`n" -replace '[|]', $Uni.Bar_Down



# hr
# @(
#     renderNode -depth 0 'root'
#     renderNode -depth 1 'dots_psmodules'
#     renderNode -depth 1 'stuff'
#     renderNode -depth 2 'bar'
# ) | Join-String -sep "`n"
# hr
# @(
#     '├──{0}' -f 'dots_psmodules'
#     '|  ├──{0}' -f 'Dotils'
#     '|      ├──{0}' -f 'Dotils'
# ) -join "`n" -replace '[|]', $Uni.Bar_Hypen
# @(
#     '├──{0}' -f 'dots_psmodules'
#     '|  ├─{0}' -f 'Dotils'
#     '|  ├─{0}' -f 'Dotils'
# ) -join "`n" -replace '[|]', $Uni.Bar_Down
# @(
#     '├──{0}' -f 'dots_psmodules'  -replace ' ', $Uni.Bar_Hypen
#     '|    ├─{0}' -f 'Dotils' -replace ' ', $Uni.Bar_Right
#     '|  ├─{0}' -f 'Dotils'
# ) -join "`n" -replace '[|]', $Uni.Bar_Down

