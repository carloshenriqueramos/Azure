##### Lista todas as Roles
Get-AzRoleDefinition | Format-Table -Property Name, IsCustom, Id

##### Lista usuários/grupos com permissão de uma Role específica
$roleassignmentname = (Get-AzRoleDefinition | where-object {$_.name -eq "Security Admin"}).Name

##### Permissões atribuídas a um recurso
$scoperesourceID = (Get-AzResource | Where-object {$_.name -eq "veeambackup21"}).ResourceID

##### Lista todas as Roles atribuídas a uma Subscrição
Get-AzRoleAssignment -Scope /subscriptions/{subscriptionId}

##### Lista todas as Roles atribuídas a todos os Resource Groups
Get-AzResource | foreach-object {Get-AzRoleAssignment -ResourceGroupName $_.Name}

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

#Create new role assignment single user
$user = read-host "Insert User"
$scope = read-host "Insert Assignment Scope"
$role = read-host "Insert User Role"
New-azroleassignment -signinname $user -scope $scope -roledefinitionname $role

#Create new role assignment single group
$group = read-host "Insert GroupID"
$scope = read-host "Insert Assignment Scope"
$role = read-host "Insert User Role"
New-azroleassignment -objectid $group -scope $scope -roledefinitionname $role

#assign bulk users in same role and scope(need to get resource ID before)
$arquivo = get-content c:\temp\users.txt
$role = read-host "Insert User Role"
$scope = read-host "Inser Assignment Scope"
foreach ($user in $arquivo) {
	New-azroleassignment -signinname $user -scope $scope -roledefinitionname $role
}

#Assign bulk user in same role with multiple scopes
$role = read-host "Insert User Role"
$scope = read-host "Inser Assignment Scope"
$resources = @()
foreach($resource in get-content c:\temp\resources.txt){
	$resources += get-azresource -name $resource
	foreach($scope in $resources.resourceid){
		foreach($user in get-content c:\temp\users.txt){
			New-azroleassignment -signinname $user -scope $scope -roledefinitionname $role
		}
	}
}

#check all role assignments in all subscriptions and remove
$warningpreference = "Silentlycontinue"
$user = read-host "Insert User"
$Subscriptions = Get-AzSubscription
foreach ($sub in $Subscriptions) {
    Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext
	Remove-azroleassignment -signinname $user
}
$warningpreference = "Continue"

#Mass assignment same sub webapp
$scope = @()
foreach($web in get-content c:\temp\webapps.txt){
	$scope += (Get-AzWebApp -Name $web).id
}
$webapps = $scope 
foreach ($webapp in $webapps) {
	foreach($user in $arquivo){
		New-azroleassignment -signinname $user -scope $webapp -roledefinitionname "Website Contributor"
	}
}

#check user role assignments
$user = read-host "Insert User"
$userroles = Get-AzRoleAssignment -signinname $user | select signinname,roledefinitionname,scope
$userroles

#check user role assignments in all subscriptions
$user = read-host "Insert User"
$warningpreference = "Silentlycontinue"

$Subscriptions = Get-AzSubscription
$userroles = @()
foreach ($sub in $Subscriptions) {
$subname = $sub.name
write-progress "Searching assignments for $user in subscription $subname"
    Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext
$userroles += Get-AzRoleAssignment -signinname $user | select signinname,roledefinitionname,scope,@{n="SubscriptionName";e={$sub.name}}
}
$userroles
$warningpreference = "Continue"

#Remove Permissions from last script
foreach($role in $userroles){
	Remove-AzRoleAssignment -SignInName $user -Scope $role.scope -RoleDefinitionName $role.roledefinitionname
}

#Mirror User role Assignments in all subscriptions - Use it together with last script
$user2 = read-host "Insert user who will receive access"
foreach($role in $userroles){
	New-azroleassignment -signinname $user2 -scope $role.scope -roledefinitionname $role.roledefinitionname
}