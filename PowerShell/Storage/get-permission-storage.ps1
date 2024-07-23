<#
.SYNOPSIS
    Lista as permissoes de uma Storage Account

.DESCRIPTION
    Lista as permissoes de uma Storage Account

.EXAMPLE
    .\get-permission-storage.ps1

.NOTES
    Nome: get-permission-storage
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/get-permission-storage.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Solciita as informacoes de Resource Group e nome da Storage Account
$resourceGroupName = read-host "Informe o nome do Resource Group"
$storageAccountName = read-host "Informe o nome da Storage Account"

# Lista as Permissoes para a Storage Account
Get-AzRoleAssignment -ResourceGroupName $resourceGroupName -ResourceName $storageAccountName -ResourceType 'Microsoft.Storage/storageAccounts' `
    | Select DisplayName, SignInName, RoleDefinitionName, ObjectType, Scope `
    | ft