#Install the Microsoft Graph PowerShell SDK module
Install-Module Microsoft.Graph -Verbose -AllowClobber -Force

#Authenticate with your Entra ID account
Connect-MgGraph -Scope 'Application.ReadWrite.All'

#Get all applications
$applications = Get-MgApplication -All

#Create an array to store the output
$output = @()

#Loop through each application
foreach ($app in $applications) {
    #Get the service principal for the application
    $servicePrincipal = Get-MgServicePrincipal -Filter "appId eq '$($app.AppId)'"

    #Add the application name and service principal ObjectId to the output array
    $output += New-Object PSObject -Property @{
        "App Name" = $app.DisplayName
        "ObjectId" = $servicePrincipal.Id
    }
}

#Output the array in a table format
$output | Format-Table

#############################################
#Remove all users assigned to the application
#############################################

#Get Service Principal using objectId
$sp = Get-MgServicePrincipal -ServicePrincipalId 46ddcaa9-ef22-42cb-b569-50df47cea6e1

#Get MS Graph App role assignments using objectId of the Service Principal
$assignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $sp.Id -All

$assignments | Select-Object PrincipalDisplayName

#Remove all users and groups assigned to the application
$assignments | ForEach-Object {
    if ($_.PrincipalType -eq "User") {
        Remove-MgUserAppRoleAssignment -UserId $_.PrincipalId -AppRoleAssignmentId $_.Id
    } elseif ($_.PrincipalType -eq "Group") {
        Remove-MgGroupAppRoleAssignment -GroupId $_.PrincipalId -AppRoleAssignmentId $_.Id
    }
}

####################################
#Revoke refresh tokens for all users
####################################

#Get Service Principal using objectId
$sp = Get-MgServicePrincipal -ServicePrincipalId 46ddcaa9-ef22-42cb-b569-50df47cea6e1

#Get MS Graph App role assignments using objectId of the Service Principal
$assignments = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $sp.Id -All | Where-Object {$_.PrincipalType -eq "User"}

$assignments | Format-List

#Revoke refresh token for all users assigned to the application
$assignments | ForEach-Object {
    Invoke-MgInvalidateUserRefreshToken -UserId $_.PrincipalId
}

##################################################
#Revoke all permissions granted to the application
##################################################

#Get Service Principal using objectId
$sp = Get-MgServicePrincipal -ServicePrincipalId 46ddcaa9-ef22-42cb-b569-50df47cea6e1

#Get all delegated permissions for the service principal
$spOAuth2PermissionsGrants = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $sp.Id -All

#Remove all delegated permissions
$spOAuth2PermissionsGrants | ForEach-Object {
    Remove-MgOauth2PermissionGrant -OAuth2PermissionGrantId $_.Id
}

#Get all application permissions for the service principal
$spApplicationPermissions = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id

#Remove all app role assignments
$spApplicationPermissions | ForEach-Object {
    Remove-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $_.PrincipalId -AppRoleAssignmentId $_.Id
}

#### ------------------------------
Connect-AzureAD -TenantId "e0397d98-3001-4e83-a25f-3327178c3e19"

$appName = "chrteste"
$user = "adm.carloshr_hotmail.com#EXT#@admcarloshrhotmail.onmicrosoft.com"

$userId = (Get-AzureADUser | where {$_.UserPrincipalName -eq $user}).ObjectId

$samlApp = New-AzureADApplication -DisplayName $appName `  
                       -IdentifierUris "https://myapp.domain.com" `  
                       -ReplyUrls "https://myapp.domain.com/sso"
  
#####
Add-AzureADApplicationOwner -ObjectId $samlApp.ObjectId -RefObjectId $userId


New-AzureADServicePrincipal -DisplayName $appName `  
                       -IdentifierUris "https://myapp.domain.com" `  
                       -ReplyUrls "https://myapp.domain.com/sso"

# -----------

$appName = "SAMLAppTest1"  
$samlApp = New-AzureADApplication -DisplayName $appName `  
                       -IdentifierUris "http://mynewapp.contoso.com" `  
                       -SamlMetadataURL "http://mynewapp.contoso.com/metadata.xml" `  
                       -ReplyUrls "http://mynewapp.contoso.com/finishLogin"  
  
Get-AzureADApplication -SearchString $appName  
  
New-AzureADServicePrincipal -AccountEnabled $true `  
                            -AppId $samlApp.AppId `  
                            -AppRoleAssignmentRequired $true `  
                            -DisplayName $appName `  
                            -Tags {WindowsAzureActiveDirectoryIntegratedApp}  
  
Get-AzureADServicePrincipal -SearchString $appName 