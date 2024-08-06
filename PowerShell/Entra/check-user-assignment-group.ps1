Install-Module AzureAD

Connect-AzureAD

$Groups = Import-Csv -Path 'C:\Temp\groups.csv'

# valida se o usuario faz parte dos grupos criados
foreach($Group in $Groups) {
    $grp = $Group.DisplayName
    
    $useradd = Get-AzureADUser | select userprincipalname,objectid | where {$_.UserPrincipalName -eq "USER@DOMAIN.COM"} 
    $users = $useradd.objectid

    Get-AzureADUserMembership -ObjectId $users | where {$_.DisplayName -like "*$grp*"}
}