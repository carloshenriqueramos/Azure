Connect-AzAccount

# Select Azure Subscription

    $subscriptionId = 
        (Get-AzSubscription |
         Out-GridView `
            -Title "Select an Azure Subscription ..." `
            -PassThru).SubscriptionId

    Select-AzSubscription `
        -SubscriptionId $subscriptionId

# Select Azure Resource Group 

    $rgName =
        (Get-AzResourceGroup |
         Out-GridView `
            -Title "Select an Azure Resource Group ..." `
            -PassThru).ResourceGroupName

# Select Azure VM

    $vmName = 
        (Get-AzVm -ResourceGroupName $rgName |
         Out-GridView `
            -Title "Select an Azure VM ..." `
            -PassThru).Name

# Get Azure VM Object

    $vm = 
        Get-AzVm `
            -ResourceGroupName $rgName `
            -Name $vmName

# Get New Azure VM Size for scale-up or scale-down

    $currentVmSize = $vm.HardwareProfile.VmSize

    $vmFamily = $currentVmSize -replace '[0-9]', '*'

    $newVmSize =
        (Get-AzVMSize `
            -Location $vm.Location
        ).Name |
        Where-Object {$_ -Like $vmFamily} |
        Out-GridView `
            -Title "Select a new VM Size ..." `
            -PassThru

    $vm.HardwareProfile.VmSize = $newVmSize

    $vm | Update-AzureRmVM 
