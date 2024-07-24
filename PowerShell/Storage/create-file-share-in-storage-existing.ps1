<#
.SYNOPSIS
    Cria File Share em Storage Account Existente

.DESCRIPTION
    Cria File Share em Storage Account Existente

.EXAMPLE
    .\create-file-share-in-storage-existing.ps1

.NOTES
    Nome: create-file-share-in-storage-existing
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/create-file-share-in-storage-existing.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Solicita Resource Group, nome da Storage Account e File Share
$resourceGroupName  = read-host "Informe o nome do Resource Group"
$storageAccountName = read-host "Informe o nome da Storage Account"
$storageShareName   = read-host "Informe o nome do File Share a ser Criado"

# Get na Storage Account fornecida para obtencao do Contexto
$ctx = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName).Context

# Cria Azure file share
New-AzStorageShare -Name $storageShareName -Context $ctx

# Lista os Files Share da Storage Account
Write-host ""
Write-host "Listando os Files Share da Storage Account" $storageAccountName
Get-AzStorageShare -Context $ctx | ft