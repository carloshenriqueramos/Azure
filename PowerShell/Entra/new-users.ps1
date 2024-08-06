Param
(
    [parameter(Mandatory=$true)]
    [string] $firstname,
    [parameter(Mandatory=$true)]
    [string] $lastname,
    [parameter(Mandatory=$true)]
    [string] $city,
    [parameter(Mandatory=$true)]
    [string] $phone,
    [parameter(Mandatory=$true)]
    [string] $pw

)
$displayname = $firstname + " " + $lastname
$upn = "$firstname.$lastname" + "@rios.engineer"
New-ADUser -Name $displayname `
-SamAccountName "$firstname.$lastname" `
-UserPrincipalName $upn `
-DisplayName $displayname `
-GivenName $firstname `
-Surname $lastname `
-City $city `
-OfficePhone $phone `
-AccountPassword (ConvertTo-SecureString $pw -AsPlainText -Force) `
-Enabled:$true `
-Server az-dc-01 `
-Path "OU=Employees,DC=contoso,DC=ad" `
