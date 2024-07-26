<#
.SYNOPSIS
    Obtem informacoes sobre o Hybrid Benefit dos Azure SQL Databases

.DESCRIPTION
    Obtem informacoes sobre o Hybrid Benefit dos Azure SQL Databases

.EXAMPLE
    .\get-sqldb-hybrid-benefit.ps1

.NOTES
    Nome: get-sqldb-hybrid-benefit
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Banco%20de%20Dados/SQL%20Server/get-sqldb-hybrid-benefit.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Guardando dados no Array
$sqlDbs = @()

# Definindo diretorio de destino do export do arquivo CSV
$outputCsv = "C:\TEMP\AzSqlDbInfoHybrid.csv"

# Get de todas as subscriptions habilitadas
$subs = Get-AzSubscription | Where-Object {$_.State -eq "Enabled"}

# Analisando cada subscription
foreach ( $sub in $subs ){
    
    # Set the current subscription context
    Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext

    # Get de todas os Azure SQL Databases e adiciona ao Array
    $sqlDbs +=Get-AzResource -ResourceType "Microsoft.Sql/servers" `
    | ForEach-Object -Process {Get-AzSqlDatabase -ServerName $_.Name -ResourceGroupName $_.ResourceGroupName} `
    | Select-Object @{Name="Subscription"; Expression={$sub.name}},ResourceGroupName,ServerName,DatabaseName,Location,LicenseType,CreationDate

}

# Export para o arquivo CSV
$sqlDbs | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Output ""
Write-Output "Export completed. CSV file saved to $outputCsv"