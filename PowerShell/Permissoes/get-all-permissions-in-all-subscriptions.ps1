##### Lista permissão de um ou mais usuários em todas Subscrições

Connect-AzAccount

[string[]]$names = "email@dominio.com","email2@dominio.com"

$subs = Get-AzSubscription | Where {$_.State -eq "Enabled"}

$allAccess = @()

foreach ($sub in $subs) 
{
    Select-AzSubscription -SubscriptionId $sub.Id
    # change azure subscription
    [void](Set-AzContext -SubscriptionID $sub)
    $currentSubscription = ($subs | Where { $_.SubscriptionId -eq $sub })
    $subscriptionName = $currentSubscription.SubscriptionName
    if([String]::IsNullOrEmpty($subscriptionName)) {
        $subscriptionName = $currentSubscription.Name
    }
            
            foreach($name in $names){
                
                $permissions = Get-AzRoleAssignment -SignInName $name | Select @{N='Subscription';E={$sub.Name}}, DisplayName, SignInName, RoleDefinitionName  
                
                    foreach($permission in $permissions){
                            $customPsObject = New-Object -TypeName PsObject
                            $customPsObject | Add-Member -MemberType NoteProperty -Name SubscriptionName -Value $permission.Subscription
                            $customPsObject | Add-Member -MemberType NoteProperty -Name DisplayName -Value $permission.DisplayName
                            $customPsObject | Add-Member -MemberType NoteProperty -Name SignInName -Value $permission.SignInName
                            $customPsObject | Add-Member -MemberType NoteProperty -Name RoleDefinitionName -Value $permission.RoleDefinitionName
                            $allAccess += $customPsObject
                    }
            }
}

$allAccess | where {$_.RoleDefinitionName -eq "Billing Reader"} | Export-Csv 'C:\Temp\permissoes.csv' -NoTypeInformation

