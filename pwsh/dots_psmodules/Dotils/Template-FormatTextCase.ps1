@'
This is so close to working nicely.
tab generates this

    Text.Case Lower (Get-Culture

then if you backspace, space, or quote, it'll start completions.


```ps1
 [ArgumentCompletions(
            "en-us",
            "(Get-Culture ",
            "(Get-Culture 'de-de')"
        )][string]$CultureName = (Get-culture).Name,
```
'@
function Text.Case {
    param(
        # Which mode, Upper, TitleCase, LowerCase and invariant versions
        [ValidateSet('Title', 'Upper', 'Lower','LowerInvariant', 'UpperInvariant')]
        [Parameter()][string]$OutputMode,
        [Parameter()]
        [ArgumentCompletions(
            "en-us",
            "(Get-Culture ",
            "(Get-Culture 'de-de')"
        )][string]$CultureName = (Get-culture).Name,

        [Alias('InputObject')]
        [AllowNull()]
        [AllowEmptyString()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$TextInput
    )
    begin {
        $cult = Get-Culture -Name $CultureName }
    process {
        if($null -eq $TextInput) { return }
        if( $TextInput.length -eq 0) { return }
        [string]$obj = $TextInput ?? ''

        switch($OutputMode) {
           'Title' {
                $cult.TextInfo.ToTitleCase( $obj ) }
           'Upper' {
                $cult.TextInfo.ToUpper( $obj ) }
           'Lower' {
                $cult.TextInfo.ToLower( $obj ) }
           'LowerInvariant' {
                $obj.ToLowerInvariant() }
            'UpperInvariant' {
                $obj.ToUpperInvariant() }
           default { $obj }
        }
    }
}

# 'HiWorld' | Text.Case LowerInvariant (Get-Culture '


function Format-TextCase {

    <#
    .synopsis
        Format text case using culture's [TextInfo]
    .NOTES
        note
            Get-Culture # default
            Get-Culture '' # invariant

        curious, is this ever *not* equivalent ?
            'sdf'.ToUpper( $cult )
            $cult.TextInfo.ToUpper( 'sdf' )
    .link
        https://learn.microsoft.com/en-us/dotnet/api/system.globalization.cultureinfo?view=net-7.0
    #>
    [Alias('F-It')]
    param(
        # Which mode, Upper, TitleCase, LowerCase and invariant versions
        [ValidateSet('Title', 'Upper', 'Lower',
            'LowerInvariant', 'UpperInvariant')]
        [Parameter()]
        [string]$OutputMode,

        [Parameter()]
        [ArgumentCompletions(
            "en-us", "(Get-Culture 'de-de')"
        )][string]$CultureName = (Get-culture).Name,

        [Alias('InputObject')]
        [AllowNull()]
        [AllowEmptyString()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$TextInput

    )
    begin {

        $cult = Get-Culture -Name $CultureName }
    process {
        if($null -eq $TextInput) { return }
        if( $TextInput.length -eq 0) { return }
        [string]$obj = $TextInput ?? ''

        switch($OutputMode) {
           'Title' {
                $cult.TextInfo.ToTitleCase( $obj ) }
           'Upper' {
                $cult.TextInfo.ToUpper( $obj ) }
           'Lower' {
                $cult.TextInfo.ToLower( $obj ) }
           'LowerInvariant' {
                $obj.ToLowerInvariant() }
            'UpperInvariant' {
                $obj.ToUpperInvariant() }
           default { $obj }
        }
    }
}

$sample = @'
Example Url that should be patched locally, when month does not exist in the data set
'@.ToLower()

$Sample | F-It Title
$Sample | F-It LowerInvariant