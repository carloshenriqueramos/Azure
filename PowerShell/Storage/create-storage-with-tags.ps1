<#
.SYNOPSIS
    Cria Storage Account com Tags

.DESCRIPTION
    Cria Storage Account com Tags

.EXAMPLE
    .\create-storage-with-tags.ps1

.NOTES
    Nome: create-storage-with-tags
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/create-storage-with-tags.ps1
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

# Solicita nome da Storage Account
$storageAccountName = read-host "Informe o nome da Storage Account"

# Valida se o nome desejado da Storage Account esta disponivel
$saNameAvailable = (Get-AzStorageAccountNameAvailability -Name $storageAccountName).NameAvailable

if ($saNameAvailable) {

   $resourceGroupName = read-host "Informe o nome do Resource Group"
   $location = read-host "Informe a Localizacao do Resource Group e Storage Account"
   $sku = read-host "Informe o SKU da Storage Account"

   # Opcoes                                            SkuName 
   #Locally redundant storage (LRS)	                 = Standard_LRS
   #Zone-redundant storage (ZRS)	                    = Standard_ZRS
   #Geo-redundant storage (GRS)	                    = Standard_GRS
   #Read-access geo-redundant storage (RAGRS)	     = Standard_RAGRS
   #Geo-zone-redundant storage (GZRS)	              = Standard_GZRS
   #Read-access geo-zone-redundant storage (RA-GZRS) = Standard_RAGZRS

   # Cria Storage Account
   New-AzStorageAccount -ResourceGroupName $resourceGroupName `
      -Name $storageAccountName `
      -Location $location `
      -SkuName $sku `
      -Kind StorageV2 `
      -Tag $tags `
      -EnableHttpsTrafficOnly $true `
      -AllowBlobPublicAccess $false `
      -MinimumTlsVersion TLS1_2

      Write-host "Storage Account" $storageAccountName "criada!" -BackgroundColor Green

   } 
   
   else
      
      {
         Write-host "Nome" $storageAccountName "ja esta em uso, por favor escolha outro nome" -BackgroundColor Red
         Exit 1
      }