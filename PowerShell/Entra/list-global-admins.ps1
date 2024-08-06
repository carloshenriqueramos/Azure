Set-Location c:\
Clear-Host

#We need the cmdlets
Install-Module -Name AzureAD -AllowClobber -Force -Verbose

#Sometimes the module must be imported
Import-Module AzureAD

#Lets connect to the Azure Active Directory
Connect-AzureAD

#Azure AD Role information
$CompanyAdminRole = Get-AzureADDirectoryRole | Where-Object {$_.DisplayName -eq "Global administrator"}

#Get members
Get-AzureADDirectoryRoleMember -ObjectId $CompanyAdminRole.ObjectId