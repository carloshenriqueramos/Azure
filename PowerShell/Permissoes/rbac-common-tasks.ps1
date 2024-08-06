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