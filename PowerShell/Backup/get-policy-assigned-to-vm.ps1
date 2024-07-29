<#
.SYNOPSIS
    Lista se uma VM possui ou nao Azure Backup ativado e os detalhes de Vault e Politica de Backup atribuida

.DESCRIPTION
    Lista se uma VM possui ou nao Azure Backup ativado e os detalhes de Vault e Politica de Backup atribuida

.EXAMPLE
    .\get-policy-assigned-to-vm.ps1

.NOTES
    Nome: get-policy-assigned-to-vm
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Backup/get-policy-assigned-to-vm.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Solicita as informacoes da VM
$vmName = read-host "Informe o nome da VM"

$vm = Get-AzVM | Where-Object {$_.Name -eq $vmName}

# Get de todos Vaults de Backup
$backupVaults = Get-AzRecoveryServicesVault

# Obtem status de Backup da VM
$statusBackupVm = Get-AzRecoveryServicesBackupStatus -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Type 'AzureVM'

# Valida se a VM possui Backup habilitado
if ([string]::IsNullOrEmpty($statusBackupVm.VaultId)) {
                
    # Criando estrutura para o arquivo de Export de VMs sem Backup
	$vmWithoutBackup = [PSCustomObject]([ordered]@{

        ResourceGroupVm        = $vm.ResourceGroupName
        VM                     = $vm.Name 
        Localizacao            = $vm.Location 
        BackupHabilitado       = $statusBackupVm.BackedUp

    })

    # Exibe o resultado do Array
    $vmWithoutBackup | ft


}

Else {

    $vmBackupVault = $backupVaults | Where-Object {$_.ID -eq $statusBackupVm.VaultId}
    $container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $vmBackupVault.ID -FriendlyName $vm.Name
    $backupItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM -VaultId $vmBackupVault.ID

    # Criando estrutura para o arquivo de Export de VMs com Backup
    $vmWithBackup = [PSCustomObject]([ordered]@{

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

    # Exibe o resultado do Array
    $vmWithBackup | ft

}