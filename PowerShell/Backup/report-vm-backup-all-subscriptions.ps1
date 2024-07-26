<#
.SYNOPSIS
    Lista se a VM possui ou nao Azure Backup ativado e os detalhes de Vault e Politica de Backup atribuida

.DESCRIPTION
    Lista se a VM possui ou nao Azure Backup ativado e os detalhes de Vault e Politica de Backup atribuida

.EXAMPLE
    .\report-vm-backup-all-subscriptions.ps1

.NOTES
    Nome: report-vm-backup-all-subscriptions
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Backup/report-vm-backup-all-subscriptions.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Guardando dados no Array
$outputVmsWithBackup = @()
$outputVmsWithoutBackup = @()

# Definindo diretorio de destino do export do arquivo CSV
$outputCsvVmsWithBackup = "C:\TEMP\VmsWithBackup.csv"
$outputCsvVmsWithoutBackup = "C:\TEMP\VmsWithoutBackup.csv"

# Get de todas as subscriptions habilitadas
$subs = Get-AzSubscription | Where-Object {$_.State -eq "Enabled"}

# Analisando cada subscription
foreach ($sub in $subs) {

	# Set the current subscription context
    Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext
 
    # Get de todas as VMs, exceto as que sao criadas pelo Databricks
    $vms = Get-AzVM | Where-Object {$_.ResourceGroupName -notlike "DATABRICKS*"}

    # Get de todos Vaults de Backup
    $backupVaults = Get-AzRecoveryServicesVault

    # Analisando cada VM
    foreach ($vm in $vms) {

            # Obtem status de Backup da VM
            $statusBackupVm = Get-AzRecoveryServicesBackupStatus -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Type 'AzureVM'

            # Valida se a VM possui Backup habilitado
            if ([string]::IsNullOrEmpty($statusBackupVm.VaultId)) {
                
                # Criando estrutura para o arquivo de Export
				$vmWithoutBackup = [PSCustomObject]([ordered]@{
                    Subscription           = $sub.Name 
                    ResourceGroupVm        = $vm.ResourceGroupName
                    VM                     = $vm.Name 
                    Localizacao            = $vm.Location 
                    BackupHabilitado       = $statusBackupVm.BackedUp
                })

                # Adicionando os objetos de consulta no Array de saida
                $outputVmsWithoutBackup += $vmWithoutBackup
                $vmWithoutBackup = ""

            }
           
            Else {
                             
                $vmBackupVault = $backupVaults | Where-Object {$_.ID -eq $statusBackupVm.VaultId}
                $container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $vmBackupVault.ID -FriendlyName $vm.Name
                $backupItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM -VaultId $vmBackupVault.ID

                # Criando estrutura para o arquivo de Export
				$vmWithBackup = [PSCustomObject]([ordered]@{
                    Subscription           = $sub.Name 
                    ResourceGroupVm        = $vm.ResourceGroupName
                    VM                     = $vm.Name 
                    Localizacao            = $vm.Location  
                    BackupHabilitado       = $statusBackupVm.BackedUp 
                    VaultBackupName        = $vmBackupVault.Name 
                    ResourceGroupNameVault = $vmBackupVault.ResourceGroupName
                    PoliticaBackup         = $backupItem.ProtectionPolicyName 
                    HealthStatus           = $backupItem.HealthStatus 
                    ProtectionStatus       = $backupItem.ProtectionStatus 
                    LastBackupStatus       = $backupItem.LastBackupStatus 
                    LastBackupTime         = $backupItem.LastBackupTime 
                    DeleteState            = $backupItem.DeleteState 
                    LatestRecoveryPoint    = $backupItem.LatestRecoveryPoint 
                })

                # Adicionando os objetos de consulta no Array de saida
                $outputVmsWithBackup += $vmWithBackup    
                $vmWithBackup = "" 

            }

     }

}

# Export para o arquivo CSV
$outputVmsWithBackup | Export-Csv -Path $outputCsvVmsWithBackup -NoTypeInformation
$outputVmsWithoutBackup | Export-Csv -Path $outputCsvVmsWithoutBackup -NoTypeInformation

Write-Output ""
Write-Output "Export completed. CSV files saved to $outputCsvVmsWithBackup and $outputCsvVmsWithoutBackup"