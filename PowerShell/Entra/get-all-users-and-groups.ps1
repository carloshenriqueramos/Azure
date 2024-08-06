$users = Get-AzureADUser -All $true

$results = @()

foreach ($user in $users) {
    $userGroups = Get-AzureADUserMembership -ObjectId $user.ObjectId
	$result = [PSCustomObject]@{
		UserPrincipalName = $user.UserPrincipalName
		DisplayName = $user.DisplayName
		Groups = ($userGroups | ForEach-Object { $_.DisplayName }) -join ', '
	}
	$results += $result
}
$results | Export-Csv -Path C:\UserGroupMemberships.csv -NoTypeInformation