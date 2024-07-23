<#
.SYNOPSIS
    Habilita o Trafego apenas por Http em todas as Storage Accounts e em seguida, lista todas as Storage Accounts

.DESCRIPTION
    Habilita o Trafego apenas por Http em todas as Storage Accounts e em seguida, lista todas as Storage Accounts

.EXAMPLE
    .\enable-https-traffic-only-all-storages.ps1

.NOTES
    Nome: enable-https-traffic-only-all-storages
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/enable-https-traffic-only-all-storages.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Guardando dados no Array
$output = @()

# Definindo diretorio de destino do export do arquivo CSV
$outputCsv = "C:\TEMP\Storages.csv"

# Get em todas as storages accounts
$sas = Get-AzStorageAccount

# Ativa EnableHttpsTrafficOnly
foreach ($sa in $sas) {

    Write-host "Validando se o Https Traffic Only para a Storage Account" $sa.StorageAccountName "esta ativado"
    
    if($sa.EnableHttpsTrafficOnly -eq $false) {
            
        Write-host "Https Traffic Only desativado para a Storage Account $sa.StorageAccountName" -BackgroundColor Red
        Write-host "Ativando Https Traffic Only para a Storage Account" $sa.StorageAccountName
        Set-AzStorageAccount -Name $sa.StorageAccountName -ResourceGroupName $sa.ResourceGroupName -EnableHttpsTrafficOnly $true

    }
    
    else {

        Write-host "Https Traffic Only da Storage Account:" $sa.StorageAccountName "ativado" -BackgroundColor Green
    }      

}

# Get em todas as storages accounts para gerar o relatorio
$allsa = Get-AzStorageAccount | Select StorageAccountName, ResourceGroupName, EnableHttpsTrafficOnly

# Analisando cada Storage Account
ForEach ($storage in $allsa){

    # Criando estrutura para para o arquivos de Export
    $output += New-Object PSObject -property $([ordered]@{
       
        StorageAccount      = $storage.StorageAccountName
        ResourceGroupName   = $storage.ResourceGroupName
        StatusHttpsTraffic  = $storage.EnableHttpsTrafficOnly

    })
}

# Export para o arquivo CSV
$output | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Output "Export completed. CSV file saved to $outputCsv"