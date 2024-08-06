$rgName = read-host "Insert Resource Group Where the Data disk will be created"
$vmName = read-host "Insert the VM where disk will be attached"
$location = read-host "Insert the region where disk will be created" #Use Get-azlocation to get all available Azure Regions for selected Subscription
$storageType = read-host "Insert the disk SKU" #Available values are Standard_LRS, Premium_LRS, StandardSSD_LRS, and UltraSSD_LRS, Premium_ZRS and StandardSSD_ZRS.
$disksize = read-host "Insert Disk Size in GB"
$dataDiskName = $vmName + '_datadiskname'

#Use the Below Script to get LUNs in use for the VM
$vm = Get-AzVM -ResourceGroupName $rgname -Name $vmname 
$vmLUN = $vm.StorageProfile.DataDisks 
$vmLUN | select name,disksizegb,lun

$lun = read-host "Insert the LUN where the disk will be attached" 

$diskConfig = New-AzDiskConfig -SkuName $storageType -Location $location -CreateOption Empty -DiskSizeGB $disksize
$dataDisk1 = New-AzDisk -DiskName $dataDiskName -Disk $diskConfig -ResourceGroupName $rgName

$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName
$vm = Add-AzVMDataDisk -VM $vm -Name $dataDiskName -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 4

Update-AzVM -VM $vm -ResourceGroupName $rgName
