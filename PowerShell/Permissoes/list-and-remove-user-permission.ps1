##### Lista permissões e remove

$user = "email@dominio.com"
$subs = Get-AzSubscription | Where {$_.State -eq "Enabled"} | Select-Object -ExpandProperty SubscriptionId

foreach($sub in $subs){
        Set-AzContext -SubscriptionId $sub

        try {
    
                $roles = Get-AzRoleAssignment -Scope "/subscriptions/$sub" -ErrorAction SilentlyContinue

                foreach ($role in $roles) {
                    if ($role.SignInName -eq $user){
                        Write-Output "Found role assignment $($role.RoleDefinitionName) for $($role.DisplayName) in subscription $($sub)"
                        
                        Write-Output "Removing role assignment $($role.RoleDefinitionName) for $($role.DisplayName) in subscription $($sub)"
                        Remove-AzRoleAssignment -ObjectId $role.ObjectId -Scope $role.Scope -RoleDefinitionName $role.RoleDefinitionName          
                    }
    
                }
            }

        catch {
            Write-Error "Error processing subscription-level assignments for subscription $($sub): $_"
        }
}
