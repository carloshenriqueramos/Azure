<# 

'  ACTT Tool Extraction Code for Azure
'
'  
'  REVISION HISTORY:
' ------------------------------------------------------------------------------------
'   Date			Responsible							Activity			
' ------------------------------------------------------------------------------------
' 10/Nov/2020		Ramakrishna, Shashank				Code Created
' 10/Jan/2022		Prakash, Achanta					Updated code for addressing null values keyVaultSecretList 	
' 15/Feb/2022		Antony, Godwin						Updated code for BackupvaultList	
' 20/Apr/2022		Antony, Godwin 						Updated code for ACTT_CONFIG_SETTINGS.actt
' 1/Mar/2023		Antony,Godwin						Updated code for subscription based extraction
' 15/Mar/2023		Antony, Godwin 						Updated code for for chekcing the AzureCLI and Azure Module Check
' 20/Mar/2023       Antony, Godwin						Commented the extraction of Groupmembers details.
Notice:
' ------------------------------------------------------------------------------------
'	The purpose of this "read only" script is to download data that can be analyzed as part of our audit.  
'	We expect that you will follow your company's regular change management policies and procedures prior to running the script.
'	To the extent permitted by law, regulation and our professional standards, this script is provided "as is," 
'	without any warranty, and the Deloitte Network and its contractors will not be liable for any damages relating to this script or its use.  
'	As used herein, "we" and "our" refers to the Deloitte Network entity that provided the script to you, and the "Deloitte Network" refers to 
'	Deloitte Touche Tohmatsu Limited ("DTTL"), the member firms of DTTL, and each of their affiliates and related entities.
'
'	
#>


$ScriptStartTime = Get-Date
$Extract_Script_Version = "20.0"
$psVersion = $PSVersionTable.PSVersion.Major

$Path = Join-Path (Get-Location) "\ACTTAzure_RAW"
If(!(test-path -Path $Path))
{
New-Item -ItemType directory -Path $Path > $null   #-Force  #. (current directory) 3-Name 
}

$swExceptionLog = New-Object System.IO.StreamWriter($(Join-Path $Path 'exception.log'), $false, [System.Text.Encoding]::Unicode)
$swExceptionLog.WriteLine('[LUMP] NVARCHAR(MAX)')
$swACTTDataLog = New-Object System.IO.StreamWriter($(Join-Path $Path 'ACTT_AZUREDATA.LOG'), $false, [System.Text.Encoding]::Unicode)

Function Get-TimeDate
{
	<#
	.SYNOPSIS
		Returns a formatted Date-Time object	
	.DESCRIPTION
		This function will return a date-time object formatted.
	.EXAMPLE
		Get-Date
	.OUTPUTS
		Date-Time object
	#>
	Get-Date -Format 'MM/dd/yyyy hh:mm:ss.fff tt'
}


#Start-Transcript -Path $(Join-Path $Path "\ACTTDATA.LOG") -UseMinimalHeader   #create ps session text to a log file


Write-output "*#*" | out-file -append -encoding ASCII -filepath "$Path\ACTT_CONFIG_FIELDTERMINATOR.actt"
Write-output "SettingName VARCHAR(100)*#*SettingValue VARCHAR(max)" | out-file -append -encoding ASCII -filepath "$Path\ACTT_CONFIG_SETTINGS.actt"
Write-output "Extract Application Version*#*Microsoft_Azure" | out-file -append -encoding ASCII -filepath "$Path\ACTT_CONFIG_SETTINGS.actt"
Write-output "Extract Script Version*#*$($Extract_Script_Version)" | out-file -append -encoding ASCII -filepath "$Path\ACTT_CONFIG_SETTINGS.actt"
Write-output "Data Extraction Date*#*$($ScriptStartTime)" | out-file -append -encoding ASCII -filepath "$Path\ACTT_CONFIG_SETTINGS.actt"
Write-output "PowerShell Version*#*$($psVersion)" | out-file -append -encoding ASCII -filepath "$Path\ACTT_CONFIG_SETTINGS.actt"

Function Write-ACTTDataLog
{
	
	# Uses Global StreamWriter object $swACTTDataLog
	[CmdletBinding()]
	Param
	(
		[Parameter(Position = 0,
				   Mandatory = $true,
				   HelpMessage = 'Data to be written to ACTTDataLog File')]
		[ValidateNotNullOrEmpty()]
		[string]$Message
	)
	
	# Write log entry to $Path
	$swACTTDataLog.WriteLine($(Get-TimeDate) + ': ' + $Message)
}

Function New-ZipExtractedData 
{
    #Simple function to zip the extracted data
    #If(test-path -Path $Path)
    #{
       # If($($PSVersionTable.PSVersion.Major) -ge 3)
		#{
	       
            $source = $Path
        $destination = Join-Path (Get-Location) "\ACTTAzureOutput_RAW.zip"
        
        If(Test-path $destination) {Remove-item $destination}
        Add-Type -assembly "system.io.compression.filesystem"
        [io.compression.zipfile]::CreateFromDirectory($Source, $destination)
        
        #Compress-Archive -Path $Path_ZipLOc_target $Path_D\$DBNAME_MAP.zip -Force 
       # Remove-Item -Recurse -Force $Path
       # }
    #}        
}

Function Module-Check
{
	import-module AzureAD
		if ($?)
		{
			Write-Host "Detected Azure AD module"
		}
		else
		{
			Write-Host "Kindly refer the instruction document to install Azure AD module and re-run the extractor"\
			exit
		}	
}	

#<#

Function Get-AzureDetails
{
	  try 
    {
		
		IF($PSVersiontable.PSEdition.equals('Core'))
{
    Write-Host "az login is not required"
    Write-Host "Continuing the extraction for $subname"
	Write-Host ''
	
}
else
{
	Write-Host "az login is  required"
	az logout
	az login
}

		
Write-Host "Below are the Subscriptions Configured" -ForegroundColor Green
az account list --query '[].name' --output tsv
$subscriptions = az account list --query '[].name' --output tsv
az account list --output json | out-file -Append -encoding unicode -filepath "$Path\az_account_list.json"
Write-Host ''
$subname=(Read-Host "Enter the Subscription name for which the data to be extracted")
#Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\resourcegroups.json"
#Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\AllResources.json"
#Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\RoleAssignments.json"
#Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\CustomRole.json"
#$global:Loop1=(Read-Host "Enter the Subscription name for which the data to be extracted")
	#$global:Loop1=$global:Loop1.Split(',')
	#$global:Loop1count=$global:Loop1.count
	#foreach ($subname in $global:Loop1)
		#{
			#$global:Loop1count = $global:Loop1count - 1
		#}
		
#<#

if ( $subscriptions.contains($subname) )
{
	Write-Host "Subscription validated" -ForegroundColor Green
	Write-Host "Starting extraction for Subscription "$subname"" -ForegroundColor Green
	Write-Host ''
}
else
{
	Write-Host ''
	Write-Host "Subscription validation failed" -ForegroundColor Red
	Write-Host "Kindly enter the correct subscription"
	Write-Host ''
	Get-AzureDetails
}

#Connect-AzureAD

Write-output "Extraction of resourcegroups for $subname is started " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of resourcegroups for $subname is started"
az group list --subscription "$subname" --output json | out-file -Append -encoding unicode -filepath "$Path\resourcegroups.json"
Write-output "Extraction of resourcegroups for $subname is ended " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of resourcegroups for $subname is ended"

Write-output "Extraction of AllResources for $subname is started " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of AllResources for $subname is started"
az resource list --subscription "$subname" --output json | out-file -Append -encoding unicode -filepath "$Path\AllResources.json"
Write-output "Extraction of AllResources for $subname is ended " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of AllResources for $subname is ended"

Write-output "Extraction of RoleAssignments for $subname is started " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of  RoleAssignments for $subname is started"
az role assignment list --all --include-classic-administrators true --subscription "$subname" --output json| out-file -Append -encoding unicode -filepath "$Path\RoleAssignments.json"
Write-output "Extraction of RoleAssignments for $subname is ended " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of  RoleAssignments for $subname is ended"

Write-output "Extraction of CustomRole for $subname is started " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of  CustomRole for $subname is started"
az role definition list --custom-role-only true --subscription "$subname" --output json | out-file -Append -encoding unicode -filepath "$Path\CustomRole.json"
Write-output "Extraction of CustomRole for $subname is ended" | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of CustomRole for $subname is ended"

Write-output "Extraction of AllRoleDefinitions is started " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of  AllRoleDefinitions started"
az role definition list --subscription "$subname" --output json | out-file -Append -encoding unicode -filepath "$Path\AllRoleDefinitions.json"
Write-output "Extraction of AllRoleDefinitions is ended " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host " Extraction of AllRoleDefinitions ended"


#Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\resourcegroups.json"
#Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\AllResources.json"
#Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\RoleAssignments.json"
#Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\CustomRole.json"

Write-output "Extraction of log-profiles is started " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of log-profiles started"
az monitor log-profiles list --subscription "$subname" --query [*].[id,name]  --output json | out-file -Append -encoding unicode -filepath "$Path\log-profiles.json"
Write-output "Extraction of log-profiles is ended " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of log-profiles ended"


Write-output "Extraction of log-profiles-Rentention is started " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of log-profiles-Rentention is started "
az monitor log-profiles list --subscription "$subname" --query [*].retentionPolicy --output json | out-file -Append -encoding unicode -filepath "$Path\log-profiles-Rentention.json"
Write-output "Extraction of log-profiles-Rentention is ended " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of log-profiles-Rentention is ended "



Write-output "Extraction of log-profiles-locations is started " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of log-profiles-locations is started "
az monitor log-profiles list --subscription "$subname" --query [*].locations --output json | out-file -Append -encoding unicode -filepath "$Path\log-profiles-locations.json"
Write-output "Extraction of log-profiles-locations is ended " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of log-profiles-locations is ended "

Write-output "Extraction of NetworkSecGroups is started " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of NetworkSecGroups is started "
az network nsg list --subscription "$subname"  --query '[*].{name:name,securityRules:securityRules}' --output json | out-file -Append -encoding unicode -filepath "$Path\NetworkSecGroups.json"
Write-output "Extraction of NetworkSecGroups is ended " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of NetworkSecGroups is ended "


Write-output "Extraction of StorageAccounts started  " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Connection  to StorageAccounts is started"

az storage account list --subscription "$subname"  --query '[*].{name:name,enableHttpsTrafficOnly:enableHttpsTrafficOnly,allowBlobPublicAccess:allowBlobPublicAccess}' --output json | out-file -Append -encoding unicode -filepath "$Path\StorageAccounts.json"
$StorageAccountList = @()
##$StorageAccountList = az storage account list --subscription "$subname" --query "[?allowBlobPublicAccess].[name]" --output tsv
$StorageAccountList = az storage account list --subscription "$subname" --query "[*].[name]" --output tsv
$StorageAccCount = $StorageAccountList.Count
try 
	{
		
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Containers_PublicAccess.json"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Queue_PublicAccess.json"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Table_PublicAccess.json"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Share_PublicAccess.json"

foreach ($storageAcc in $StorageAccountList) 
{
    Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Containers_PublicAccess.json"
    Write-Output """StorageAccountName"":""$storageAcc""" | out-file -Append -encoding unicode -filepath "$Path\Containers_PublicAccess.json"
   
   $cnt5=az storage container list --subscription "$subname" --account-name $storageAcc --auth-mode login --query '[*].{ContainerName:name,PublicAccess:properties.publicAccess}' --output tsv
		if ($cnt5.count -ne 0)
		{
			Write-Output ",""ContainerProperties"":" | out-file -Append -encoding unicode -filepath "$Path\Containers_PublicAccess.json"
			az storage container list --subscription "$subname" --account-name $storageAcc --auth-mode login --query '[*].{ContainerName:name,PublicAccess:properties.publicAccess}' --output json | out-file -Append -encoding unicode -filepath "$Path\Containers_PublicAccess.json"
		}
	
	
					#$cnt5=az storage container list --account-name $storageAcc --auth-mode login --query '[*].{ContainerName:name,PublicAccess:properties.publicAccess}' --output tsv
					#if ($cnt5.count -eq 0){
					#	Write-Output "{}" | out-file -Append -encoding unicode -filepath "$Path\Containers_PublicAccess.json"}


    Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Queue_PublicAccess.json"
    Write-Output """StorageAccountName"":""$storageAcc""" | out-file -Append -encoding unicode -filepath "$Path\Queue_PublicAccess.json"
    
	$cnt6=az storage queue list --subscription "$subname" --account-name $storageAcc --auth-mode login --query '[*].{QueueName:name}' --output tsv
		if ($cnt6.count -ne 0)
		{
			Write-Output ",""QueueProperties"":" | out-file -Append -encoding unicode -filepath "$Path\Queue_PublicAccess.json"
    #az storage queue list --account-name $storageAcc --auth-mode login --query "[*].[{QueueName:name}]" | out-file -Append -encoding unicode -filepath "$Path\Queue_PublicAccess.json"
			az storage queue list --subscription "$subname" --account-name  $storageAcc --auth-mode login --query '[*].{QueueName:name}' | out-file -Append -encoding unicode -filepath "$Path\Queue_PublicAccess.json"
		}
		
	#$cnt6=az storage queue list --account-name $storageAcc --auth-mode login --query '[*].{QueueName:name}' --output tsv
	#				if ($cnt6.count -eq 0){
	#					Write-Output "{}" | out-file -Append -encoding unicode -filepath "$Path\Queue_PublicAccess.json"}
	

    Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Table_PublicAccess.json"
    Write-Output """StorageAccountName"":""$storageAcc""" | out-file -Append -encoding unicode -filepath "$Path\Table_PublicAccess.json"
    
		$cnt7=az storage table list --subscription "$subname" --account-name  $storageAcc --query '[*].{TableName:name}' --output tsv
		if ($cnt7.count -ne 0)
		{
		
	Write-Output ",""TableProperties"":" | out-file -Append -encoding unicode -filepath "$Path\Table_PublicAccess.json"
    #az storage table list --account-name $storageAcc --query "[*].[{TableName:name}]" | out-file -Append -encoding unicode -filepath "$Path\Table_PublicAccess.json"
    az storage table list --subscription "$subname" --account-name $storageAcc --query '[*].{TableName:name}' | out-file -Append -encoding unicode -filepath "$Path\Table_PublicAccess.json"
		}
	
	#$cnt7=az storage table list --account-name $storageAcc --query '[*].{TableName:name}' --output tsv
	#				if ($cnt7.count -eq 0){
	#					Write-Output "{}" | out-file -Append -encoding unicode -filepath "$Path\Table_PublicAccess.json"}

    Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Share_PublicAccess.json"
    Write-Output """StorageAccountName"":""$storageAcc""" | out-file -Append -encoding unicode -filepath "$Path\Share_PublicAccess.json"
    
		$cnt9=az storage share list --subscription "$subname" --account-name $storageAcc --query '[*].{ShareName:name}' --output tsv
		if ($cnt9.count -ne 0)
		{
	Write-Output ",""ShareProperties"":" | out-file -Append -encoding unicode -filepath "$Path\Share_PublicAccess.json"
    #az storage share list --account-name $storageAcc --query "[*].[{ShareName:name}]" | out-file -Append -encoding unicode -filepath "$Path\Share_PublicAccess.json"
    az storage share list --subscription "$subname" --account-name  $storageAcc --query '[*].{ShareName:name}' | out-file -Append -encoding unicode -filepath "$Path\Share_PublicAccess.json"
		}
	
    $StorageAccCount=$StorageAccCount-1
    If($StorageAccCount -ge 1){
        Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Containers_PublicAccess.json"
        Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Queue_PublicAccess.json"
        Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Table_PublicAccess.json"
        Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Share_PublicAccess.json"
    }
    Else{
        Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Containers_PublicAccess.json"
        Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Queue_PublicAccess.json"
        Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Table_PublicAccess.json"
        Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Share_PublicAccess.json"
    }
}
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Containers_PublicAccess.json"
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Queue_PublicAccess.json"
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Table_PublicAccess.json"
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Share_PublicAccess.json"


Write-output "Extraction of StorageAccounts ended  " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Connection  to StorageAccounts is ended"

  }
    catch {
        $swExceptionLog.WriteLine('Exception in groupmember listings')
        $swExceptionLog.WriteLine($Error[0])
        continue
    }


Write-output "Extraction of VMEncrytionOSDiskDetails and VMEncrytionDataDiskDetails started  " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of VMEncrytionOSDiskDetails and VMEncrytionDataDiskDetails started "

#<#
$ListAllVMs = @()
$ListAllVMs = az vm list --subscription "$subname"  --query '[].[name,resourceGroup]' --output tsv
$ListAllVMsCount = $ListAllVMs.Count
try 
	{
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionOSDiskDetails.json"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionDataDiskDetails.json"

foreach ($Entry in $ListAllVMs) 
{
    $vmName = $Entry.Split("`t")[0]
    $RG = $Entry.Split("`t")[1]
    Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionDataDiskDetails.json"
    Write-Output """vmNameRG"":""$vmName-$RG""," | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionDataDiskDetails.json"
    Write-Output """vmNameRGProperties"":" | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionDataDiskDetails.json"
    Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionDataDiskDetails.json"    
    az vm encryption show --subscription "$subname" --name $vmName --resource-group $RG --query dataDisk | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionDataDiskDetails.json"
    Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionDataDiskDetails.json"
    
    Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionOSDiskDetails.json"
    Write-Output """vmNameRG"":""$vmName-$RG""," | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionOSDiskDetails.json"
    Write-Output """vmNameRGProperties"":" | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionOSDiskDetails.json"
    Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionOSDiskDetails.json"
    az vm encryption show --subscription "$subname" --name $vmName --resource-group $RG --query osDisk | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionOSDiskDetails.json"
    Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionOSDiskDetails.json"

     $ListAllVMsCount=$ListAllVMsCount-1
    If($ListAllVMsCount -ge 1){
        Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionOSDiskDetails.json"
        Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionDataDiskDetails.json"
    }
    Else{
        Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionOSDiskDetails.json"
        Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionDataDiskDetails.json"
    }  
  
}
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionOSDiskDetails.json"
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\VMEncrytionDataDiskDetails.json"



Write-output "Extraction of VMEncrytionOSDiskDetails and VMEncrytionDataDiskDetails ended  " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of VMEncrytionOSDiskDetails and VMEncrytionDataDiskDetails ended "

  }
    catch {
        $swExceptionLog.WriteLine('Exception in groupmember listings')
        $swExceptionLog.WriteLine($Error[0])
        continue
    }


Write-output "Extraction of SQLDataEncryptionDetails started  " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of SQLDataEncryptionDetails started "

$SqlServerList = az sql server list --subscription "$subname" --query [].[resourceGroup,name] --output tsv
$SqlServerListCount = $SqlServerList.Count
try 
	{
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\SQLDataEncryptionDetails.json"
foreach ($Pair in $SqlServerList) {
    $RG = $Pair.Split("`t")[0]
    $Srv = $Pair.Split("`t")[1]

    $SqlDBList = az sql db list --subscription "$subname" --resource-group $RG --server $Srv --query [].[name] --output tsv
    $SqlServerDBCount = $SqlDBList.Count    
    foreach ($SDB in $SqlDBList) {

    Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\SQLDataEncryptionDetails.json"
    Write-Output """SQLServerInstanceName"":""$Srv""," | out-file -Append -encoding unicode -filepath "$Path\SQLDataEncryptionDetails.json"
    Write-Output """SQLDatabaseName"":""$SDB""," | out-file -Append -encoding unicode -filepath "$Path\SQLDataEncryptionDetails.json"
    Write-Output """SrvSDBProperties"":" | out-file -Append -encoding unicode -filepath "$Path\SQLDataEncryptionDetails.json"
    az sql db tde show --subscription "$subname" --resource-group $RG --server $Srv --database $SDB --query "{status:status,location:location,name:name,resourceGroup:resourceGroup,type:type}" | out-file -Append -encoding unicode -filepath "$Path\SQLDataEncryptionDetails.json"

    $SqlServerDBCount=$SqlServerDBCount-1

    If($SqlServerDBCount -ge 1){
            Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\SQLDataEncryptionDetails.json"
        }
        Else{
            Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\SQLDataEncryptionDetails.json"
        }
        
    }
	
	$SqlServerListCount=$SqlServerListCount-1
	 If($SqlServerListCount -ge 1){
            Write-Output "," | out-file -Append -encoding unicode -filepath "$Path\SQLDataEncryptionDetails.json"
        }
        
}
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\SQLDataEncryptionDetails.json"


Write-output "Extraction of SQLDataEncryptionDetails ended  " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of SQLDataEncryptionDetails ended "

  }
    catch {
        $swExceptionLog.WriteLine('Exception in groupmember listings')
        $swExceptionLog.WriteLine($Error[0])
        continue
    }


#### Note: ACTT extracts Keyvault detiails to check if the keys are enabled and expiration days.No sensitive information is being extracted.#####
Write-output "Extraction of Keyvault Details started  " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of Keyvault Details started "

$KeyVaultList = az keyvault list --subscription "$subname" --query [].[name,resourceGroup] --output tsv
$KeyVaultListCount = $KeyVaultList.Count
try 
	{
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\keyVaultKeyList.json"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\keyVaultSecretList.json"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\keyVaultDeleteProtectionDetails.json"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\keyVaultMonitorDiagnostic.json"
foreach ($vaultpair in $KeyVaultList) {
    $keyVaultName = $vaultpair.Split("`t")[0]
    $RG = $vaultpair.Split("`t")[1]

    Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\keyVaultKeyList.json"
    Write-Output """keyVaultName"":""$keyVaultName"""| out-file -Append -encoding unicode -filepath "$Path\keyVaultKeyList.json"
    
	$cnt1=az keyvault key list --subscription "$subname"  --vault-name $keyVaultName --query '[*].{kid:kid,enabled:attributes.enabled,expires:attributes.expires}' --output tsv
					if ($cnt1.count -ne 0)
					{
						Write-Output ",""keyVaultProperties"":" | out-file -Append -encoding unicode -filepath "$Path\keyVaultKeyList.json"
#    az keyvault key list --vault-name $keyVaultName --query "[*].[{kid:kid},{enabled:attributes.enabled},{expires:attributes.expires}]" | out-file -Append -encoding unicode -filepath "$Path\keyVaultKeyList.json"
						az keyvault key list --subscription "$subname" --vault-name $keyVaultName --query '[*].{kid:kid,enabled:attributes.enabled,expires:attributes.expires}' | out-file -Append -encoding unicode -filepath "$Path\keyVaultKeyList.json"
					}
					
					#19.0 Prakash --to check null user policies
                   
				   
                    
					
    Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\keyVaultSecretList.json"
    Write-Output """keyVaultName"":""$keyVaultName""" | out-file -Append -encoding unicode -filepath "$Path\keyVaultSecretList.json"
    
					$cnt2=az keyvault secret list --subscription "$subname" --vault-name $keyVaultName --query '[*].{id:id,enabled:attributes.enabled,expires:attributes.expires}' --output tsv
					if ($cnt2.count -ne 0)
					{
						Write-Output ",""keyVaultProperties"":" | out-file -Append -encoding unicode -filepath "$Path\keyVaultSecretList.json"
#    az keyvault secret list --vault-name $keyVaultName --query "[*].[{id:id},{enabled:attributes.enabled},{expires:attributes.expires}]" | out-file -Append -encoding unicode -filepath "$Path\keyVaultSecretList.json"
						az keyvault secret list --subscription "$subname" --vault-name $keyVaultName --query '[*].{id:id,enabled:attributes.enabled,expires:attributes.expires}' | out-file -Append -encoding unicode -filepath "$Path\keyVaultSecretList.json"
					}
					
					#$cnt2=az keyvault secret list --vault-name $keyVaultName --query '[*].{id:id,enabled:attributes.enabled,expires:attributes.expires}' --output tsv
					#if ($cnt2.count -eq 0){
					#	Write-Output "{}" | out-file -Append -encoding unicode -filepath "$Path\keyVaultSecretList.json"}


      Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\keyVaultDeleteProtectionDetails.json"
    Write-Output """keyVaultName"":""$keyVaultName""," | out-file -Append -encoding unicode -filepath "$Path\keyVaultDeleteProtectionDetails.json"
    Write-Output """ResourceGroup"":""$RG""" | out-file -Append -encoding unicode -filepath "$Path\keyVaultDeleteProtectionDetails.json"
    
	$cnt3=az keyvault show --subscription "$subname" --resource-group $RG --name $keyVaultName --query "{enableSoftDelete:properties.enableSoftDelete,enablePurgeprotection:properties.enablePurgeProtection}" --output tsv
					if ($cnt3.count -ne 0)
					{
	
	Write-Output ",""keyVaultNameProperties"":" | out-file -Append -encoding unicode -filepath "$Path\keyVaultDeleteProtectionDetails.json"
    az keyvault show --subscription "$subname" --resource-group $RG --name $keyVaultName --query "{enableSoftDelete:properties.enableSoftDelete,enablePurgeprotection:properties.enablePurgeProtection}" | out-file -Append -encoding unicode -filepath "$Path\keyVaultDeleteProtectionDetails.json"
					
					#$cnt3=az keyvault show --resource-group $RG --name $keyVaultName --query "{enableSoftDelete:properties.enableSoftDelete,enablePurgeprotection:properties.enablePurgeProtection}" --output tsv
					#if ($cnt3.count -eq 0){
						#Write-Output "{}" | out-file -Append -encoding unicode -filepath "$Path\keyVaultDeleteProtectionDetails.json"
						}
						
    
	
	Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\keyVaultMonitorDiagnostic.json"
    Write-Output """keyVaultName"":""$keyVaultName""," | out-file -Append -encoding unicode -filepath "$Path\keyVaultMonitorDiagnostic.json"
    Write-Output """ResourceGroup"":""$RG""" | out-file -Append -encoding unicode -filepath "$Path\keyVaultMonitorDiagnostic.json"
    
					$cnt4=az monitor diagnostic-settings list --subscription "$subname" --resource $keyVaultName --resource-group $RG --resource-type Microsoft.KeyVault/vaults --output tsv
					if ($cnt4.count -ne 0)
					{
							
	Write-Output ",""keyVaultNameProperties"":" | out-file -Append -encoding unicode -filepath "$Path\keyVaultMonitorDiagnostic.json"
    az monitor diagnostic-settings list --subscription "$subname" --resource $keyVaultName --resource-group $RG --resource-type Microsoft.KeyVault/vaults | out-file -Append -encoding unicode -filepath "$Path\keyVaultMonitorDiagnostic.json"
					}
					
					#$cnt4=az monitor diagnostic-settings list --resource $keyVaultName --resource-group $RG --resource-type Microsoft.KeyVault/vaults --output tsv
					#if ($cnt4.count -eq 0){
						#Write-Output "{}" | out-file -Append -encoding unicode -filepath "$Path\keyVaultMonitorDiagnostic.json"}
    
	 
	 $KeyVaultListCount=$KeyVaultListCount-1
     
    If($KeyVaultListCount -ge 1){
        Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\keyVaultKeyList.json"
        Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\keyVaultSecretList.json"
        Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\keyVaultDeleteProtectionDetails.json"
        Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\keyVaultMonitorDiagnostic.json"
    }
    Else{
        Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\keyVaultKeyList.json"
        Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\keyVaultSecretList.json"
        Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\keyVaultDeleteProtectionDetails.json"
        Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\keyVaultMonitorDiagnostic.json"
    }

}
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\keyVaultKeyList.json"
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\keyVaultSecretList.json"
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\keyVaultDeleteProtectionDetails.json"
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\keyVaultMonitorDiagnostic.json"

Write-output "Extraction of Keyvault Details ended  " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of Keyvault Details ended "

  }
    catch {
        $swExceptionLog.WriteLine('Exception in groupmember listings')
        $swExceptionLog.WriteLine($Error[0])
        continue
    }


Write-output "Extraction of Backupvault Details started  " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of Backupvault Details started "

$BackupvaultList = az backup vault list --subscription "$subname" --query [].[resourceGroup,name] --output tsv
$BackupvaultListCount = $BackupvaultList.Count
try 
	{
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\azbackuppolicylist.json"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\azbackupitemlist.json"

foreach ($Pair in $BackupvaultList) {
    $RG = $Pair.Split("`t")[0]
    $VN = $Pair.Split("`t")[1]
	Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\azbackuppolicylist.json"
	Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\azbackupitemlist.json"
		Write-Output """vaultName"":""$VN""," | out-file -Append -encoding unicode -filepath "$Path\azbackuppolicylist.json"
	Write-Output """vaultName"":""$VN""," | out-file -Append -encoding unicode -filepath "$Path\azbackupitemlist.json"
	Write-Output """ResourceName"":""$RG""," | out-file -Append -encoding unicode -filepath "$Path\azbackuppolicylist.json"
	Write-Output """ResourceName"":""$RG""," | out-file -Append -encoding unicode -filepath "$Path\azbackupitemlist.json"
	    Write-Output """vaultNameRG"":""$VN-$RG""," | out-file -Append -encoding unicode -filepath "$Path\azbackuppolicylist.json"
	  Write-Output """vaultNameRG"":""$VN-$RG""," | out-file -Append -encoding unicode -filepath "$Path\azbackupitemlist.json"
	 Write-Output """vaultNameRGPolicy"":" | out-file -Append -encoding unicode -filepath "$Path\azbackuppolicylist.json"
	Write-Output """vaultNameRGPolicy"":" | out-file -Append -encoding unicode -filepath "$Path\azbackupitemlist.json"
		
    #Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\azbackuppolicylist.json"
	  #Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\azbackupitemlist.json"
	az backup policy list --subscription "$subname" --resource-group $RG --vault-name $VN | out-file -Append -encoding unicode -filepath "$Path\azbackuppolicylist.json"
	az backup item list --subscription "$subname" --resource-group $RG --vault-name $VN | out-file -Append -encoding unicode -filepath "$Path\azbackupitemlist.json"
	
	#Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\azbackuppolicylist.json"
	#Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\azbackupitemlist.json"
    
    
     $BackupvaultListCount=$BackupvaultListCount-1
    If($BackupvaultListCount -ge 1){
        Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\azbackuppolicylist.json"
		Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\azbackupitemlist.json"
        
    }
    Else{
        Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\azbackuppolicylist.json"
		Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\azbackupitemlist.json"
        
    }  
  
}
	Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\azbackuppolicylist.json"
	Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\azbackupitemlist.json"
	
Write-output "Extraction of Backupvault Details started  " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of Backupvault Details started "

  }
    catch {
        $swExceptionLog.WriteLine('Exception in groupmember listings')
        $swExceptionLog.WriteLine($Error[0])
        continue
    }

#<#


Write-output "Extraction of AllUsers is started " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of AllUsers started"
az ad user list --output json | out-file -Append -encoding unicode -filepath "$Path\AllUsers.json"
Write-output "Extraction of AllUsers is ended " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of AllUsers ended"

Write-output "Extraction of GuestUsers is started " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of GuestUsers started"
az ad user list --filter "UserType eq 'Guest'" --output json | out-file -Append -encoding unicode -filepath "$Path\GuestUsers.json"
Write-output "Extraction of GuestUsers is ended " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of GuestUsers ended"

#Write-output "Connecting to Azure AD " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
#Connect-AzureAD
#If("$?" -eq "True"){
 #       Write-Output "Connect-AzureAD command execution successfull" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
	#	Write-Host "Connect-AzureAD command execution successfull" 
# }
 #    Else{   
  #      Write-Output "Connect-AzureAD command execution failed" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
	#	Write-Host "Connect-AzureAD command execution failed"
     #   }
#Write-output "Connection  to Azure AD is ended " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
#Write-Host "Connection  to Azure AD is ended " 

Write-output "Extraction of AzureAD Users started  " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Connection  to AzureAD  Users is started" 
try{
Get-AzureADUser -All $true| Select-Object UserPrincipalName, @{N="PasswordNeverExpires";E={$_.PasswordPolicies -contains "DisablePasswordExpiration"}} | ConvertTo-Json | out-file -Append -encoding unicode -filepath "$Path\Users_PasswordNeverExpires.json"
}
catch{
 $swExceptionLog.WriteLine('Exception Get-AzureADUser')
 $swExceptionLog.WriteLine($Error[0])
 $ErrorActionPreference =  'Continue'
  
}
Write-output "Extraction of AzureAD Users ended  " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Connection  to AzureAD  Users is ended " 

#>

Write-output "Extraction of log-profiles-categories is started " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of log-profiles-categories is started "
az monitor log-profiles list --subscription "$subname"  --query [*].categories --output json | out-file -Append -encoding unicode -filepath "$Path\log-profiles-categories.json"
Write-output "Extraction of log-profiles-categories is ended " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of log-profiles-categories is ended "




Write-output "Extraction of AzureADServicePrincipalOwner started  " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Connection  to AzureADServicePrincipalOwner is started"
#Get-AzureADServicePrincipalOwner -objectid $id.ObjectId | Select ObjectId,DisplayName,UserPrincipalName,UserType | ConvertTo-JSON | out-file -Append -encoding unicode -filepath "$Path\AzureADServicePrincipalOwner.json"
$ServicePrincipalList = @{}
$ServicePrincipalList = Get-AzureADServicePrincipal | Select DisplayName, ObjectId, AppId
$ServicePrincipalcount = $ServicePrincipalList.Count 
try 
	{
		
 Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\AzureADServicePrincipalOwner.json"
foreach($id in $ServicePrincipalList) 
{
    Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\AzureADServicePrincipalOwner.json"
    Write-Output """DisplayName"":""$($id.DisplayName)""," | out-file -Append -encoding unicode -filepath "$Path\AzureADServicePrincipalOwner.json"
    Write-Output """OwnerDetails"":" | out-file -Append -encoding unicode -filepath "$Path\AzureADServicePrincipalOwner.json"
    Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\AzureADServicePrincipalOwner.json"
    Get-AzureADServicePrincipalOwner -objectid $id.ObjectId | Select ObjectId,DisplayName,UserPrincipalName,UserType | ConvertTo-JSON | out-file -Append -encoding unicode -filepath "$Path\AzureADServicePrincipalOwner.json"
    Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\AzureADServicePrincipalOwner.json"

    $ServicePrincipalcount=$ServicePrincipalcount-1
    If($ServicePrincipalcount -ge 1){
        Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\AzureADServicePrincipalOwner.json"
        }
     Else{   
        Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\AzureADServicePrincipalOwner.json"
        }
}
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\AzureADServicePrincipalOwner.json"
Write-output "Extraction of AzureADServicePrincipalOwner ended  " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Connection  to AzureADServicePrincipalOwner is ended"

}
  
    catch {
        $swExceptionLog.WriteLine('Exception in groupmember listings')
        $swExceptionLog.WriteLine($Error[0])
        continue
    }


}
    catch {
        $swExceptionLog.WriteLine('Generic Exception')
        $swExceptionLog.WriteLine($Error[0])
        $ErrorActionPreference = 'Continue'
    }

    finally
    {
        $swExceptionLog.Close()
        $swACTTDataLog.Close()
    }
    

}
Write-Host "Analyzing the environment where the script is being run"
IF($PSVersiontable.PSEdition.equals('Core'))
{
    Write-Host "Detected Environment Azure CloudShell"
    Get-AzureDetails            
    New-ZipExtractedData
	Write-Host "********* IMPORTANT: The file has successfully generated as ACTTAzureOutput_RAW.zip **********" -ForegroundColor Green
	Write-Host "**********Please make sure to delete the generated file "ACTTAzureOutput_RAW.zip" and Folder "ACTTAzure_RAW"  from the server after you have provided the file to Deloitte Engagement Team********" -ForegroundColor Green

}
else
{
    Write-Host "Detected Environment is not Azure CloudShell"
	$checkcli=az --version | Select-String "azure-cli"
	if ($checkcli -ne 0)
	{
		Write-Host " Azure CLI is installed."
		Module-Check
		#az login
   		Get-AzureDetails 
		#GroupMembers
    	New-ZipExtractedData
		Write-Host "********* IMPORTANT: The file has successfully generated as ACTTAzureOutput_RAW.zip **********" -ForegroundColor Green
		Write-Host "**********Please make sure to delete the generated file "ACTTAzureOutput_RAW.zip" and Folder "ACTTAzure_RAW"  from the server after you have provided the file to Deloitte Engagement Team********" -ForegroundColor Green

	}
	else
	{
		Write-Host " Azure CLI is not installed.Kindly refer the instructions to install Azure CLI and re-extract"
		exit
	}
}

$ScriptEndTime = Get-Date
Write-output "Extract End Date*#*$($ScriptEndTime)" | out-file -append -encoding ASCII -filepath "$Path\ACTT_CONFIG_SETTINGS.actt"

##Compress-Archive -path $Path -DestinationPath .\acttAzureRaw.zip

Write-output "Extraction Completed  " | out-file -append -encoding ASCII -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction Completed"


#Stop-Transcript





# SIG # Begin signature block
# MIIx/gYJKoZIhvcNAQcCoIIx7zCCMesCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWUpaXf2wnf031y2th8DWAO7q
# jM6ggixXMIIFfzCCA2egAwIBAgIQGLXChEOQEpdBrAmKM2WmEDANBgkqhkiG9w0B
# AQsFADBSMRMwEQYKCZImiZPyLGQBGRYDY29tMRgwFgYKCZImiZPyLGQBGRYIRGVs
# b2l0dGUxITAfBgNVBAMTGERlbG9pdHRlIFNIQTIgTGV2ZWwgMSBDQTAeFw0xNTA5
# MDExNTA3MjVaFw0zNTA5MDExNTA3MjVaMFIxEzARBgoJkiaJk/IsZAEZFgNjb20x
# GDAWBgoJkiaJk/IsZAEZFghEZWxvaXR0ZTEhMB8GA1UEAxMYRGVsb2l0dGUgU0hB
# MiBMZXZlbCAxIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAlPqN
# qqVpE41dp1s1+neM+Xv5zfUAKTrD10RAF9epFFmIIMH62VgMXOYYWBryNQaUAYPZ
# lvv/Tt0cCKca5XAWKp4DbBeblCmxfHsqEz3R/kzn/CHRHnQ3YMZRMorAccq82Ddx
# Kiwnw9o0W5SGD5A+zNXh9DjcCx0G5ROAaqiv7m3HYz2HrEvqdIuMkMoj7Y2ieMiw
# /PuIjVU8wmodltkBmGoAeOOcVYaWBZTpKy0NC/xYL7eHfMKdgRaa30pFVeZliN8D
# MiN/exbfr6iu00fQAsNxiZleH/6CLHuODdh+7KK00Wp2Wi9qz/IeOAGkj8j0jXFn
# nX5PHQWcVVv8E8sIK1S95xDxmhOsrMGkGA6G3F7a1qfI1WntvYBT98eUgZQ3whDq
# jypj622jjXLkUxlfuUeuBHB2+T9kSbapQHIhjAE3f97A/FOuzG0aerr6eNC5doNj
# OX31Bfp5W0WkhbX8D0Aexf7v+OsboqFkAkaNzSS2oaX7+G3XAw2r+slDmyimr+bo
# aLEo4vM+oFzFUeBQOXvjGBEnGtxXmSIPwsLu+HlhOvjtXINLbsczl2QWzC2arRPx
# x6HLr1hPj0eiyz7bKDPQ+N+U9l5OetL6NNFgppVDoqSVo5FUwh47wZKaqXZ8b1jP
# j/SS+IRsbKnCJ37+YXfkA2Mid9x8oMyRfBfwed8CAwEAAaNRME8wCwYDVR0PBAQD
# AgGGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFL6LoCtmWVn6kHFRpaeoBkJO
# kDztMBAGCSsGAQQBgjcVAQQDAgEAMA0GCSqGSIb3DQEBCwUAA4ICAQCDTvRyLG76
# 375USpexKf0BGCuYfW+o/6G18GRqZeYls7lO251xn7hfXacfEZIHCPoizan0yvZJ
# tYUocXRMieo766Zwn8g4OgEZjJXsw81p0GlkylmdWhqO+sRuGyYvGY32MWZ16oz6
# x/CG+rseou2HsLLtlSV76D2XPnDutIAHI/S4is4A7F0V+oNX04aHpUXMb0Y1BkPK
# NF1gIlmf4rdtRh6+2r374QP+Ruw+nJiPNwF7TF28wkz1iUXWK9FSmM1Q6+/uXxpx
# 9qRFRwv+pCd/07IneZ3GmxxTNJxSzzEJxIfwoJIn6HL9NYPltAZ7CuWYsm5TFY+x
# 5TZ5qS/O6+nAHd30T7K/q+H5hjp9tisYah3RiBOOU+iZvtUsr1XaLT7zizxnmp4s
# sHHryLhNkYu2uh/dT1/iq8SbM3fKGElML+mE7ZPAg2q2B76kgbY+GrEtzNnzwNfI
# wkh/IDKYJ9n6JU2yQ4oa5sJjTf5uHUhxV9Zd8/BZK8L3H5S7Iy3yCVLyq98xuUZ3
# ChL4FoKeS89uMrgKADP2xnAdIw1nnd67ZSPrTVk3sZO/uJVKTzjpU0V10sc27VmV
# x9YByc4o4xDoQ6+eAlUbNpuoFpchzdL2dx5JUalLl2T4jg4UIzKcidPhEmyU1ApK
# UXFQTbx0N8v1WC2UXROwuc0YDLR7v6RCLjCCBY0wggR1oAMCAQICEA6bGI750C3n
# 79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoT
# DERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UE
# AxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoX
# DTMxMTEwOTIzNTk1OVowYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0
# IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNl
# cnQgVHJ1c3RlZCBSb290IEc0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKC
# AgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUuySE98orYWcLhKac9WKt2ms2uexuEDcQw
# H/MbpDgW61bGl20dq7J58soR0uRf1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6
# dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXG
# XuxbGrzryc/NrDRAX7F6Zu53yEioZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXn
# Mcvak17cjo+A2raRmECQecN4x7axxLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy
# 19sEcypukQF8IUzUvK4bA3VdeGbZOjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFY
# F/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDgohIbZpp0yt5LHucOY67m1O+Skjqe
# PdwA5EUlibaaRBkrfsCUtNJhbesz2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFg
# qrFjGESVGnZifvaAsPvoZKYz0YkH4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJR
# R3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7Gr
# hotPwtZFX50g/KEexcCPorF+CiaZ9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2
# MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9P
# MB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIB
# hjB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2lj
# ZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRo
# dHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0Eu
# Y3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV
# 5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8t
# tzjv9P+Aufih9/Jy3iS8UgPITtAq3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKh
# SLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO
# 7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WY
# IsGyWfVVa88nq2x2zm8jLfR+cWojayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3
# AamfV6peKOK5lDCCBd4wggPGoAMCAQICEz4AAAAKdNVtyb8ulQIAAgAAAAowDQYJ
# KoZIhvcNAQELBQAwVDETMBEGCgmSJomT8ixkARkWA2NvbTEYMBYGCgmSJomT8ixk
# ARkWCERlbG9pdHRlMSMwIQYDVQQDExpEZWxvaXR0ZSBTSEEyIExldmVsIDIgQ0Eg
# MjAeFw0yMTA2MjkxOTM1MDFaFw0yNjA2MjkxOTQ1MDFaMGwxEzARBgoJkiaJk/Is
# ZAEZFgNjb20xGDAWBgoJkiaJk/IsZAEZFghkZWxvaXR0ZTEWMBQGCgmSJomT8ixk
# ARkWBmF0cmFtZTEjMCEGA1UEAxMaRGVsb2l0dGUgU0hBMiBMZXZlbCAzIENBIDIw
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCjBK7eN3UwSWRgwF4dqTZ3
# El/JIiq4rhpa9PFP92bSNZOmChLVKZ7N+LcLDekcJrqvGdhU8ZXxZQih4rXVpK+h
# EvoAv7odDAD4sdV2ZhKwAgto9q1Q19RC188LXcwiK86QWl18Q/pQsNHqLtAhJ0kF
# wH2CxGd/hKI+h43owy8LgQIU4rAuJsBMiKE1VLIJGZ7OJd19K18r2X7MTe5Ri1fc
# CA8z+96gJfgCelt70oRWzW+xs84ZZ+ar4aP8ueeNq84vksHALQi25i/p68UsjY3P
# qdcN6h1fmZpJ0+1bc99O9/JpZ/BfZ3tGb1qPTAWvTLbtx/xZhXMlv5vYZbGJ1dKR
# AgMBAAGjggGPMIIBizASBgkrBgEEAYI3FQEEBQIDAgACMCMGCSsGAQQBgjcVAgQW
# BBS8vokw1VAoJKLdJxkOj2Xnd1qcETAdBgNVHQ4EFgQUOKGpLhVw4kdhFAZtNuZr
# jw4uw2EwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMBIG
# A1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0jBBgwFoAURy427rSc/1xeGHy4E+G+qSAe
# FLMwXAYDVR0fBFUwUzBRoE+gTYZLaHR0cDovL3BraS5kZWxvaXR0ZS5jb20vQ2Vy
# dEVucm9sbC9EZWxvaXR0ZSUyMFNIQTIlMjBMZXZlbCUyMDIlMjBDQSUyMDIuY3Js
# MHYGCCsGAQUFBwEBBGowaDBmBggrBgEFBQcwAoZaaHR0cDovL3BraS5kZWxvaXR0
# ZS5jb20vQ2VydEVucm9sbC9TSEEyTFZMMkNBMl9EZWxvaXR0ZSUyMFNIQTIlMjBM
# ZXZlbCUyMDIlMjBDQSUyMDIoMikuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQBm9NVB
# JXk77sQM0Qln9/XtirH6bJPIXy1aFhyr1ydTOuZ3TqgOWYxZYXd5rinskWrLWxEN
# ep9UVe+tMu9Daadi/GZqf7tBZpb3c07Z1nHOJp8vRTtIRTh0oaA8vmRrynbIpEp6
# HdNQ9HXOTghxlBDLHt8SbzqG818tNslZaPfBHALsj4Fj9tS20jjwD1PTiT7TZmwU
# ovU4HGs5fttOF/haRq0/ngZYeaeLEeYUmNh2KGWKZRhr0+TgAcEt1P3jF8N6Eh4J
# zMLY+jJlCR/zP0WWnssT7BE2fYrWpC1SNSZ2G8Cbkeg3ZV0A4EOSirpVR09yw0W3
# //hpiZ+enRpNpFlEM7G6mFX1gelmOiQ53V93i43ihPu7pFpkhOKwh5NIfTPcGglm
# mY57k6hKgzopvdS/1KBSSeCp6Tw6xnuXWY+hV1XTlT2W/ADvmT9EII8sUsLLAEKX
# 1CW1BSSNmPdUM+3VBMlsrpxyNYPwj1VFli9VFflasF6uwtHfEQHYttWhUWjEu5Xh
# 0u88zyBHbjEIBCK7wpWdK0cLjIx9k3ogvbeEGzRCRbiwhcC0wt7E4tqeLVneJ1VL
# +aELWEqjFIbm+KfslyKF+Y3tDqm+bPk+XHWpiLMOFiOEtdWZaLBmf168jlPDHaxi
# MiAaC/whoQx1r5pUTO6zkOGkX78OPiDrwUU0hDCCBq4wggSWoAMCAQICEAc2N7ck
# VHzYR6z9KGYqXlswDQYJKoZIhvcNAQELBQAwYjELMAkGA1UEBhMCVVMxFTATBgNV
# BAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8G
# A1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MB4XDTIyMDMyMzAwMDAwMFoX
# DTM3MDMyMjIzNTk1OVowYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0
# LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hB
# MjU2IFRpbWVTdGFtcGluZyBDQTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAMaGNQZJs8E9cklRVcclA8TykTepl1Gh1tKD0Z5Mom2gsMyD+Vr2EaFEFUJf
# pIjzaPp985yJC3+dH54PMx9QEwsmc5Zt+FeoAn39Q7SE2hHxc7Gz7iuAhIoiGN/r
# 2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r07G1decfBmWNlCnT2exp39mQh0YAe9tE
# QYncfGpXevA3eZ9drMvohGS0UvJ2R/dhgxndX7RUCyFobjchu0CsX7LeSn3O9TkS
# Z+8OpWNs5KbFHc02DVzV5huowWR0QKfAcsW6Th+xtVhNef7Xj3OTrCw54qVI1vCw
# MROpVymWJy71h6aPTnYVVSZwmCZ/oBpHIEPjQ2OAe3VuJyWQmDo4EbP29p7mO1vs
# gd4iFNmCKseSv6De4z6ic/rnH1pslPJSlRErWHRAKKtzQ87fSqEcazjFKfPKqpZz
# QmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0z9JMq++bPf4OuGQq+nUoJEHtQr8FnGZJ
# UlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y99xh3pP+OcD5sjClTNfpmEpYPtMDiP6z
# j9NeS3YSUZPJjAw7W4oiqMEmCPkUEBIDfV8ju2TjY+Cm4T72wnSyPx4JduyrXUZ1
# 4mCjWAkBKAAOhFTuzuldyF4wEr1GnrXTdrnSDmuZDNIztM2xAgMBAAGjggFdMIIB
# WTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBS6FtltTYUvcyl2mi91jGog
# j57IbzAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/57qYrhwPTzAOBgNVHQ8BAf8E
# BAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgwdwYIKwYBBQUHAQEEazBpMCQGCCsG
# AQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYBBQUHMAKGNWh0
# dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQu
# Y3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsG
# CWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAfVmOwJO2b5ipRCIBfmbW2CFC
# 4bAYLhBNE88wU86/GPvHUF3iSyn7cIoNqilp/GnBzx0H6T5gyNgL5Vxb122H+oQg
# JTQxZ822EpZvxFBMYh0MCIKoFr2pVs8Vc40BIiXOlWk/R3f7cnQU1/+rT4osequF
# zUNf7WC2qk+RZp4snuCKrOX9jLxkJodskr2dfNBwCnzvqLx1T7pa96kQsl3p/yhU
# ifDVinF2ZdrM8HKjI/rAJ4JErpknG6skHibBt94q6/aesXmZgaNWhqsKRcnfxI2g
# 55j7+6adcq/Ex8HBanHZxhOACcS2n82HhyS7T6NJuXdmkfFynOlLAlKnN36TU6w7
# HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HNT7ZAmyEhQNC3EyTN3B14OuSereU0cZLX
# JmvkOHOrpgFPvT87eK1MrfvElXvtCl8zOYdBeHo46Zzh3SP9HSjTx/no8Zhf+yvY
# fvJGnXUsHicsJttvFXseGYs2uJPU5vIXmVnKcPA3v5gA3yAWTyf7YGcWoWa63VXA
# OimGsJigK+2VQbc61RWYMbRiCQ8KvYHZE/6/pNHzV9m8BPqC3jLfBInwAM1dwvnQ
# I38AC+R2AibZ8GV2QqYphwlHK+Z/GqSFD/yYlvZVVCsfgPrA8g4r5db7qS9EFUrn
# Ew4d2zc4GqEr9u3WfPwwggbAMIIEqKADAgECAhAMTWlyS5T6PCpKPSkHgD1aMA0G
# CSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1
# NiBUaW1lU3RhbXBpbmcgQ0EwHhcNMjIwOTIxMDAwMDAwWhcNMzMxMTIxMjM1OTU5
# WjBGMQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxJDAiBgNVBAMTG0Rp
# Z2lDZXJ0IFRpbWVzdGFtcCAyMDIyIC0gMjCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAM/spSY6xqnya7uNwQ2a26HoFIV0MxomrNAcVR4eNm28klUMYfSd
# CXc9FZYIL2tkpP0GgxbXkZI4HDEClvtysZc6Va8z7GGK6aYo25BjXL2JU+A6LYyH
# Qq4mpOS7eHi5ehbhVsbAumRTuyoW51BIu4hpDIjG8b7gL307scpTjUCDHufLckko
# HkyAHoVW54Xt8mG8qjoHffarbuVm3eJc9S/tjdRNlYRo44DLannR0hCRRinrPiby
# tIzNTLlmyLuqUDgN5YyUXRlav/V7QG5vFqianJVHhoV5PgxeZowaCiS+nKrSnLb3
# T254xCg/oxwPUAY3ugjZNaa1Htp4WB056PhMkRCWfk3h3cKtpX74LRsf7CtGGKMZ
# 9jn39cFPcS6JAxGiS7uYv/pP5Hs27wZE5FX/NurlfDHn88JSxOYWe1p+pSVz28Bq
# mSEtY+VZ9U0vkB8nt9KrFOU4ZodRCGv7U0M50GT6Vs/g9ArmFG1keLuY/ZTDcyHz
# L8IuINeBrNPxB9ThvdldS24xlCmL5kGkZZTAWOXlLimQprdhZPrZIGwYUWC6poEP
# CSVT8b876asHDmoHOWIZydaFfxPZjXnPYsXs4Xu5zGcTB5rBeO3GiMiwbjJ5xwtZ
# g43G7vUsfHuOy2SJ8bHEuOdTXl9V0n0ZKVkDTvpd6kVzHIR+187i1Dp3AgMBAAGj
# ggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8E
# DDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# HwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFGKK3tBh
# /I8xFO2XC809KpQU31KcMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3Rh
# bXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1l
# U3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAFWqKhrzRvN4Vzcw/HXj
# T9aFI/H8+ZU5myXm93KKmMN31GT8Ffs2wklRLHiIY1UJRjkA/GnUypsp+6M/wMkA
# mxMdsJiJ3HjyzXyFzVOdr2LiYWajFCpFh0qYQitQ/Bu1nggwCfrkLdcJiXn5CeaI
# zn0buGqim8FTYAnoo7id160fHLjsmEHw9g6A++T/350Qp+sAul9Kjxo6UrTqvwlJ
# FTU2WZoPVNKyG39+XgmtdlSKdG3K0gVnK3br/5iyJpU4GYhEFOUKWaJr5yI+RCHS
# PxzAm+18SLLYkgyRTzxmlK9dAlPrnuKe5NMfhgFknADC6Vp0dQ094XmIvxwBl8kZ
# I4DXNlpflhaxYwzGRkA7zl011Fk+Q5oYrsPJy8P7mxNfarXH4PMFw1nfJ2Ir3kHJ
# U7n/NBBn9iYymHv+XEKUgZSCnawKi8ZLFUrTmJBFYDOA4CPe+AOk9kVH5c64A0JH
# 6EE2cXet/aLol3ROLtoeHYxayB6a1cLwxiKoT5u92ByaUcQvmvZfpyeXupYuhVfA
# YOd4Vn9q78KVmksRAsiCnMkaBXy6cbVOepls9Oie1FqYyJ+/jbsYXEP10Cro4mLu
# eATbvdH7WwqocH7wl4R44wgDXUcsY6glOJcB0j862uXl9uab3H4szP8XTE0AotjW
# AQ64i+7m4HJViSwnGWH2dwGMMIIGyTCCBLGgAwIBAgITNAAAAAeJIXWJc80n8gAA
# AAAABzANBgkqhkiG9w0BAQsFADBSMRMwEQYKCZImiZPyLGQBGRYDY29tMRgwFgYK
# CZImiZPyLGQBGRYIRGVsb2l0dGUxITAfBgNVBAMTGERlbG9pdHRlIFNIQTIgTGV2
# ZWwgMSBDQTAeFw0yMDA4MDUxNzMyNTZaFw0zMDA4MDUxNzQyNTZaMFQxEzARBgoJ
# kiaJk/IsZAEZFgNjb20xGDAWBgoJkiaJk/IsZAEZFghEZWxvaXR0ZTEjMCEGA1UE
# AxMaRGVsb2l0dGUgU0hBMiBMZXZlbCAyIENBIDIwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCY9vqwcsHbkkPbzo1/JHZF+42CZJdpHZ0uiPHus8OqIRYo
# zTWZJ2q7N5ePtC79VCyJAtX/2jHAwCtK+MkdGN5DYvuis8bK3FaI7qc0eQps9QKQ
# FOZEAtVxcrSJiZeFCNrKmPHnLxuLcrXcBHtrFNs2U8QXLfP1PAUZ+2Z4k4i+V7d0
# G84LEmt7WbGZ/nji2TOr4N/QQ0/ywDjVZ5BsDlnINrYLw9abxcvn1fTRSC0wlw6r
# h8Ib7GSOXuedtDj8A/uUYcaSXRudgTld3+dUDzr7A765NRyZuzR8n18o7durfCCJ
# RpHLIFtRDY3MaWBp9/GqB7aUzdYKaJB4crJ8qw6R+DjX7qHupQXLAOgOS+dUGMmz
# b62AiaqoPqLCaBlYe3o94iLAkD8ggoF/S3U7Xobf26Kbo1KJ6xIr7B84zHLFmKj8
# HMoY862/g/CiwGU8qWErltu8xZjZEWxZAnos+JFeUTk0hhuH8JPKeAh0zoOvCvnu
# whkZZsoIlz2c5G15WDHemByIUDE4UafWTfObEzzepjHGAqLp+qXwoKBuj6XqW5E4
# trmuxF+QY+1FfLUdYnvHBx/z8nEskaWnWu2cadmWO9vRNu3CjwbAOiKFIxKH0yga
# slOu2Ty2dh/hSkuAYqMbIY5QEUatEZBwSFZvMNMrmpk//R/fV3cKd3NA5FgBvwID
# AQABo4IBlDCCAZAwEAYJKwYBBAGCNxUBBAMCAQIwIwYJKwYBBAGCNxUCBBYEFBXh
# v+KL8O1azIV0T6na/7GPCLczMB0GA1UdDgQWBBRHLjbutJz/XF4YfLgT4b6pIB4U
# szARBgNVHSAECjAIMAYGBFUdIAAwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEw
# CwYDVR0PBAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQEwHwYDVR0jBBgwFoAUvoug
# K2ZZWfqQcVGlp6gGQk6QPO0wWAYDVR0fBFEwTzBNoEugSYZHaHR0cDovL3BraS5k
# ZWxvaXR0ZS5jb20vQ2VydEVucm9sbC9EZWxvaXR0ZSUyMFNIQTIlMjBMZXZlbCUy
# MDElMjBDQS5jcmwwbgYIKwYBBQUHAQEEYjBgMF4GCCsGAQUFBzAChlJodHRwOi8v
# cGtpLmRlbG9pdHRlLmNvbS9DZXJ0RW5yb2xsL1NIQTJMVkwxQ0FfRGVsb2l0dGUl
# MjBTSEEyJTIwTGV2ZWwlMjAxJTIwQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQCH
# noNRnnF5G9P8l0AzxuKos4jg8uUiEg+59F8w8mWajrh1j0b8lWQXuqHxIdabu6aN
# JO9vfnuRrIkKSzljdXBLXUD0cyxErXXTzd7EHbsdQF3ZbcjJG/YoFlP5KwCyeG1v
# ayUS4+qqukVkLe7ZFlrxeicpVVxffB8U3SrET7JeSNgxQ3GveRi5yVvaS3/j9GCC
# R9XTp0vRfaUeS0sxgguavxNvb95TZLv/+Gt1wf+1xZnb2GIjMvSprKnSPYwG5cAJ
# X9kM2F4QG8Prn2nXhp7bcKuBOldIsvrxHAeNpCoVV/YRY9eNHUxUlK+MHdAqIZ1d
# OW1S7UwGytEdsXCPzfGGJLWdNJZ8jFIz40bS762P1Inl85BIQyUJ7RpyF2hc+8Xn
# S4PBpMvFQ6gGgMrYMp3yckVr/Hz8aPfmOftE2n/9S7NuYiE6vthmp1+IHCcZ9+bi
# tLnvsScFKxCG46PO6Oslsl3c0/Zqvb3dm6mvx35BhRtTnWfL6ZRhsZDxVB5mCjvZ
# eQUCfPHW9nD1QrlVTukLTOUFkv8U1XqFuByfFDQr+pEC50m3HTcak0XmyqHIQLSd
# 28JJ2WMqx/ia+A3CsQNNrocu0Qo42KyctKDnoitw/Hlb94Pwqyh2XCl+DxQz8D3j
# ZXwlFkkuAWtz6erKw+L5wg0xN3+fjSHbDMZGVyMMTzCCBxowggYCoAMCAQICE2UA
# lPSp6W57Va6QlE8AAgCU9KkwDQYJKoZIhvcNAQELBQAwbDETMBEGCgmSJomT8ixk
# ARkWA2NvbTEYMBYGCgmSJomT8ixkARkWCGRlbG9pdHRlMRYwFAYKCZImiZPyLGQB
# GRYGYXRyYW1lMSMwIQYDVQQDExpEZWxvaXR0ZSBTSEEyIExldmVsIDMgQ0EgMjAe
# Fw0yMzA0MTQxNDEyMzVaFw0yNTA0MTMxNDEyMzVaMIG9MQswCQYDVQQGEwJVUzEL
# MAkGA1UECBMCVE4xEjAQBgNVBAcTCUhlcm1pdGFnZTEaMBgGA1UEChMRRGVsb2l0
# dGUgU2VydmljZXMxITAfBgNVBAsTGFVTIEN5YmVyIERhdGEgUHJvdGVjdGlvbjEo
# MCYGA1UEAxMfVVMgQ3liZXIgQ29kZSBTaWduaW5nIDIwMjMtMjAyNTEkMCIGCSqG
# SIb3DQEJARYVYm9iYnJvd25AZGVsb2l0dGUuY29tMIIBIjANBgkqhkiG9w0BAQEF
# AAOCAQ8AMIIBCgKCAQEAxTAvCOTtwllzOMGn2eKEV/v0qU8b4X36ZOogdSfHkIUU
# pcKORkSx/AkV/GfYZ9nBl3si1hnSkh9UoU9pwJmAymNaGS/FKN2kBstLe4d2IA5c
# 9ILg0xsxn9rR/UwPY/xW2t6ek3uQHS/FURXsH2XYf82LPK44ynYFOVwrQizZWdj6
# x0oqjMriJ7UTky+3++Px3BMIfiIVWK2m9et7omqMADrKioRp7SUmjekBcgnPrk++
# TzfUcGqtk9gDjjQRuIZUcgYS2ruY/q++fL/FsU9uP6RFsVBXiVBEZCLloK2d+meG
# tCVNbEhssfoHEluldp+mMPxAwWSGc12k98fDd0wJnQIDAQABo4IDYTCCA10wCwYD
# VR0PBAQDAgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIGBvUmFvoUTgtWb
# PIPXjgeG8ckKXIPK9y3C8zICAWQCAR4wHQYDVR0OBBYEFMfBYqejeXBVp+SMS3Tg
# /fIHzZ1DMB8GA1UdIwQYMBaAFDihqS4VcOJHYRQGbTbma48OLsNhMIIBQQYDVR0f
# BIIBODCCATQwggEwoIIBLKCCASiGgdVsZGFwOi8vL0NOPURlbG9pdHRlJTIwU0hB
# MiUyMExldmVsJTIwMyUyMENBJTIwMigyKSxDTj11c2F0cmFtZWVtMDA0LENOPUNE
# UCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25m
# aWd1cmF0aW9uLERDPWRlbG9pdHRlLERDPWNvbT9jZXJ0aWZpY2F0ZVJldm9jYXRp
# b25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnSGTmh0
# dHA6Ly9wa2kuZGVsb2l0dGUuY29tL0NlcnRlbnJvbGwvRGVsb2l0dGUlMjBTSEEy
# JTIwTGV2ZWwlMjAzJTIwQ0ElMjAyKDIpLmNybDCCAVcGCCsGAQUFBwEBBIIBSTCC
# AUUwgcQGCCsGAQUFBzAChoG3bGRhcDovLy9DTj1EZWxvaXR0ZSUyMFNIQTIlMjBM
# ZXZlbCUyMDMlMjBDQSUyMDIsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZp
# Y2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9ZGVsb2l0dGUsREM9
# Y29tP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9u
# QXV0aG9yaXR5MHwGCCsGAQUFBzAChnBodHRwOi8vcGtpLmRlbG9pdHRlLmNvbS9D
# ZXJ0ZW5yb2xsL3VzYXRyYW1lZW0wMDQuYXRyYW1lLmRlbG9pdHRlLmNvbV9EZWxv
# aXR0ZSUyMFNIQTIlMjBMZXZlbCUyMDMlMjBDQSUyMDIoMikuY3J0MBMGA1UdJQQM
# MAoGCCsGAQUFBwMDMBsGCSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwDQYJKoZI
# hvcNAQELBQADggEBAFd64KXqcGmmRRUF7ZFoimEIvXOJ1FgQCkVbDhzO50nkTpDw
# s1A+epg6J19s4yt3wB/Wl1cQNi1clER1E7loK/YwV80Tyi6Zna9FgKyh/FjCYvb7
# x/ahDIFX3qvNILOcY0Qc+QIF+J8DyNJrGOr6NoouttGb/qKS19Aj4alJLMlNISyi
# nSerJthbXOhambH4f97UA1qypIlizGpRJ+C0CUxhnUpWRy1IxUzZZrv+JpFBoPv7
# u51Yfr4G0ZtjMC8e8aukqTqzE8SfKf04vduOKA7dP4J6tvrcT8XCruBr3/Ag7lhl
# /YAkDPb2detPsI3gGG3aiU95M3q1D1DulZD4vR4xggURMIIFDQIBATCBgzBsMRMw
# EQYKCZImiZPyLGQBGRYDY29tMRgwFgYKCZImiZPyLGQBGRYIZGVsb2l0dGUxFjAU
# BgoJkiaJk/IsZAEZFgZhdHJhbWUxIzAhBgNVBAMTGkRlbG9pdHRlIFNIQTIgTGV2
# ZWwgMyBDQSAyAhNlAJT0qelue1WukJRPAAIAlPSpMAkGBSsOAwIaBQCgQDAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAjBgkqhkiG9w0BCQQxFgQUxHc3bYXDbgRS
# 7H3OTcUvBbJTca0wDQYJKoZIhvcNAQEBBQAEggEAZ/4JV/bWbNM6f/ZMjgBwr9DX
# /kEU/s19di/zd2nwes8aO99N+BBYhxmYOKtduBUiZcyIWWm/PT1VKW2bUAvYpKqH
# AUID8ZQmeBRa+QK5If/e9nXpnXJXLWuAaXYZgAK5R4kOJaI6ua8ssSgBdSNIuQE5
# 9PhY7WfIfKT7qB/pD7Rlk8yDEue3bM0VfNyzwhy54l3sNWZTcwv68Nvbnhxwnsrd
# RtYtD8sCUJ5rrsnAmhkanK6oNf7LpFGV2r3GwcrcykwWD5sYU/7xp6XZrY18zaSG
# bF9Yi8jctFkWR4i39y7q0hU55S/JcN9KUwlZ+8DMOV44VahJD2VehZ6x+yZYTqGC
# AyAwggMcBgkqhkiG9w0BCQYxggMNMIIDCQIBATB3MGMxCzAJBgNVBAYTAlVTMRcw
# FQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3Rl
# ZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAxNaXJLlPo8Kko9
# KQeAPVowDQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcB
# MBwGCSqGSIb3DQEJBTEPFw0yMzA2MjExNjU2NTdaMC8GCSqGSIb3DQEJBDEiBCCt
# 6hhBGrhJ2nbj1BhAVVeGN5aPhJsfsbiFmdhA9NmrlDANBgkqhkiG9w0BAQEFAASC
# AgBl4CghWf4eYNSjv/RiIBBQXuouJy3CwnvhW2MpJIfTiXUqcCbt/igposGK0VHB
# Sv9Jvkjt2cq8Excf6LYOoHlh6I+O0cQ1oe3hEiknCyKMl+hyQwFukc3Jb9sKNKBk
# tIcqbkrPnkOCrN4cDzJRL4R/8/o3ZuXYV/RyYOlv7iwIlrsKzYZyWcpVjwyHVITg
# y09sikn0swdIvRHpIjQiWUGLSJsTOvRaui8uNqPlizbHozKkn0LSKzEoCpSkhPGO
# 2NLXI3d5aZBPWMax+Eg2PFGWWjMlnnMQirV4M6VbsieIxhv9gk+zZOvnv8XoynJe
# NC7wfl9WAyLezZlkpLPfHQMXtt8GMJKAfkXwbDZPJPTLwH7OsAfM1orzotsoT1rQ
# axTJcyKPHp2lL0GFb/6CeWre0Adj4TaF/P6anAugXzDFhYAccWIpuW4UQUjNYQKC
# B2zDeSXdp5az7aV6G7Pk/BhvC/hV7d07c3N59mMVo6kxxiMhnRlNi1XB/J5Bp0ec
# fLA5J06tPQrkvRth0bF9x0DBSFEn5JhQwwH9wAZS1zTf0/+NbMiif9EuZWvg1Une
# yVbhUXoS8kDwbORGaM6920ofwLsyB0My335FwMASVVyh16+r60BIqJSj8oIwscBc
# GnS049Z/ONsFUQNpc9fbWV/IA7qkI0BO3/8EoaeFREbZ0w==
# SIG # End signature block
