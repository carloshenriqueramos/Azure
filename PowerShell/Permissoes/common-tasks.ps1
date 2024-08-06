##### Lista todas as Roles
Get-AzRoleDefinition | Format-Table -Property Name, IsCustom, Id

##### Lista usuários/grupos com permissão de uma Role específica
$roleassignmentname = (Get-AzRoleDefinition | where-object {$_.name -eq "Security Admin"}).Name

##### Permissões atribuídas a um recurso
$scoperesourceID = (Get-AzResource | Where-object {$_.name -eq "veeambackup21"}).ResourceID

##### Lista todas as Roles atribuídas a uma Subscrição
Get-AzRoleAssignment -Scope /subscriptions/{subscriptionId}

##### Lista todas as Roles atribuídas a um RG
$resourceGroupName = "myResourceGroup"
Get-AzRoleAssignment -ResourceGroupName $resourceGroupName

##### Lista todas as Roles atribuídas a um Usuário
$principalName = "user@azureis.fun"
Get-AzRoleAssignment -SignInName $principalName | Select-Object -ExpandProperty RoleDefinitionName

###### Add a role assignment to a user
$principalName = "user@azureis.fun"
$roleName = "Contributor"
$scope = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}"
New-AzRoleAssignment -SignInName $principalName -RoleDefinitionName $roleName -Scope $scope

###### Remove a role assignment for a user
$principalName = "user@azureis.fun"
$scope = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}"
Remove-AzRoleAssignment -SignInName $principalName -Scope $scope

###### Remove all role assignments for a specific user
$principalName = "user@azureis.fun"
Get-AzRoleAssignment -SignInName $principalName | Remove-AzRoleAssignment

###### List all built-in roles
Get-AzRoleDefinition | Where-Object { $_.IsCustom -eq $false }

###### List all custom roles
Get-AzRoleDefinition | Where-Object { $_.IsCustom -eq $true }

###### Create a custom role
$roleName = "CustomRole"
$roleDescription = "This is a custom role."
$actions = "Microsoft.Storage/storageAccounts/write"
$scope = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}"
New-AzRoleDefinition -Name $roleName -Description $roleDescription -Actions $actions -AssignableScopes $scope

###### Update a custom role
$roleName = "CustomRole"
$actionsToAdd = "Microsoft.Storage/storageAccounts/read"
$actionsToRemove = "Microsoft.Storage/storageAccounts/write"
$role = Get-AzRoleDefinition -Name $roleName
$role.Actions.Remove($actionsToRemove)
$role.Actions.Add($actionsToAdd)
Set-AzRoleDefinition -Role $role

###### Delete a custom role
$roleName = "CustomRole"
Remove-AzRoleDefinition -Name $roleName

###### List all users or groups assigned to a specific role
$roleName = "Contributor"
Get-AzRoleAssignment -RoleDefinitionName $roleName | Select-Object -ExpandProperty SignInName

###### List all permissions granted by a specific role
$roleName = "Contributor"
$roleDefinition = Get-AzRoleDefinition -Name $roleName
$roleDefinition.Actions

###### List all resource groups that a user has access to
$principalName = "user@azureis.fun"
Get-AzRoleAssignment -SignInName $principalName | Select-Object -ExpandProperty Scope | Get-AzResourceGroup

###### Create a role assignment for a service principal
$servicePrincipalId = "servicePrincipalId"
$roleName = "Contributor"
$scope = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}"
New-AzRoleAssignment -ServicePrincipalName $servicePrincipalId -RoleDefinitionName $roleName -Scope $scope
