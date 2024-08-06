##### Lista permissão de um ou mais usuários em uma Subscrição específica e também nos Resource Groups
[string[]]$names = "email@dominio.com","email2@dominio.com"
$sub = Get-AzSubscription -SubscriptionName "SUBSCRIPTION"
$id = $sub.id

$rgs = Get-AzResourceGroup

foreach($name in $names){
        Write-Output ""
        Write-Output "Listando permissões do $name na Subscricao"
        Get-AzRoleAssignment -Scope "/subscriptions/$id" -SignInName $name | Select DisplayName, SignInName, RoleDefinitionName, Scope
        
        foreach($rg in $rgs){
            Write-Output ""
            Write-Output "Listando permissões do $name no Resource Groups $($rg.ResourceGroupName)"
            Get-AzRoleAssignment -SignInName $name -ResourceGroupName $rg.ResourceGroupName | Select DisplayName, SignInName, RoleDefinitionName, Scope
        }
}
