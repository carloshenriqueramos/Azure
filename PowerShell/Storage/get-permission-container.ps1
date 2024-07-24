<#
.SYNOPSIS
    Lista as permissoes de um Container

.DESCRIPTION
    Lista as permissoes de um Container

.EXAMPLE
    .\get-permission-container.ps1

.NOTES
    Nome: get-permission-container
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/get-permission-container.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Solicita as informacoes de Resource Group e nome da Storage Account
$resourceGroupName = read-host "Informe o nome do Resource Group"
$storageAccountName = read-host "Informe o nome da Storage Account"
$containerName = read-host "Informe o nome do Container"

# Lista as Permissoes para o Container
Get-AzRoleAssignment -ResourceGroupName $resourceGroupName -ResourceType "Microsoft.Storage/storageAccounts" -ResourceName $storageAccountName `
    | Where-Object { $_.Scope -like '*/containers/$containerName' -or -not ($_.Scope -like '*/storageAccounts*/default/containers/*') } `
    | ft