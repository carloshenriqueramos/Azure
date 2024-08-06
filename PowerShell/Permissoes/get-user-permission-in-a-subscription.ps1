##### Lista permissão de um ou mais usuários em uma Subscrição específica

[string[]]$names = "email@dominio.com","email2@dominio.com"

$sub = Get-AzSubscription -SubscriptionName "SUBSCRIPTION"
$id = $sub.id

foreach($name in $names){
        Get-AzRoleAssignment -Scope "/subscriptions/$id" -SignInName $name | Select DisplayName, SignInName, RoleDefinitionName, Scope
}  

