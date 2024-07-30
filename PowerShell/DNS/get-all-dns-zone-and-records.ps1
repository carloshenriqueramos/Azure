<#
.SYNOPSIS
    Lista todas as DNS Zone e seus Registros em uma Subscription

.DESCRIPTION
    Lista todas as DNS Zone e seus Registros em uma Subscription

.EXAMPLE
    .\get-all-dns-zone-and-records.ps1

.NOTES
    Nome: get-all-dns-zone-and-records
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/DNS/get-all-dns-zone-and-records.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Solicita o Nome da Subscription
$subname = read-host "Digite o nome da Subscription"

# Set the current subscription context
Get-AzSubscription -subscriptionname $subname | Set-azcontext

# Get em todas as Zonas DNS
$zones = Get-AzDnsZone

# Valida se a variavel nao e Nula ou em Branco
if (!([string]::IsNullOrEmpty($zones))) {

    # Analisando a Zona DNS
    foreach ($zone in $zones){

        # Guardando dados no Array
        $output = @()

        # Definindo diretorio de destino do export do arquivo CSV
        $outputCsv = "C:\TEMP\$($zone.Name).csv"

        # Obtendo Todos os Registros DNS da Zona
        $records = Get-AzDnsRecordSet -ResourceGroupName $zone.ResourceGroupName -ZoneName $zone.Name
        
        # Analisando Registro DNS
        foreach ($record in $records){

            # Criando estrutura para o arquivo de Export
            $outputObject = [PSCustomObject]([ordered]@{
                SubscriptionName = $subname
                RG               = $record.ResourceGroupName
                Zone             = $record.ZoneName
                Name             = $record.Name
                RecordType       = $record.recordtype
                Records          = $record.records -join ","
            })
        
            # Adicionando os objetos de consulta no Array de saida
            $output += $outputObject

        }
    
        # Export para o arquivo CSV
        $output | Export-Csv -Path $outputCsv -NoTypeInformation
        Write-Output "Export completed. CSV file saved to $outputCsv"

    }

}