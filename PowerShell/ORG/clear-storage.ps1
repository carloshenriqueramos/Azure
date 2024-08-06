# setup
#import-module az
#import-module az.storage
# creds
#connect-azaccount
#
# set up array of subs



$subs= ‘<subscription ID>’, ‘<subscription ID>’

# today
$nowdate = Get-Date



#initialise output



$stgdata =@()




Write-Host “Enumerating” $subs.count “subscription(s)”



# loop through the subscription(s)



foreach ($subscription in $subs) {
# in subscription, next read the storage accounts
#set context
write-host “Switching to subscription” $subscription
set-azcontext -subscription $subscription |out-null
write-host “enumerating storage accounts”
$stgacclist = get-azstorageaccount
write-host “Total of” $stgacclist.count “storage accounts in subscription” $subscription



# loop through each storage account



foreach ($stgacc in $stgacclist) {
# in storage account, get all storage containers, tables and queues
# stgacc entity has StorageAccountNme and ResourceGroupName and tags



set-azcurrentstorageaccount -Name $stgacc.StorageAccountName -ResourceGroupName $stgacc.ResourceGroupName



write-host “enumerating storage account ” $stgacc.StorageAccountName ” in resource group” $stgacc.ResourceGroupName
write-host “storage containers”
$stgcontainers = get-azstoragecontainer
write-host “table service”
$tblservice = get-azstoragetable
write-host “queue service”
$qservice = get-azstoragequeue




#get transactions



$transactions = Get-AzMetric -ResourceId $stgacc.id -TimeGrain 0.1:00:00 -starttime ((get-date).AddDays(-60)) -endtime (get-date) -MetricNames “Transactions” -WarningAction SilentlyContinue
write-host “60 days of transactions” $(($transactions.Data | Measure-Object -Property total -Sum).sum)



#reset usage array
$lastused = @()



#loop through each blob service container
foreach ($container in $stgcontainers) {
# in blob storage container
write-host “collecting blob storage data”



$lastused += [PSCustomObject]@{
Subscription = $subscription
ResourceGroup = $stgacc.ResourceGroupName
StorageAccount = $stgacc.StorageAccountName
StorageContainer = $container.name
LastModified = $container.lastmodified.Date
Age = ($nowdate – $container.LastModified.Date).Days



}



#let’s find any unmanaged disks in the container
$allblobs = get-azstorageblob -container $container.name
$vhdblobs = $allblobs | Where-Object {$_.BlobType -eq ‘PageBlob’ -and $_.Name.EndsWith(‘.vhd’)}



}



write-host “Total of ” $stgcontainers.count “containers. Minimum age ” ($lastused.Age |Measure -Minimum).minimum “maximum age” ($lastused.Age |Measure -Maximum).maximum



#append to the array



$stgdata += [PSCustomObject]@{
Subscription = $subscription
ResourceGroup = $stgacc.ResourceGroupName
StorageAccount = $stgacc.StorageAccountName
Transactions = $(($transactions.Data | Measure-Object -Property total -Sum).sum)
ContainerCount = $stgcontainers.Count
TableCount = $tblservice.Count
QueueCount = $qservice.Count
AgingMin = ($lastused.Age |Measure -Minimum).minimum
AgingMax = ($lastused.Age |Measure -Maximum).maximum
vhd = $vhdblobs.count
blobs = $allblobs.count



#tag metadata
itowner = $stgacc.tags.itowner
businessowner = $stgacc.tags.businessowner
application =$stgacc.tags.application
costcenter = $stgacc.tags.costcenter



}
}
}
#output to csv



$stgdata | export-csv <somelocation>\storageacc.csv -force -NoTypeInformation