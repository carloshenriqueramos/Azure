#CertificateValidation
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

elseif($dnsrecordset -ne $null){
    $value = read-host "Enter Verification DNS Value"
    Write-host "Value for Verification is $value"
    $name = read-host "Enter TXT Name"
    $type = "TXT"
    $Records = @()
    $recordset = Get-AzDnsRecordSet -ResourceGroupName $RG -ZoneName $zone -Name $name -RecordType $type
    Add-AzDnsRecordConfig -Recordset $recordset -Value $value
    $RecordSetUpdate = Set-AzDnsRecordSet -Recordset $Recordset
}

# Verificar refresh na verificacao por linha de comando
#----------------------------------------------

#Add CNAME CustomDomainVerification
$rg = read-host "Insert ResourceGroupName"
$zone = read-host "Insert Zone Name"
$fqdn= read-host "Insert custom domain"
$webappname= read-host "Insert WebApp Name"
Write-Host "Configure a CNAME record that maps $fqdn to $webappname.azurewebsites.net"
$namecname = read-host "Insert CNAME record Name"
New-AzDnsRecordSet -Name $namecname -RecordType CNAME -ZoneName $zone -ResourceGroupName $rg -Ttl 3600 -DnsRecords (New-AzDnsRecordConfig -Cname "$webappname.azurewebsites.net")
#----------------------------------------------

# Add a custom domain name to the web app. 
$rg = read-host "Insert ResourceGroupName"
Set-AzWebApp -Name $webappname -ResourceGroupName $rg `
-HostNames @($fqdn,"$webappname.azurewebsites.net") -HttpsOnly $true

#-----------------------------------------------------------------------------

# Upload and bind the SSL certificate to the web app.
$rg = read-host "Insert ResourceGroupName"
$pfxPath= read-host "Insert PFX Certificate Path"
$pfxPassword= read-host "Insert PFX Certificate Password"
$rg = read-host "Insert ResourceGroup Name"
New-AzWebAppSSLBinding -WebAppName $webappname -ResourceGroupName $rg -Name $fqdn `
-CertificateFilePath $pfxPath -CertificatePassword $pfxPassword -SslState SniEnabled 

#--------------------------------------------------
