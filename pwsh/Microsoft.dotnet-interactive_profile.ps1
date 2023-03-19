# invoking from: <file:///C:\Users\cppmo_000\SkyDrive\Documents\PowerShell\Microsoft.dotnet-interactive_profile.ps1>
## main entry for dotnet interactive using path $PROFILE
$PSCommadPath | Join-String -f 'loading: "{0}"'


<#

previous entry point from interactive:


## main entry for dotnet interactive using path $PROFILE
$PSCommadPath | Join-String -f 'loading: "{0}"'
# . ( gi 'H:\data\2023\dotfiles.2023\pwsh\Microsoft.dotnet-interactive_profile.ps1' )
. (Get-Item -ea 'continue' (Join-Path $env:Nin_Dotfiles 'pwsh/Microsoft.dotnet-interactive_profile.ps1'))

PS> $PROFILE
 C:\Users\nin\Documents\PowerShell\Microsoft.dotnet-interactive_profile.ps1

[
  {
    "Name": "AllUsersCurrentHost",
    "Value": "C:\\Users\\nin\\.nuget\\packages\\microsoft.dotnet-interactive\\1.0.416502\\tools\\net7.0\\any\\runtimes\\win\\lib\\net7.0\\Microsoft.dotnet-interactive_profile.ps1"
  },
  {
    "Name": "CurrentUserCurrentHost",
    "Value": "C:\\Users\\nin\\Documents\\PowerShell\\Microsoft.dotnet-interactive_profile.ps1"
  }
]

previous entry point:
    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\Microsoft.PowerShell.Host\Microsoft.PowerShell.Host.psd1

## additional files:

gci <file:///C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules>


    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\CimCmdlets\CimCmdlets.psd1
    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\Microsoft.PowerShell.Diagnostics\Diagnostics.format.ps1xml
    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\Microsoft.PowerShell.Diagnostics\Event.format.ps1xml
    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\Microsoft.PowerShell.Diagnostics\GetEvent.types.ps1xml
    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\Microsoft.PowerShell.Diagnostics\Microsoft.PowerShell.Diagnostics.psd1
    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\Microsoft.PowerShell.Host
    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\Microsoft.PowerShell.Host\Microsoft.PowerShell.Host.psd1
    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\Microsoft.PowerShell.Management\Microsoft.PowerShell.Management.psd1
    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\Microsoft.PowerShell.Security\Microsoft.PowerShell.Security.psd1
    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\Microsoft.PowerShell.Security\Security.types.ps1xml
    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\Microsoft.PowerShell.Utility\Microsoft.PowerShell.Utility.psd1
    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\Microsoft.WSMan.Management\Microsoft.WSMan.Management.psd1
    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\Microsoft.WSMan.Management\WSMan.format.ps1xml
    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\PSDiagnostics\PSDiagnostics.psd1
    C:\Users\cppmo_000\.nuget\packages\microsoft.dotnet-interactive\1.0.416502\tools\net7.0\any\runtimes\win\lib\net7.0\Modules\PSDiagnostics\PSDiagnostics.psm1

#>

