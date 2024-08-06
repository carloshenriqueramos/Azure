Install-Module AzureAD

Connect-AzureAD

$Groups = Import-Csv -Path 'C:\Temp\groups.csv'

# adicionando usuario aos grupos
foreach($Group in $Groups) {
    $grp = $Group.DisplayName
    
    $groupid = Get-AzureADGroup | Where-Object {$_.DisplayName -like "*$grp*"} 
    $useradd = Get-AzureADUser | select userprincipalname,objectid | where {$_.UserPrincipalName -eq "USUARIO@DOMAIN.COM"} 
    $users = $useradd.objectid

    foreach($user in $users){ 

        Add-AzureADGroupMember -ObjectId $groupid.ObjectId -RefObjectId $user 
    
    }
}