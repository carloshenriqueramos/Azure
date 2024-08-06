# Importando modulo necessario Az.Storage module
Import-Module Az.Storage

# Connect ao Azure
Connect-AzAccount

# Definindo diretorio de destino do export do arquivo CSV
$outputCsv = "C:\TEMP\ContainerPublic.csv"

# Guardando dados no Array
$outputData = @()

# Get de todas as subscriptions
$subscriptions = Get-AzSubscription

# Analisando cada subscription
foreach ($subscription in $subscriptions) {
    # Set the current subscription context
    Set-AzContext -SubscriptionId $subscription.Id

    # Get em todas as storages accounts em cada subscription
    $storageAccounts = Get-AzStorageAccount

    # Analisando cada storage account
    foreach ($storageAccount in $storageAccounts) {
        # Get do context da Storage Account
        $ctx = $storageAccount.Context

        # Get nas propriedades selecionadas
        $blobServiceProperties = Get-AzStorageBlobServiceProperty -Context $ctx

        # Verificando se o acesso ananimo esta habilitado.
        $anonymousAccessEnabled = if ($blobServiceProperties.PublicAccess -ne $null) { "Yes" } else { "No" }

        # Get de todos os containers
        $containers = Get-AzStorageContainer -Context $ctx

        # Analisando cada container
        foreach ($container in $containers) {
            # Get no PublicAccess de cada container
            $publicAccessLevel = $container.PublicAccess

            # Criando estrutura para para o arquivos de Export
            $outputObject = [PSCustomObject]@{
                SubscriptionId         = $subscription.Id
                SubscriptionName       = $subscription.Name
                StorageAccountName     = $storageAccount.StorageAccountName
                ResourceGroupName      = $storageAccount.ResourceGroupName
                ContainerName          = $container.Name
                AnonymousAccessEnabled = $anonymousAccessEnabled
                PublicAccessLevel      = $publicAccessLevel
            }

            # Adicionando os objetos de consulta no Array de saida
            $outputData += $outputObject
        }
    }
}

# Export para o arquivo CSV
$outputData | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Output "Export completed. CSV file saved to $outputCsv"