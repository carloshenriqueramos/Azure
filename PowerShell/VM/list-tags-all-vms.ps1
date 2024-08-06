Connect-AzAccount

$Subscription = Select-AzSubscription -SubscriptionName "SUBNAME"

    # Get all of the VM's:
    ($rmvms=Get-AzVM) > 0
    
foreach ($vm in $rmvms)
    {    
        # Get status (does not seem to be a property of $vm, so need to call Get-AzurevmVM for each rmVM)
        $vmstatus = Get-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Status

        # Add values to the array:
        $vmarray += New-Object PSObject -Property @{`
            Subscription=$subscription.SubscriptionName; `
            AzureMode="Resource_Manager"; `
            Name=$vm.Name; PowerState=(get-culture).TextInfo.ToTitleCase(($vmstatus.statuses)[1].code.split("/")[1]); `
            Tags=$vm.tags;}
    }


$vmarray |select -ExpandProperty "Name,tags" | Out-File C:\Temp\Tags.txt