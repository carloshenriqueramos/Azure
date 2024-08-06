$webapps = @()
$Subscriptions = Get-AzSubscription

foreach ($sub in $Subscriptions) {
    Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext
    $webapps += get-azwebapp 
}
 
$output = @()

foreach($webapp in $webapps){
 
    $output += New-Object PSObject -property $([ordered]@{ 
        Name = $webapp.name
        Hostnames = $webapp.hostnames -join ","
        State = $webapp.state
        Location = $webapp.Location
        Kind = $webapp.Kind
        Type = $webapp.Type
        })
}
$output | where-object {$_.hostnames -like "*votorantim*"} | ft 