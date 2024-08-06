$registeredApps=Get-AzureADApplication -All:$true | select appId, displayName
#$appSignIns=Get-AzureADAuditSignInLogs -Filter "createdDateTime gt 2021-09-21 and appDisplayName eq 'CBA - Meritum Compliance'" | select AppId, AppdisplayName, createdDateTime
$appsArray=@()
foreach ($appName in $registeredApps.displayName) {
    $appSignIns=Get-AzureADAuditSignInLogs -Filter "createdDateTime gt 2021-09-21 and appDisplayName eq '$appName'" | select AppId, AppdisplayName, createdDateTime
    if ($appSignIns.count -gt 0)
   {
    write-host "Application" $appName "had" $appSignIns.count "sign-ins." -ForegroundColor Yellow -BackgroundColor DarkGreen
    $appName.AppdisplayName | Out-File c:\temp\AppWithSignIns.csv -Append
    }
   else
        {
    write-host "Application" $appName "had no sign-ins." -ForegroundColor Yellow -BackgroundColor DarkRed
    $appName | Out-File c:\temp\AppWithoutSignIns.csv -Append
        }
}