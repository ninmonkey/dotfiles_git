$Config = @{
    AppRoot      = Get-Item $PSScriptRoot
    Profile_Root = Join-Path $Env:AppData 'Code/User' | Get-Item -ea 'stop'
}
$Config += @{
    Export_DotfilesRoot = Join-Path $Config.AppRoot 'desktop-main'
    Profile_SubProfiles = Join-Path $Config.Profile_Root 'profiles'
}
# $Config | Format-Table -auto -Wrap
# $Config | Format-List
# return
function __collect.VsCode.Config {
    $P = @{
        Profile_SubProfiles = Join-Path $Config.Profile_Root 'profiles'
    }

}

function __renderHashtable.Experiment {
    param(
        [Alias('Hash', 'InputHash')]
        [Parameter(Position = 0, Mandatory)]
        [hashtable]$InputObject,

        [Parameter(Position = 1, Mandatory)]
        [ArgumentCompletions(
            'Default',
            'SemanticPath'
        )]
        [string]$OutputMode,

        [Alias('Sort')]
        [Parameter(Position = 2)]
        [ValidateSet('Key', 'Value')]
        [string]$SortByKey
    )
    if ($SortByKey) {
        $sortSplat = @{
            InputHash = $InputObject
            SortBy    = $SortByKey
        }
        $InputObject = Ninmonkey.Console\Sort-Hashtable @sortSplat
        Write-Warning 'sort not working in all cases, maybe using implicit case casensitive?'
    }

    Hr -fg orange
    label 'OutputMode' $OutputMode
    switch ( $OutputMode ) {
        'Default' {
            $InputObject.GetEnumerator()
            | Join-String -sep "`n`n" -p {
                "{0}`n{1}" -f @(
                    $_.Key
                    $_.Value
                ) }
        }
        'SemanticPath' {
            $C = @{}
            $C.Fg_Dim = "${fg:gray30}"
            $C.Fg_Dim = "${fg:gray15}"
            $C.Fg = "${fg:gray65}"
            $C.Fg_Em = "${fg:gray85}"
            $C.Fg_Max = "${fg:gray100}"
            $C.Fg_Min = "${fg:gray0}"
            $InputObject.GetEnumerator()
            | Join-String -sep "`n`n" -p {
                $segs = $_.Value -split '\\'
                $render_pathColor = @(
                    $body = $segs | Select-Object -SkipLast 2
                    | Join-String -sep '/'

                    $tail = $segs | Select-Object -Last 2
                    | Join-String -sep '/'

                    $C.Fg_Dim
                    $Body
                    $C.Fg_Em
                    '/'
                    $Tail
                    $PSStyle.Reset
                ) | Join-String

                $render_key = @(
                    $C.Fg_Max
                    $_.Key
                    $PSStyle.Reset
                ) | Join-String

                # '{0}{1}' -f @(
                "{0}`n{1}" -f @(
                    $render_key
                    $render_pathColor) }
        }
        'Default2' {
            $InputObject.GetEnumerator()
            | Join-String -sep "`n`n" -p {
                '{0} : {1}' -f @(
                    $_.Key
                    $_.Value ) }
        }
        default {
            throw "UnhandledMode: $OutputMode"
        }

    }
    Hr
}

if ($false) {
    # example invokes

    __renderHashtable.Experiment -InputHash $Config 'Default'
    __renderHashtable.Experiment -InputHash $Config 'SemanticPath'

    $SomePaths = @{
        Home         = Get-Item ~
        AppData      = Get-Item $Env:AppData
        LocalAppData = Get-Item $Env:LocalAppData
        UserProfile  = Get-Item $Env:UserProfile
    }
    __renderHashtable.Experiment -InputObject $SomePaths -OutputMode SemanticPath -SortByKey Value
    __renderHashtable.Experiment -InputObject $SomePaths -OutputMode SemanticPath
}
__renderHashtable.Experiment -InputObject $Config -OutputMode SemanticPath -SortByKey Key