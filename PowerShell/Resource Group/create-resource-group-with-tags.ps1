<#
.SYNOPSIS
    Cria Resource Group com Tags

.DESCRIPTION
    Cria Resource Group com Tags

.EXAMPLE
    .\create-resource-group-with-tags.ps1

.NOTES
    Nome: create-resource-group-with-tags
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/create-resource-group-with-tags.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Definicao de Tags
$tags = @{

   "ACN"="";
   "AMBIENTE"="";
   "ANOCRIACAO"="";
   "APLICACAO"="";
   "CC"="";
   "COMPARTILHADO"="";
   "DIRETORIA"="";
   "EMPRESA"=""
   "INICIATIVA"=""
}

# Solicita nome do Resource Group e Localizacao
$resourceGroupName = read-host "Informe o nome do Resource Group"
$location          = read-host "Informe a Localizacao do Resource Group"

# Cria Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location -Tag $tags

Write-host ""
Write-host "Resource Group" $resourceGroupName "criado!" -BackgroundColor Green