```ps1
Get-Module Dotils | Dotils.Summarize.Module

groupings
    -contains 'string|text'
    -contains 'join|split'
    -contains 'regex\match\replace'
    -contains ''

ByReturnType
    returns string or fileinfo or any
ByParameterType
    takes fileinfo 



gcm -m dotils | % nAME | SORT -Unique | CountOf
    # 142 

gcm -m dotils | .Match.Start '[\._]'

CommandType     Name                
-----------     ----                
Function        __compare-Is.Type   

gcm -m Dotils Dotils.Select-*

CommandType     Name                                               Version    Sourc
-----------     ----                                               -------    -----
Function        Dotils.Select-ExcludeBlankProperty                 0.0        Dotil
Function        Dotils.Select-NotBlankKeys                         0.0        Dotil
Function        Dotils.Select-TemporalFirstObject                  0.0        Dotil

Pwsh 7.3.6> [30] 🐒
gcm -m Dotils *Select*       

CommandType     Name                                               Version    Sourc
-----------     ----                                               -------    -----
Alias           .Select.FirstTime -> Dotils.Select-TemporalFirstO… 0.0        Dotil
Alias           .Select.One -> Dotils.Select.One                   0.0        Dotil
Alias           Select-ExcludeBlankProperty                        0.0        Dotil
Alias           SelectBy-Module                                    0.0        Dotil
Function        Dotils.Error.Select                                0.0        Dotil
Function        Dotils.Select-ExcludeBlankProperty                 0.0        Dotil
Function        Dotils.Select-NotBlankKeys                         0.0        Dotil
Function        Dotils.Select-TemporalFirstObject                  0.0        Dotil
Function        Dotils.Select.One                                  0.0        Dotil
Function        Dotils.Select.Some                                 0.0        Dotil
Function        Dotils.Select.Variable                             0.0        Dotil
Function        Dotils.SelectBy-Module                             0.0        Dotil

Pwsh 7.3.6> [30] 🐒
gcm -m dotils *command*

CommandType     Name                                               Version    Sourc
-----------     ----                                               -------    -----
Alias           MonkeyBusiness.Vaidate.ExportedCommands -> Dotils… 0.0        Dotil
Function        Dotils.Find-MyNativeCommand                        0.0        Dotil
Function        Dotils.Get-NativeCommand                           0.0        Dotil
Function        Dotils.GetCommand                                  0.0        Dotil
Function        Dotils.InferCommandCategory                        0.0        Dotil
Function        Dotils.Measure-CommandDuration                     0.0        Dotil
Function        Dotils.Modulebuilder.Format-SummarizeCommandAlias… 0.0        Dotil
Function        Dotils.Random.Command                              0.0        Dotil
Function        Dotils.Random.CommandExample                       0.0        Dotil

Pwsh 7.3.6> [30] 🐒
gcm -m dotils *describe*

CommandType     Name                                               Version    Sourc
-----------     ----                                               -------    -----
Alias           .Describe -> Dotils.Describe                       0.0        Dotil
Alias           .Describe.Error -> Dotils.Describe.Error           0.0        Dotil
Alias           Dotils.Describe.Type -> Dotils.Debug.GetTypeInfo   0.0        Dotil
Function        Dotils.Describe                                    0.0        Dotil
Function        Dotils.Describe.Error                              0.0        Dotil
Function        Dotils.Describe.ErrorRecord                        0.0        Dotil
```