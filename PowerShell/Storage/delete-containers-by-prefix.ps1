<#
.SYNOPSIS
    Remover Container em Storage Account

.DESCRIPTION
    Remover Container em Storage Account

.EXAMPLE
    .\delete-containers-by-prefix.ps1

.NOTES
    Nome: delete-containers-by-prefix
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/delete-containers-by-prefix.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Solicita Resource Group, nome da Storage Account e Container
$resourceGroupName = read-host "Informe o nome do Resource Group"
$storageAccountName = read-host "Informe o nome da Storage Account"
$storageContainerName = read-host "Informe o nome do Container a ser Removido"

# Get na Storage Account fornecida para obtencao do Contexto
$ctx = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName).Context

# Lista os Containers da Storage Account
Write-host ""
Write-host "Listando os Containers da Storage Account" $storageAccountName
Get-AzStorageContainer -Context $ctx | Select Name, PublicAccess, LastModified

# Get do Container a ser Removido
$containerToDelete = Get-AzStorageContainer -Context $ctx -Prefix $storageContainerName

# Lista o Container a ser Removido
Write-Host "Listando o Container a ser Removido"
$containerToDelete | select Name

# Solicitando confirmacao para remocao do Container
Write-Host ""
$confirmation = Read-Host "Deseja prosseguir com remocao do Container? (S/N)"

if ($confirmation.ToUpper() -ne "S") {
  Write-Host "Remocao do Container cancelado."
  return
}

# Removendo o Container
Write-Host ""
Write-Host "Removendo o Container" $storageContainerName -BackgroundColor Red
$containerToDelete | Remove-AzStorageContainer -Context $ctx 

# Lista os Containers Restantes da Storage Account
Write-host ""
Write-host "Listando os Containers da Storage Account" $storageAccountName
Write-Host ""
Get-AzStorageContainer -Context $ctx | Select Name, PublicAccess, LastModified