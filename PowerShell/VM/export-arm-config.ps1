<#
.SYNOPSIS
Export current arm config.
.DESCRIPTION
Export current arm config json.
.NOTES
Name: Azure-export-arm-config
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)

Requires Module AzureRM

#>

#Set up your variables: $subscriptionID = "<SUBSCRIPTION ID>" 
$rgname = "myResourceGroup" 
$vmname = "myVMName"  

#Stop deallocate the VM 
Stop-AzVM -ResourceGroupName $rgname -Name $vmname  
    
#Export the JSON file;  
Get-AzVM -ResourceGroupName $rgname -Name $vmname |ConvertTo-Json -depth 100|Out-file -FilePath c:\temp\$vmname.json