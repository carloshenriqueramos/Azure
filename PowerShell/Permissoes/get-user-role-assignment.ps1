#Loop through all subscriptions to get user Roles
$warningpreference = "Silentlycontinue"
$Subscriptions = Get-AzSubscription
$user = read-host "Insert user"
foreach ($sub in $Subscriptions) {
    Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext
Get-azroleassignment -signinname $user| FT Signinname,@{n="Subscription";e={$sub.Name}},Roledefinitionname,scope
}
$warningpreference = "Continue"