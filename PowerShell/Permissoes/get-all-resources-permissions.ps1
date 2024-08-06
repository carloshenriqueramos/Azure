Get-AzResource | foreach-object {Get-AzRoleAssignment -ResourceGroupName $_.Name}
