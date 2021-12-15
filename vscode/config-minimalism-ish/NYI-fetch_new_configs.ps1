[hashtable]$App = @{ BasePath = Get-Item $PSSCriptroot }
[hashtable]$Config = @{}

[hashtable]$App = $App + [ordered]@{
    ExportPath = Join-Path $App.BasePath '.output'
    SourceJson = 'J:\vscode_datadir\games\User\settings.json'
}
$x = 10
    
h1 'one'

$App | format-dict 

h1 '2'
$Config | format-dict 