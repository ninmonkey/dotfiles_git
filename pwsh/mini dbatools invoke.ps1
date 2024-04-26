Import-Module DbaTools
# mini DbaTools invoke query

$SqlAzureConnectionString ??= Get-Secret -Name 'GitLogger.SqlAzureConnectionString' -AsPlainText
$sqlInstance = 'nin8\sql2019'
$selected = Get-DbaComputerCertificate -ComputerName 'nin8'
        | ? DnsNameList -Contains 'localhost'
        | ? Name -Match 'IIS Express Development Certificate'


Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true
Set-DbaNetworkCertificate -SqlInstance $SqlInstance -Thumbprint $selected.Thumbprint -Confirm
# (toggling this on for localhost only)  for a guide/explaination about default requiring encryption:
# <https://blog.netnerds.net/2023/03/new-defaults-for-sql-server-connections-encryption-trust-certificate/>

( $dbInst = Connect-DbaInstance -Connstring $SqlAzureConnectionString )
Invoke-DbaQuery -Query 'select top @N * from sys.system_objects' -SqlInstance $sqlInstance -SqlParameter @{
    N = '4'
}
| Ft
