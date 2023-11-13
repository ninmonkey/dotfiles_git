using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language
using namespace Globalization
# err -Clear
$Mod = gi 'H:\data\2023\dotfiles.2023\pwsh\dots_psmodules\Dotils\Completions.NamedDateFormatString.psm1'

impo $mod -Force -PassThru -Scope Global | Render.ModuleName

get-date
$x = 10

[System.Globalization.DateTimeFormatInfo]|Fime | ft
(get-culture).DateTimeFormat

[Globalization.DateTimeFormatInfo]$DtFmtInfo = (get-culture).DateTimeFormat
hr
$DtFmtInfo | fime *pattern* -MemberType Property | % Name | join.ul



@'
try

    Get-Date | Datetime.Format -FormatString "MMMM d"
    Get-Date | Datetime.Format -FormatString ( Datetime.NamedFormatStr ...
'@