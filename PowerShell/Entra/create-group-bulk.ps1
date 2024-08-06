Install-Module AzureAD

Connect-AzureAD

$Groups = Import-Csv -Path 'C:\Temp\groups.csv'

# criando grupos 
foreach($Group in $Groups) {

    New-AzureADMSGroup -DisplayName $Group.DisplayName -Description $Group.Description -MailEnabled $False -MailNickName "group" -SecurityEnabled $True

} 

# exibe os grupos criados
foreach($Group in $Groups) {
    $grp = $Group.DisplayName
    
    Get-AzureADGroup | where {$_.DisplayName -like "*$grp*"}
}