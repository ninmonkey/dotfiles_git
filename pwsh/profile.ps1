# shared (all 3)
"⊢🐸 ↪ enter Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: regular, prof: AllUsersCurrentHost" | Write-Warning; [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>


# toggle /w env var
$PSDefaultParameterValues['*:verbose'] = $True
$PSDefaultParameterValues.Remove('*:verbose')







'bypass 🔻, early exit: Finish refactor: "{0}"' -f @( $PSCommandPath )
"⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: Debug, prof: CurrentUserCurrentHost (psit debug only)" | Write-Warning; [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>
return




"enter ==> Profile: docs/profile.ps1/ => Pid: ( $PSCOmmandpath ) '${pid}'" | Write-Warning
. (Get-Item -ea stop 'C:\Users\cppmo_000\SkyDrive\Documents\2021\dotfiles_git\powershell\profile.ps1')
"exit  <== Profile: docs/profile.ps1/ => Pid: '${pid}'" | Write-Warning

"⊢🐸 ↩ exit  Pid: '$pid' `"$PSCommandPath`". source: VsCode, term: regular, prof: AllUsersCurrentHost" | Write-Warning; [Collections.Generic.List[Object]]$global:__ninPathInvokeTrace ??= @(); $global:__ninPathInvokeTrace.Add($PSCommandPath); <# 2023.02 #>