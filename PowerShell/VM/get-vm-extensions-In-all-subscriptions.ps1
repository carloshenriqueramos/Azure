$vmextensions = @()

foreach($sub in $subs){
    set-azcontext $sub.id
    $vms = get-azvm -status

        foreach($vm in $vms){
            $vmOSoffer = $vm.storageprofile.imagereference.offer
            $vmOSsku = $vm.storageprofile.imagereference.sku
            $vmOSPublisher = $vm.storageprofile.imagereference.Publisher
            $vmOS = $vm.StorageProfile.OsDisk.OsType
            $VMOsName = $Vm.OsName 
            $VmOsVersion = $vm.OsVersion
            $vmstate = $vm.Powerstate
            $vmextensions += get-azvmextension -vmname $vm.name -resourcegroupname $vm.resourcegroupname | select @{n="Subscription";e={$sub.Name}},vmname,resourcegroupname,location,publisher,name,extensiontype,provisioningstate,@{n="OS Type";e={$vmOS}},@{n="OS Name";e={$vmOsName}},@{n="OS Version";e={$vmOSVersion}},@{n="OS Publisher";e={$vmOSPublisher}},@{n="OS Offer";e={$vmOSoffer}},@{n="OS SKU";e={$vmOSSku}},@{n="VM State";e={$vmstate}}
        }
}
