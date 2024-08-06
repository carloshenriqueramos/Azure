[string[]]$names = "email@dominio.com","email2@dominio.com"
$subs = Get-AzSubscription | Where {$_.State -eq "Enabled"} | Select-Object -ExpandProperty SubscriptionId
foreach($sub in $subs){
    Set-AzContext -SubscriptionId $sub
    foreach($name in $names){
        Get-AzRoleAssignment -Scope "/subscriptions/$sub" -SignInName $name | Select DisplayName, SignInName, RoleDefinitionName, Scope
    }   
}
