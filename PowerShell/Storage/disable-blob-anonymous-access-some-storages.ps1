<#
.SYNOPSIS
    Desativa o acesso anonimo ao Blob das Storage Accounts, baseado no fornecimento dos nomes dessas Storages via arquivo TXT e em seguida, lista todas as Storage Accounts

.DESCRIPTION
    Desativa o acesso anonimo ao Blob das Storage Accounts, baseado no fornecimento dos nomes dessas Storages via arquivo TXT e em seguida, lista todas as Storage Accounts

.EXAMPLE
    O arquivo TXT com os nomes das Storage Accounts deve conter um nome abaixo do outro
    .\disable-blob-anonymous-access-some-storages.ps1

.NOTES
    Nome: disable-blob-anonymous-access-some-storages
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/disable-blob-anonymous-access-some-storages.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Guardando dados no Array
$output = @()

# Definindo diretorio de destino do export do arquivo CSV
$outputCsv = "C:\TEMP\Storages.csv"

$file = Read-Host "Informe o caminho contendo o arquivo TXT com o nome das Storage Accounts"

# Definindo local onde esta o arquivo txt com as Storage Accounts
$sas = get-content $file

# Analisando cada storage account
foreach ($sa in $sas) {

    # Seleciona as informacoes da Storage Account que esta sendo informada no For
    $allStorages = Get-AzStorageAccount | Select StorageAccountName, ResourceGroupName, AllowBlobPublicAccess | Where {$_.StorageAccountName -like "*$sa*"}

    # Verifica se o Acesso Anonimo ao Blob esta ativado
    if($allStorages.AllowBlobPublicAccess -eq $null -or $allStorages.AllowBlobPublicAccess -eq $true) {
            
        Write-host "Acesso Anonimo ao Blob ativado para a Storage Account $sa.StorageAccountName" -BackgroundColor Red
        Write-host "Desativando o Acesso Anonimo ao Blob para a Storage Account" $allStorages.StorageAccountName
        Set-AzStorageAccount -Name $allStorages.StorageAccountName -ResourceGroupName $allStorages.ResourceGroupName -AllowBlobPublicAccess $false

    }
    
    else {

        Write-host "Acesso Anonimo ao Blob esta desativado para a Storage Account:" $allStorages.StorageAccountName -BackgroundColor Green
    }      

}

# Get em todas as storages accounts para gerar o relatorio
$allsa = Get-AzStorageAccount | Select StorageAccountName, ResourceGroupName, AllowBlobPublicAccess

# Analisando cada Storage Account
ForEach ($storage in $allsa){

    # Criando estrutura para para o arquivos de Export
    $output += New-Object PSObject -property $([ordered]@{
       
        StorageAccount            = $storage.StorageAccountName
        ResourceGroupName         = $storage.ResourceGroupName
        StatusAcessoAnonimoBlob   = $storage.AllowBlobPublicAccess

    })
}

# Export para o arquivo CSV
$output | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Output "Export completed. CSV file saved to $outputCsv"