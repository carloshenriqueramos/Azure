<#
.SYNOPSIS
    Movimenta Recursos entre Resource Groups

.DESCRIPTION
    Movimenta Recursos entre Resource Groups

.EXAMPLE
    .\move-resources-between-resource-groups.ps1

.NOTES
    Nome: move-resources-between-resource-groups
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/move-resources-between-resource-groups.ps1
#>

# Connect ao Azure
#Connect-AzAccount

# Guardando dados no Array
$output = @()

# Solicita nome dos Resource Groups
$resourceGroupNameSource = read-host "Informe o nome do Resource Group de Origem"
$resourceGroupNameTarget = read-host "Informe o nome do Resource Group de Destino"

# Obtem a lista de recursos no Resource Group de Origem
$resources = Get-AzResource -ResourceGroupName $resourceGroupNameSource

# Criando estrutura para exibir os Recursos
# foreach ($resource in $resources) {
    
#     $outputObject = [PSCustomObject]@{
        
#         ResourceName = $resource.Name
#         Type         = $resource.ResourceType

#     }
#     # Adicionando os objetos de consulta no Array de saida
#     $output += $outputObject  
# }

# Lista os Recursos no Resource Group de Origem
Write-host ""
Write-host "Listando os Recursos no Resource Group de Origem" -BackgroundColor Yellow
Get-AzResource -ResourceGroupName $resourceGroupNameSource | ft

Write-host "Os recursos acima serao movimentados do Resource Group" $resourceGroupNameSource "para o" $resourceGroupNameTarget -BackgroundColor Yellow

# Solicitando confirmacao para movimentacao dos Recursos
Write-host ""
$confirmation = Read-Host "Deseja prosseguir com movimentacao dos Recursos? (S/N)"

if ($confirmation.ToUpper() -ne "S") {
  Write-Host "Movimentacao dos recursos cancelada." -BackgroundColor Yellow
  return
}

# Movimenta os Recursos de Resouce Group
Move-AzResource -DestinationResourceGroupName $resourceGroupNameTarget -ResourceId $resources.ResourceId -Force

# Lista os Recursos no Resouce Group de Destino
Write-host ""
Write-host "Listando os Recursos no Resoruce Group de Destino" $resourceGroupNameTarget
Get-AzResource -ResourceGroupName $resourceGroupNameTarget | ft