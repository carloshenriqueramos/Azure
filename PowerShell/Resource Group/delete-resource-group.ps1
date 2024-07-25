<#
.SYNOPSIS
    Remove Resource Group

.DESCRIPTION
    Remove Resource Group

.EXAMPLE
    .\delete-resource-group.ps1

.NOTES
    Nome: delete-resource-group
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Resource%20Group/delete-resource-group.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Solicita nome do Resource Group e Localizacao
$resourceGroupName = read-host "Informe o nome do Resource Group a ser Removido"

# Obtendo informacoes do Resource Group
$rg = Get-AzResourceGroup -Name $resourceGroupName

# Lista os Recursos no Resource Group
Write-Host "Listando os Recursos do Resource Group"
Get-AzResource -ResourceGroupName $rg.ResourceGroupName | Select Name, ResourceType

# Solicitando confirmacao para remocao do Resource Group
Write-Host ""
$confirmation = Read-Host "Deseja prosseguir com remocao do Resource Group? (S/N)"

if ($confirmation.ToUpper() -ne "S") {
  Write-Host "Remocao do Resource Group cancelado."
  return
}

# Remove Resource Group
$rg | Remove-AzResourceGroup -Force

Write-Host "Resource Group" $resourceGroupName "Removido!"