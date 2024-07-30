$sub = read-host "Enter Subscription name"
set-az-context $sub
$rg = "rg-dns"
$zone = read-host "Enter DNS Zone"
$dnstoadd = read-host "Enter DNS Record to add"
$dnstoremove = read-host "Enter DNS record to remove"

#Exclui TXT
$RecordSet = Get-AzDnsRecordSet -Name "@" -RecordType TXT -ResourceGroupName $rg -ZoneName $zone | {where $_.records -contains $dnstoremove}
Remove-AzDnsRecordConfig -RecordSet $RecordSet -Value $dnstoremove
Set-AzDnsRecordSet -RecordSet $RecordSet

#Adiciona TXT
$rg = "rg-dns"
$zone = read-host "Enter DNS Zone"
$dnstoadd = read-host "Enter DNS Record"
$RecordSet = Get-AzDnsRecordSet -ResourceGroupName $RG -ZoneName $zone -Name "@" -RecordType TXT
Add-AzDnsRecordConfig -RecordSet $RecordSet -Value $dnstoadd
Set-AzDnsRecordSet -RecordSet $RecordSet

#Exclui MX
$RecordSet = Get-AzDnsRecordSet -Name "@" -RecordType MX -ResourceGroupName $rg -ZoneName $zone
Remove-AzDnsRecordConfig -Exchange $dnstoremove -Preference 1 -RecordSet $RECORDSET
Remove-AzDnsRecordConfig -Exchange "registroaserexcluido2." -Preference 5 -RecordSet $RECORDSET
Set-AzDnsRecordSet -RecordSet $RecordSet

#Adiciona MX
$RecordSet = Get-AzDnsRecordSet -ResourceGroupName $RG -ZoneName $zone -Name "@" -RecordType MX
Add-AzDnsRecordConfig -RecordSet $RecordSet -preference 1 -exchange "registroaseradicionado"
Add-AzDnsRecordConfig -RecordSet $RecordSet -preference 5 -exchange $dnstoadd
Set-AzDnsRecordSet -RecordSet $RecordSet