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

- [ ] 🟡 prevent bug if Ctor throws exceptions when listname is null, ahead of time.
- [ ] 🟡 filter [CompletionResults]
- [ ] 🟡 short string name from auto pattern isn't right:

    get-date | % tostring (  Try.Named.Fstr -DateFormat "LongTime"  )


note, date string sometimes has uncaught exception, test case
    Try.Named.Fstr -DateFormat <ctrl+space>
        🟢 ok
    Try.Named.Fstr <ctrl+space>
        🔴 PSReadLine Error

Oh, it's list item can't be null.
    get_ListItemText
'@
<#

### Environment
PSReadLine: 2.3.4
PowerShell: 2023.11.0
OS: Microsoft Windows 10.0.19045
BufferWidth: 91
BufferHeight: 70

Last 200 Keys:

 Tab Ctrl+z Ctrl+@ p Ctrl+l l s Enter
 e r r RightArrow Enter
 Ctrl+l p f d s Ctrl+a t r y . f o r Backspace Backspace Backspace n Tab Spacebar Tab Ctrl+
z Ctrl+z Ctrl+z Ctrl+a Backspace ( g e t l Backspace - c u l t u r e ) . d a t e t i m e f
Tab Enter
 UpArrow Spacebar | Spacebar f i m e Enter
 UpArrow Spacebar - m e m Tab Spacebar p r Tab Enter
 UpArrow Spacebar * p a t t e r n * Enter
 UpArrow Spacebar | Spacebar % Spacebar n a m e Enter
 UpArrow Ctrl+a Ctrl+x UpArrow Ctrl+w Ctrl+w Ctrl+w Ctrl+w Ctrl+w Ctrl+w Backspace Backspac
e Backspace Tab Tab . L o n g d a t e Tab Enter
 p g e t - d a Ctrl+l Ctrl+a n a m e Ctrl+a t r y . n a m e Tab Spacebar - Ctrl+@ Enter
 Spacebar Ctrl+@ DownArrow RightArrow UpArrow UpArrow UpArrow RightArrow UpArrow UpArrow Up
Arrow UpArrow UpArrow LeftArrow RightArrow DownArrow DownArrow DownArrow Escape Escape Esca
pe p UpArrow UpArrow Ctrl+a Backspace Ctrl+l n Backspace t r y . n a Tab Spacebar Ctrl+@

### Exception

System.Management.Automation.PSInvalidOperationException: Cannot access properties on a nul
l instance of the type CompletionResult.
   at System.Management.Automation.CompletionResult.get_ListItemText()
   at Microsoft.PowerShell.PSConsoleReadLine.<>c.<CreateCompletionMenu>b__54_0(CompletionRe
sult c)
   at System.Linq.Enumerable.MaxInteger[TSource,TResult](IEnumerable`1 source, Func`2 selec
tor)
   at Microsoft.PowerShell.PSConsoleReadLine.CreateCompletionMenu(Collection`1 matches)
   at Microsoft.PowerShell.PSConsoleReadLine.PossibleCompletionsImpl(CommandCompletion comp
letions, Boolean menuSelect)
   at Microsoft.PowerShell.PSConsoleReadLine.CompleteImpl(Boolean menuSelect)
'@
#>