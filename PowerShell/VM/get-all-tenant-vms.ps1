     $report = @()
     $subs = Get-AzSubscription
     Foreach ($sub in $subs)
         {
         select-AzSubscription $sub | Out-Null
         $subName = $sub.Name
            
         $vms = Get-AzVM
         $publicIps = Get-AzPublicIpAddress 
         $nics = Get-AzNetworkInterface | ?{ $_.VirtualMachine -NE $null} 
         foreach ($nic in $nics) { 
             $info = "" | Select VmName, ResourceGroupName, Region, VmSize, VirtualNetwork, PrivateIpAddress, OsType, PublicIPAddress, Subscription, Cores, Memory, CreatedDate
             $vm = $vms | ? -Property Id -eq $nic.VirtualMachine.id 
             foreach($publicIp in $publicIps) { 
                 if($nic.IpConfigurations.id -eq $publicIp.ipconfiguration.Id) {
                     $info.PublicIPAddress = $publicIp.ipaddress
                     } 
                 } 
                 [string]$sku = $vm.StorageProfile.ImageReference.Sku
                 [string]$os = $vm.StorageProfile.ImageReference.Offer
                 $osDiskName = $vm.StorageProfile.OsDisk.Name
                 $info.VMName = $vm.Name 
                 $info.OsType = $os + " " + $sku
                 $info.ResourceGroupName = $vm.ResourceGroupName 
                 $info.Region = $vm.Location
                 $vmLocation = $vm.location 
                 $info.VmSize = $vm.HardwareProfile.VmSize
                 $info.VirtualNetwork = $nic.IpConfigurations.subnet.Id.Split("/")[-3] 
                 $info.PrivateIpAddress = $nic.IpConfigurations.PrivateIpAddress 
                 $info.Subscription = $subName
                 if ($vmLocation)
                     {
                     $sizeDetails = Get-AzVMSize -Location $vmLocation | where {$_.Name -eq $vm.HardwareProfile.VmSize}
                     }
                 $info.Cores = $sizeDetails.NumberOfCores
                 $info.Memory = $sizeDetails.MemoryInMB
                 $osDisk = Get-AzDisk -ResourceGroupName $vm.ResourceGroupName -DiskName $osDiskName
                 $info.CreatedDate = $osDisk.TimeCreated
                 $report+=$info
                 } 
         }
     $report | export-csv c:\temp\VMs.csv -notypeinformation 