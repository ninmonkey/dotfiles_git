# .Link
# https://go.microsoft.com/fwlink/?LinkID=225750
# .ExternalHelp System.Management.Automation.dll-help.xml

$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

function Prompt {
    <#
    .description
    default prompt with newline and name
    #>
    "`n`n$($executionContext.SessionState.Path.CurrentLocation)`nWinPS$('>' * ($nestedPromptLevel + 1)) ";
    return
}

# function prompt {
#     "sdfdsf`n`nsdfsfd>`n`n"
}



# https://stackoverflow.com/questions/5725888/windows-powershell-changing-the-command-prompt

# PS6 unicode
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_special_characters?view=powershell-6#unicode-character-ux

# $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
# https://stackoverflow.com/questions/49476326/displaying-unicode-in-powershell


# print uni
# 0x20..0x2 + 10 | ForEach-Object { [char]$_ }

# function prompt {
#     Write-Host ("PS" + ">") -NoNewline -ForegroundColor White
#     return " "
# }

# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-output?view=powershell-6 decho
# https://stackoverflow.com/questions/35879774/how-to-powershell-to-give-warning-or-error-when-using-an-undefined-variable
# enable warning
# unlike the Set-PSDebug cmdlet, Set-StrictMode affects only the current scope and its child scopes. Therefore, you can use it in a script or function without affecting the global scope
# Set-PSDebug -Strict
# Set-StrictMode -Version latest
