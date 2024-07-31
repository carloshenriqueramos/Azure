<#
.SYNOPSIS
    Busca se determinado IP está em algum Registro contidos nas Zona DNS, baseado no fornecimento dos IPs via arquivo TXT

.DESCRIPTION
    Busca se determinado IP está em algum Registro contidos nas Zona DNS, baseado no fornecimento dos IPs via arquivo TXT

.EXAMPLE
    O arquivo TXT com os IPs deve conter um IP abaixo do outro
    .\check-if-ip-exist-in-all-dns-zones-in-all-subscriptions.ps1

.NOTES
    Nome: check-if-ip-exist-in-all-dns-zones-in-all-subscriptions
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/DNS/check-if-ip-exist-in-all-dns-zones-in-all-subscriptions.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Solicita arquivo TXT com os IPs a serem pesquisados
$file = Read-Host "Informe o caminho contendo os IPs a serem pesquisados nas Zonas DNS"

# Definindo local onde esta o arquivo txt com os IPs
$ips = get-content $file

# Get de todas as subscriptions habilitadas
$subs = Get-AzSubscription | Where-Object {$_.State -eq "Enabled"}

# Analisando cada subscription
ForEach ($sub in $subs){
    
    # Obtendo as Zona DNS
    Get-AzDnsZone | ForEach-Object {
        
        # Obtendo cada registro da Zona
        $dnszones = Get-AzDnsRecordSet -ZoneName $_.name -ResourceGroupName $_.ResourceGroupName
        
    }

    # Analisando cada IP
    ForEach ($ip in $ips) {

            # Filtrando e exportando o registro em que o IP foi identificado
            $dnszones | Where-object { $_.Records -match $ip } | Select ZoneName, Name, Records | Out-File C:\Temp\dns.txt -Append
       
    }

}