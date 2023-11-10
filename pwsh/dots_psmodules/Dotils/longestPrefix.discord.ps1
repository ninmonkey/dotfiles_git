# https://discord.com/channels/180528040881815552/447476117629304853/1143635283875737710

function longest1 {
    param( $Left, $Right )
    [System.Linq.Enumerable]::TakeWhile(
        [System.Linq.Enumerable]::Zip($Left, $Right),
        [Func[System.ValueTuple[Char,Char],bool] ] {
            param($ctuple) $ctuple.Item1 -eq $ctuple.Item2 }
    ) | % { $_.Item1 } | Join-String
}
longest1 -Left "abcd123" -Right "abce432"
[Collections.Generic.List[object]]$results = @()
$names = Get-Module | % name
$prev = $names[0]
foreach($name in ($names | Select -skip 1)) {
    $cur = $Name
    $shared = longest1 -left $prev -right $cur | Join-String
    $results.Add(@(
        [pscustomobject]@{
            Left = $prev
            Right = $cur
            Shared = $Shared
        }
    ))
    $prev  = $cur

}

function LongestCommonPrefix3 {
    param (
        [Parameter(Mandatory)]
        [Object[]] $LeftObjects,

        [Parameter(Mandatory)]
        [Object[]] $RightObjects,

        [Parameter(Mandatory)]
        [Func[ValueTuple[object, object], bool]] $Comp
    )

    [Linq.Enumerable]::Where(
        [Linq.Enumerable]::TakeWhile(
            [Linq.Enumerable]::Zip[object, object]($LeftObjects, $RightObjects),
            [Func[ValueTuple[object, object], bool]] { param($t) $t.Item1, $t.Item2 }),
            $Comp)
}

LongestCommonPrefix3 '124' '124' { $args[0].Item1 -eq $args[0].Item2 }


$first = 'abcd123'
$second = 'abce432'

$end = [Math]::Min($first.Length, $second.Length)
$result = [System.Text.StringBuilder]::new($end)
for ($i = 0; $i -lt $end; $i++) {
    if ($first[$i] -ne $second[$i]) {
        return $result.ToString()
    }

    $null = $result.Append($first[$i])
}



[Collections.Generic.List[object]]$results2 = @()
$names = Get-Module | % name
$prev = $names[0]
foreach($name in ($names | Select -skip 1)) {
    $cur = $Name
    $shared = #longest1 -left $prev -right $cur | Join-String
        LongestCommonPrefix3 $prev $cur { $args[0].Item1 -eq $args[0].Item2 }
    $results.Add(@(
       $shared
    ))
    $prev  = $cur

}

$results | ft
hr
$results2 | ft

hr


[Collections.Generic.List[object]]$results3 = @()
$names = Get-Module | % name
$prev = $names[0]
foreach($name in ($names | Select -skip 1)) {
    $cur = $Name
    $shared = #longest1 -left $prev -right $cur | Join-String
        Ninmonkey.Console\Compare-LongestSharedPrefix -Text1 $prev -Text2 $cur
    $results.Add(@(
       $shared
    ))
    $prev  = $cur

}

$results3 | ft

return
$end = [Math]::Min($first.Length, $second.Length)
$result = [System.Text.StringBuilder]::new($end)
for ($i = 0; $i -lt $end; $i++) {
    if ($first[$i] -ne $second[$i]) {
        return $result.ToString()
    }

    $null = $result.Append($first[$i])
}



function LongestCommonPrefix2 {
    param (
        [Parameter(Mandatory)]
        [Object[]] $LeftObjects,

        [Parameter(Mandatory)]
        [Object[]] $RightObjects,

        [Parameter(Mandatory)]
        [Func[Object, Object, bool]] $Comp
    )

    [System.Linq.Enumerable]::TakeWhile(
        [System.Linq.Enumerable]::Zip([object[]] $LeftObjects, [object[]] $RightObjects),
        [Func[System.ValueTuple[object, object], bool]] { param($t) $t.Item1, $t.Item2 }) |
        ? { $Comp.Invoke($_.Item1, $_.Item2) }
}

# LongestCommonPrefix2 -LeftObjects '124' -RightObjects '124' { $args[0] -eq $args[1] }


return
function LongestCommonPrefix {
    param (
        [Parameter(Mandatory)]
        [Object[]] $LeftObjects,

        [Parameter(Mandatory)]
        [Object[]] $RightObjects,

        [Parameter(Mandatory)]
        [Func[Object, Object, bool]] $Comp
    )

    [System.Linq.Enumerable]::TakeWhile(
        [System.Linq.Enumerable]::Zip([object[]] $LeftObjects, [object[]] $RightObjects),
        [Func[System.ValueTuple[object, object], bool]] { param($t) $t.Item1, $t.Item2 }) |
        ? { $Comp.Invoke($_.Item1, $_.Item2) }
}

LongestCommonPrefix -LeftObjects '124' -RightObjects '124' { $args[0] -eq $args[1] }