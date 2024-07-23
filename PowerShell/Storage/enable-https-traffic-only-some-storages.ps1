<#
.SYNOPSIS
    Habilita o Trafego apenas por Http em algumas Storage Accounts, baseado no fornecimento dos nomes dessas Storages via arquivo TXT e em seguida, lista todas as Storage Accounts

.DESCRIPTION
    Habilita o Trafego apenas por Http em algumas Storage Accounts, baseado no fornecimento dos nomes dessas Storages via arquivo TXT e em seguida, lista todas as Storage Accounts


.EXAMPLE
    O arquivo TXT com os nomes das Storage Accounts deve conter um nome abaixo do outro
    .\enable-https-traffic-only-some-storages.ps1

.NOTES
    Nome: enable-https-traffic-only-some-storages
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/enable-https-traffic-only-some-storages.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Guardando dados no Array
$output = @()

# Definindo diretorio de destino do export do arquivo CSV
$outputCsv = "C:\TEMP\Storages.csv"

$file = Read-Host "Informe o caminho contendo o arquivo TXT com o nome das Storage Accounts"

# Definindo local onde esta o arquivo txt com as Storage Accounts
$sa = get-content $file

# Analisando cada storage account
foreach ($sa in $sas) {

    # Seleciona as informacoes da Storage Account que esta sendo informada no For
    $allStorages = Get-AzStorageAccount | Select StorageAccountName, ResourceGroupName, EnableHttpsTrafficOnly | Where {$_.StorageAccountName -like "*$sa*"}

    # Verifica se a Storage Account esta com o HttpsTrafficOnly desativado e ativa
    if($allStorages.EnableHttpsTrafficOnly -eq $false) {
            
        Write-host "Https Traffic Only desativado para a Storage Account $allStoragessa.StorageAccountName" -BackgroundColor Red
        Write-host "Ativando Https Traffic Only para a Storage Account" $allStorages.StorageAccountName
        Set-AzStorageAccount -Name $allStorages.StorageAccountName -ResourceGroupName $allStorages.ResourceGroupName -EnableHttpsTrafficOnly $true

    }
    
    else {

        Write-host "Https Traffic Only da Storage Account:" $allStorages.StorageAccountName "ativado" -BackgroundColor Green
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