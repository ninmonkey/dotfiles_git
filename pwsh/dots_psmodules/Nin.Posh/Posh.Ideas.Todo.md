example uses for people

## Proxy, `gcm` paging / collapsele 



## Proxy command examples

- [ ] Proxy commands that change the default values, like: 
```ps1
function proxy.gcm {
    gcm -m Dotils, ExcelAnt *name*
}
function proxy.gci {
    get-childitem -path . -depth 3 
}
function proxy.join-csv {
    $stuff | Join-String -sep ', ' -Property Name
    $stuff | Join-String -sep ', ' -P Name
    # simplifies:
    $stuff | JoinStr ', '
    $stuff | JoinStr ', ' Name


    $str | Join-String -sep ', ' 
    $str | Join.Csv ', '  
}
function Proxy.SelectSome {
    $Input | Select -first 10 
    # becomes 
    $Input | Some
}
function Proxy.SelectAt {
    $Input | Select -index 3
    @($Index)[3]
    @($Index)[-1]

    # becomes
    $Input | At 3
    $Input | At -1
    # or 
    $Input | Last

}
```