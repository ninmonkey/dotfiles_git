err -Clear
$Mod = gi 'H:\data\2023\dotfiles.2023\pwsh\dots_psmodules\Dotils\Completions.NamedDateFormatString.psm1'

impo $mod -Force -PassThru -Scope Global | Render.ModuleName

get-date
$x = 10