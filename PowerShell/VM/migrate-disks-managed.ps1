## First Step : Define VM 
$rgName = "RG-SPSDEVQA"
$vmName = "AZRWCSPS02QA"
 
## Second Step : Check VM Backup
 
#Check if VM is BackedUp
Get-AzRecoveryServicesBackupStatus -name $vmname -ResourceGroupName $rgname -Type AzureVM | fl
 
#Check Backup Status
$namedContainer=Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -friendlyname $vmname
 
$item = Get-AzRecoveryServicesBackupItem -Container $namedContainer -WorkloadType "AzureVM"
$bkppolicy = $item.ProtectionPolicyName
$result = @()
$Result  += New-Object PSObject -property $([ordered]@{ 
Vault = $vault.name
VM = $vm
BackupPolicy = $bkppolicy
LastBackuptime = $item.lastbackuptime
LastbackupStatus = $item.lastbackupstatus
LatestRecoveryPoint = $item.latestrecoverypoint
})
$result
 
#If Needed, run a manual backup to be kept for the needed time
$DaysForBackupToBeKept = "7"
$todaydate = get-date 
$expirydate = $todaydate.AddDays($DaysForBackupToBeKept)
Backup-AzRecoveryServicesBackupItem -item $item -ExpiryDateTimeUTC $expirydate
 
##Start the Disk Migration Itself
#Check VM Status - Needs to be Deallocated
get-azvm -name $vmname -status | select name,resourcegroupname,powerstate
 
#Deallocate VM if Needed
Stop-AzVM -ResourceGroupName $rgName -Name $vmName -Force
 
#Start Migration Job - VM will be started automatically after - ALL VM disks are migrated
ConvertTo-AzVMManagedDisk -ResourceGroupName $rgName -VMName $vmName