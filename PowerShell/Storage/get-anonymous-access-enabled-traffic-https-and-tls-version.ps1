<#
.SYNOPSIS
    Lista a versão de TLS, se o Acesso Publico ao Blob e Permitido e se o Https Traffic Only esta ou nao habilitado

.DESCRIPTION
    Lista a versão de TLS, se o Acesso Publico ao Blob e Permitido e se o Https Traffic Only esta ou nao habilitado

.EXAMPLE
    .\get-anonymous-access-enabled-traffic-https-and-tls-version

.NOTES
    Nome: get-anonymous-access-enabled-traffic-https-and-tls-version
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/get-anonymous-access-enabled-traffic-https-and-tls-version.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Definindo diretorio de destino do export do arquivo CSV
$outputCsv = "C:\TEMP\StoragesAnonymousAccessTlsVersionHttpsTraffic.csv"

# Guardando dados no Array
$outputData = @()

# Get de todas as subscriptions habilitadas
$subs = Get-AzSubscription | Where-Object {$_.State -eq "Enabled"}

# Analisando cada subscription
foreach ($sub in $subs) {

    # Set the current subscription context
    Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext

    # Get em todas as storages accounts
    $sas = Get-AzStorageAccount

    # Analisando cada storage account
    foreach ($sa in $sas) {

        # Criando estrutura para o arquivo de Export
        $outputObject = [PSCustomObject]@{
            Subscription           = $sub.Name
            StorageAccountName     = $sa.StorageAccountName
            ResourceGroupName      = $sa.ResourceGroupName
            AnonymousAccessEnabled = $sa.AllowBlobPublicAccess
            HttpsTrafficOnly       = $sa.EnableHttpsTrafficOnly
            TLSVersion             = ($sa).MinimumTlsVersion
        }

        # Adicionando os objetos de consulta no Array de saida
        $outputData += $outputObject

    }

}

# Export para o arquivo CSV
$outputData | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Output "Export completed. CSV file saved to $outputCsv"