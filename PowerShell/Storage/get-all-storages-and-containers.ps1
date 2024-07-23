<#
.SYNOPSIS
    Obtém todas as Storage Accounts, seus Containers e o Nível de Acesso Anônimo de cada um

.DESCRIPTION
    Obtém todas as Storage Accounts, seus Containers e o Nível de Acesso Anônimo de cada um

.EXAMPLE
    .\get-all-storages-and-containers.ps1

.NOTES
    Nome: get-all-storages-and-containers
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/get-all-storages-and-containers.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Definindo diretorio de destino do export do arquivo CSV
$outputCsv = "C:\TEMP\Storages.csv"

# Guardando dados no Array
$outputData = @()

# Get de todas as subscriptions habilitadas
$subs = Get-AzSubscription | Where-Object {$_.State -eq "Enabled"}

# Analisando cada subscription
foreach ($sub in $subs) {

    # Set the current subscription context
    Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext

    # Get em todas as storages accounts em cada subscription
    $storageAccounts = Get-AzStorageAccount

    # Analisando cada storage account
    foreach ($storageAccount in $storageAccounts) {
        
        # Get do context de cada Storage Account
        $ctx = $storageAccount.context

        # Get de todos os containers de cada Storage Account
        $containers = Get-AzStorageContainer -Context $ctx
        
        # Analisando cada container de cada Storage Account
        foreach($container in $containers){

            # Criando estrutura para para o arquivos de Export
            $outputObject = [PSCustomObject]@{
                                SubscriptionName = $sub.Name
                                StorageAccountName = $storageAccount.StorageAccountName
                                AllowBlobPublicAccess = $storageAccount.AllowBlobPublicAccess
                                ContainerName = $container.Name
                                PublicAccessLevel = $container.PublicAccess
                                ResourceGroup = $storageAccount.ResourceGroupName
                                Location = $storageAccount.Location
            }

            # Adicionando os objetos de consulta no Array de saida
            $outputData += $outputObject  

        }     
    }
}

# Export para o arquivo CSV
$outputData | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Output "Export completed. CSV file saved to $outputCsv"