$result = @()
#get all the Log Analytics Workspace 
$all_workspace = Get-AzOperationalInsightsWorkspace


#here, I hard-code a vm name for testing purpose. If you have more VMs, you can modify the code below using loop.
foreach($vm in get-content c:\temp\VMs.txt){
$vmproperties = get-azvm -name $vm
$myvm_name = $VMproperties.name
$myvm_resourceGroup= $VMproperties.ResourceGroupName
$myvm_OS = $vmproperties.StorageProfile.ImageReference
$osver = $vmproperties.StorageProfile.ImageReference.Offer
$osver2 = $vmproperties.StorageProfile.ImageReference.Sku


If($osver -ne "WindowsServer"){
#for windows vm, the value is fixed as below
$extension_name = "OmsAgentForLinux"

$myvm = Get-AzVMExtension -ResourceGroupName $myvm_resourceGroup -VMName $myvm_name -Name $extension_name -erroraction SilentlyContinue

$workspace_id = ($myvm.PublicSettings | ConvertFrom-Json).workspaceId 

#$workspace_id

foreach($w in $all_workspace)
{
if($w.CustomerId.Guid -eq $workspace_id)
  { 
  #here, I just print out the vm name and the connected Log Analytics workspace name
  Write-Output "the vm: $($myvm_name) writes log to Log Analytics workspace named: $($w.name)"
  

$Result += New-Object PSObject -property $([ordered]@{ 
myvm_name = $VMproperties.name
myvm_resourceGroup= $VMproperties.ResourceGroupName
MyVm_OsVMType = $osver
myvm_OSSku = $osver2
LAW = $($w.name)
})
  }
}
}
elseIf ($osver -eq "windowsserver"){
#for windows vm, the value is fixed as below
$extension_name = "MicrosoftMonitoringAgent"

$myvm = Get-AzVMExtension -ResourceGroupName $myvm_resourceGroup -VMName $myvm_name -Name $extension_name -erroraction SilentlyContinue

$workspace_id = ($myvm.PublicSettings | ConvertFrom-Json).workspaceId 

#$workspace_id

foreach($w in $all_workspace)
{
if($w.CustomerId.Guid -eq $workspace_id)
  { 
  #here, I just print out the vm name and the connected Log Analytics workspace name
  Write-Output "the vm: $($myvm_name) writes log to Log Analytics workspace named: $($w.name)"
  

$Result += New-Object PSObject -property $([ordered]@{ 
myvm_name = $VMproperties.name
myvm_resourceGroup= $VMproperties.ResourceGroupName
MyVm_OsVMType = $osver
myvm_OSSku = $osver2
LAW = $($w.name)
})
  }
}
}
}