performance: `PayloRest_CompanyResourceCode`


New or updated functions: 
[].VsCode.ConvertTo.Snipet 
[ ] .Select.One 
[ ] .Select.Some 
.Text.NormalizeLineEnding 
[ ] .To.Duration 
[x] .To.Type.FromPSTypenames 
- [] dotils-ToBe.nin-Where-FilterByGroupChoice

- [ ] scriptanalyzer: VerifyValidateSetsCommasAreSynacticallyValid

```ps1
goto 'H:\data\2023\pwsh\sketches'
gci | .is.Directory
    | .Modifed This Week

need super fast colors, and by names

'do stuff' | fg dimGray bg black
'dostuff' | fg main1
'dostuff' | fg main2
'no' | WriteSem 'Bad' # big red 
'no' | WriteSem 'bold' # big red 
'no' | WriteSem 'dim' # desaturate color, or fade out
'okay' | fg 'darkgreen' Fade .2
'okay' | fg ('darkgreen' | Fade .2)
```


```ps1
gci | .GroupBy LastWriteTime -sb { $_.Year, $_.Month }

new Tree
NewTree -name -payload


$tree = New-Node 'Name' -Data $Null
    | Add-Node -Name 'child1', 'child2'

$tree = @()
$Tree.addChlid(@(
    New-Node -name 'foo'
))



$str | .Text.ToUpper
$str | .Text.ToLower
```


```ps1
Selecct-WIldcardCult
$cults ??= Get-Culture -ListAvailable
$cults | .Match.Start 'en'

function .as.Duration { 
}


```