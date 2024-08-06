#Add Domain to 365
Connect-msolservice 
$domain = read-host "Enter Domain Name"
New-msoldomain -name $domain 
$verification = (get-msoldomainverificationdns -domain $domain).label
$labelcorrect = $verification -replace "." + $domain
$dnsverification = "MS=" + $labelcorrect

#add verification txt to Zone and verifies zone existence
Connect-azaccount
$sub = read-host "Enter Subscription name"
Set-azcontext $sub 
$zone = read-host "Enter Zone Name"
$rg = read-host "Enter ResourceGroup name"
$searchzone = get-azdnszone -resourcegroupname $rg -name $zone 

if($searchzone -eq $null){
	Write-host "Zone does not exist in subscription. Please create it before proceeding." -backgroundcolor black -foregroundcolor red
	$searchzoneconfirm = read-host "Enter any input when zone is created"
    $searchzone2 = get-azdnszone -resourcegroupname $rg -name $zone -erroraction Stop
}

$dnsrecordset = (get-azdnsrecordset -zonename $zone -resourcegroupname $rg -name "@" -recordtype txt)
if($dnsrecordset -eq $null){
	Write-host "Recordset does not exist.Please create the @ TXT record"
	$RG = read-host "Enter ResourceGroupName"
	$name = read-host "Enter TXT Name"
	$type = "txt"
	$value = read-host "Enter Verification DNS Value"
	$Records = @()
	$Records += New-AzDnsRecordConfig -Value $dnsverification
	$RecordSet = New-AzDnsRecordSet -Name $name -RecordType $type -ResourceGroupName $rg -TTL 3600 -ZoneName $zone -DnsRecords $Records
}
elseif($dnsrecordset -ne $null) {
	$value = read-host "Enter Verification DNS Value"
	Write-host "Value for Verification is $value"
	$name = read-host "Enter TXT Name"
	$type = "TXT"
	$Records = @()
	$recordset = Get-AzDnsRecordSet -ResourceGroupName $RG -ZoneName $zone -Name $name -RecordType $type
	Add-AzDnsRecordConfig -Recordset $recordset -Value $value
	$RecordSetUpdate = Set-AzDnsRecordSet -Recordset $Recordset
}

#verify 365 domain
confirm-msoldomain -name $domain

#Add MX 365 Domain
$mxrecord = read-host "Enter MX record" 

$Records = @()
$Records += add-AzDnsRecordConfig -Exchange $mxrecord -Preference 1
Set-AzDnsRecordSet -RecordSet $RecordSet

$RecordSet = New-AzDnsRecordSet -Name "@" -RecordType MX -ResourceGroupName "rg-dns" -TTL 3600 -ZoneName $zone -DnsRecords $Records

#Add TXT from SPF.protection
$RG = $rg
$zone = $zone
$name = read-host "Enter TXT Name"
$type = "txt"
$value = "v=spf1 include:spf.protection.outlook.com -all"
$RecordSet = Get-AzDnsRecordSet -ResourceGroupName $rg -ZoneName $zone -Name $name -RecordType $type
Add-AzDnsRecordConfig -RecordSet $RecordSet -value $Value
Set-AzDnsRecordSet -RecordSet $RecordSet

#Add CNAME from Autodiscover
$Records = @()
$Records += New-AzDnsRecordConfig -Cname autodiscover.outlook.com
$RecordSet = New-AzDnsRecordSet -Name "autodiscover" -RecordType CNAME -ResourceGroupName $rg -TTL 3600 -ZoneName $zone -DnsRecords $Records

# These cmdlets can also be piped:
Get-AzDnsRecordSet -ResourceGroupName MyResourceGroup -ZoneName myzone.com -Name www -RecordType A | Add-AzDnsRecordConfig -Ipv4Address 172.16.0.0 | Add-AzDnsRecordConfig -Ipv4Address 172.31.255.255 | Set-AzDnsRecordSet