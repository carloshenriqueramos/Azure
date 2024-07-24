<#
.SYNOPSIS
    Cria um Container em Storage Account Existente

.DESCRIPTION
    Cria um Container em Storage Account Existente

.EXAMPLE
    .\create-blob-container-in-storage-existing.ps1

.NOTES
    Nome: create-blob-container-in-storage-existing
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/create-blob-container-in-storage-existing.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Solicita Resource Group, nome da Storage Account e Container
$resourceGroupName = read-host "Informe o nome do Resource Group"
$storageAccountName = read-host "Informe o nome da Storage Account"
$storageContainerName = read-host "Informe o nome do Container a ser Criado"

# Get na Storage Account fornecida para obtencao do Contexto
$ctx = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName).Context

# Cria o Container
New-AzStorageContainer -Name $storageContainerName -Context $ctx -Permission Off

# Lista os Containers da Storage Account
Write-host ""
Write-host "Listando os Containers da Storage Account" $storageAccountName
Get-AzStorageContainer -Context $ctx | Select Name, PublicAccess, LastModified