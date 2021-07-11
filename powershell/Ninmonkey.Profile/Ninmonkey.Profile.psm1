
$nin_dotfiles = @{
    Todo                   = 'rewrite from scatch. A Prediction Source could be neat.Or else just autocomplete prop dynames (dynamic completer if needed)'
    # PowershellCore         = $profile # redundant unless you want vscode vs normal
    PowerShellProfilesAll  = Get-Item 'C:\Users\cppmo_000\Documents\2020\dotfiles_git\powershell'
    Bat                    = Get-Item -ea SilentlyContinue "$Env:UserProfile\Documents\2020\dotfiles_git\bat\.batrc"
    RipGrep                = Get-Item -ea SilentlyContinue "$Env:UserProfile\Documents\2020\dotfiles_git\ripgrep\.ripgreprc"
    BashProfile            = 'nyi'
    WindowsTerminalPreview = Get-Item -ea silent 'C:\Users\cppmo_000\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json'
    WindowsTerminal        = Get-Item -ea silent 'C:\Users\cppmo_000\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
    vscode                 = @{
        ExtensionDir = Get-Item "$env:UserProfile\.vscode\extensions"
        User         = Get-Item "$env:appdata\Code\User\settings.json"
    }
    Git                    = @{
        GlobalIgnore = Get-Item $Env:UserProfile\Documents\2020\dotfiles_git\git\global_ignore.gitignore
    }
    PowerBI                = @{
        'ExternalToolsConfig' = Get-Item 'C:\Program Files (x86)\Common Files\Microsoft Shared\Power BI Desktop\External Tools'
    }

}
