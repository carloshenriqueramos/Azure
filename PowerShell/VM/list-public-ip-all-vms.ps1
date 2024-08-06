##### Listar Ips Públicos de 1 VM
$vm = get-azvm -ResourceGroupName "RGNAME" -Name azrlcftwhub
$vmNicName = $vm.NetworkProfile.NetworkInterfaces.Id.Split("/")[8]
$ipAddress = Get-AzPublicIpAddress | Where-Object {$_.IpConfiguration.Id -like "*$vmNicName*"} 
$ipAddress | Select Name, IpAddress | Export-Csv "C:\Temp\ips.csv" -NoTypeInformation