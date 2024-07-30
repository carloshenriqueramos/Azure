<#
.SYNOPSIS
    Lista todos os Registros contidos nas Zona DNS, baseado no fornecimento dos nomes dessas Zonas DNS via arquivo TXT

.DESCRIPTION
    Lista todos os Registros contidos nas Zona DNS, baseado no fornecimento dos nomes dessas Zonas DNS via arquivo TXT

.EXAMPLE
    O arquivo TXT com os nomes das Zonas DNS deve conter um nome abaixo do outro
    .\get-some-dns-zone-and-records.ps1

.NOTES
    Nome: get-some-dns-zone-and-records
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/DNS/get-some-dns-zone-and-records.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Solicita arquivo TXT com o nome das Zonas DNS
$file = Read-Host "Informe o caminho contendo o arquivo TXT com o nome das Zonas DNS"

# Definindo local onde esta o arquivo txt com as Zonas DNS
$dnsZones = get-content $file

# Get de todas as subscriptions habilitadas
$subs = Get-AzSubscription | Where-Object {$_.State -eq "Enabled"}

# Analisando cada subscription
foreach ($sub in $subs) {

    # Set the current subscription context
    Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext

    # Analisando cada Zona DNS inserida no arquivo TXT
    foreach ($dnsZone in $dnsZones){
        
        # Seleciona as informacoes da Zona DNS que esta sendo informada no For
        $zones = Get-AzDnsZone | Where {$_.Name -eq $dnsZone}

        # Valida se a variavel nao é Nula ou em Branco
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
                        SubscriptionName = $sub.name
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
   
    }

}