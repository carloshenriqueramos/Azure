#requires -Version 5.0 -Module Az.Monitor,Az.Accounts
<#PSScriptInfo
.VERSION 0.4
.GUID aaa68dab-9130-4c5d-83cc-f5f19b61b12f
.DESCRIPTION This is a script to find the basic details of Azure VM's that have been stopped in a subscription.
.AUTHOR Ayan Mullick
.COMPANYNAME Ayan Mullick LLC
.TAGS AzCompute AzVM Infra-Report
.LICENSEURI https://choosealicense.com/licenses/mit/
.PROJECTURI https://dev.azure.com/ayn/PowerShell/_git/AzIaaS?path=%2FGet-AzVMStopActivity.ps1&version=GBmain
#>

<#
.Synopsis
   This is a script to find the basic details of Azure VM's that have been stopped from a subscription. It iterates for each unique VM stop activity and tries to locate the VM and NIC creation activity log if the VM was created within 90 days.One needs read access to a subscription to run this script.
.EXAMPLE
   Login-AzAccount -Tenant <Tenantid> -Subscription <Subscriptionid>
   Get-AzVMStopActivity
   This will log you into the desired subscription and get the list of Azure VM's stopped from the default context.
.EXAMPLE
   Get-AzVMStopActivity.ps1 -SubscriptionId <Subscription Id> -WarningAction SilentlyContinue
   One can specify the subscription id in the -SubscriptionId parameter and suppress any warnings related to upcoming changes in the Azure PowerShell cmdlets.
.EXAMPLE
   '<Subscription Id>'|Get-AzVMStopActivity.ps1
   One can pipe a subscription id to the cmdlet too.
.EXAMPLE
   (Get-AzSubscription).id|ForEach-Object {Get-AzVMStopActivity.ps1 -SubscriptionId $PSItem -WarningAction SilentlyContinue}
   One can use the Foreach-Object cmdlet to get the VM deletion list from all the subscriptions one has access to.
.EXAMPLE
   $VMstop=(Get-AzSubscription).id|ForEach-Object -Parallel {Get-AzVMStopActivity.ps1 -SubscriptionId $PSItem -WarningAction SilentlyContinue}
   $VMstop|? OsType -NE 'Linux'|Export-Csv -Path C:\Temp\Vmdeletion.csv
   This will query all the subscriptions in the tenant for the list of deleted VM's in parallel, filter for OSType and export the list to a CSV file.
.NOTES
   One can IM ayan@mullick.in on Teams if one needs to add parameters to it.
#>

[CmdletBinding()]
param([Parameter(ValueFromPipeline=$true)] [ArgumentCompleter({return $(Get-AzSubscription).Id} )]  [string] $SubscriptionId = $(Get-AzContext).Subscription.Id)

$Params = @{DefaultProfile  = $($Context=Set-AzContext -SubscriptionId $SubscriptionId;$Context); StartTime = $($Starttime=(Get-Date).AddDays(-90); $Starttime); ErrorAction='Stop'}                                                           #Splatting DefaultProfile etc to avoid errors during parallel execution.
if ($Context) {$StopActivity=(Get-AzActivityLog @Params -ResourceProvider Microsoft.Compute).Where{$_.OperationName.Value -EQ 'Microsoft.Compute/virtualMachines/deallocate/action'}|Sort-Object ResourceId,CorrelationId -Unique}                    #Gets unique VM deletion activity by resource id and CorrelationId[specific time]
$StopActivity.ForEach{$RId = $_.ResourceId
            $Creation=(Get-AzActivityLog @Params -ResourceId $RId).Where{($_.ResourceId -eq $RId -and $_.substatus.value -eq 'Created')}|Select-Object -Last 1                                                                                 #Locates record for creation of the VM
            if ( $Creation ) {$Responsebody=(New-Object PSObject -Property ([hashtable]$($Creation.Properties.Content))).responseBody|ConvertFrom-Json
                              $CreationProp=$Responsebody.properties}

            if ( $CreationProp) {$NicCreation=(((Get-AzActivityLog @Params -EndTime $Creation.EventTimestamp -ResourceId $CreationProp.networkProfile.networkInterfaces.id).Where{$PSItem.Properties.Content.Keys -match 'responsebody'})[0])  #Locates record for creation of its NIC
                                 if ($NicCreation) {$PIP=   ((New-Object PSObject -Property ([hashtable]$NicCreation.Properties.Content)).responsebody|ConvertFrom-Json).properties.ipConfigurations.properties.privateIPAddress}              #Get IP from the NIC creation log
                                }
            [PSCustomObject]@{
                    AzVMname      = $RId.Split("/")[8]
                    Hostname      = $CreationProp.osProfile.computerName
                    AzVMId        = $CreationProp.VMId
                    OSType        = $CreationProp.storageprofile.osdisk.ostype
                    CreatedUTC    = $Creation.EventTimestamp
                    CreatedBy     = $Creation.Caller
                    IP            = $PIP
                    Subscription  = ($Context.Name).Substring(0,$Context.Name.IndexOf('('))
                    SubscriptionId= $_.SubscriptionId
                    Location      = $Responsebody.location
                    ResourceGroup = $_.resourceGroupName
                    StoppedUTC    = $_.eventTimestamp
                    StoppeddBy     = $_.Caller
                    Operation     = $_.operationName.value
                                }
                        }

### COMO UTILIZAR
# Get-AzVMStopActivity.ps1 -SubscriptionId d4cdd336-c4d5-4582-977e-e024e1698104 | Export-Csv -Path c:\temp\VmStopped.csv