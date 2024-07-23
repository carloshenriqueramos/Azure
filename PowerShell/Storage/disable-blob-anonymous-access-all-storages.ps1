<#
.SYNOPSIS
    Desativa o acesso anonimo ao Blob em todas as Storage Accounts e em seguida, lista todas as Storage Accounts

.DESCRIPTION
    Desativa o acesso anonimo ao Blob em todas as Storage Accounts e em seguida, lista todas as Storage Accounts

.EXAMPLE
    .\disable-blob-anonymous-access-all-storages.ps1

.NOTES
    Nome: disable-blob-anonymous-access-all-storages
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/disable-blob-anonymous-access-all-storages.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Guardando dados no Array
$output = @()

# Definindo diretorio de destino do export do arquivo CSV
$outputCsv = "C:\TEMP\Storages.csv"

# Get em todas as storages accounts
$sas = Get-AzStorageAccount

# Analisando cada storage account
foreach ($sa in $sas) {

    Write-host "Validando se o Acesso Anonimo ao Blob para a Storage Account" $sa.StorageAccountName "esta ativado"
    
    # Verifica se o Acesso Anonimo ao Blob esta ativado
    if($sa.AllowBlobPublicAccess -eq $null -or $sa.AllowBlobPublicAccess -eq $true) {
            
        Write-host "Acesso Anonimo ao Blob ativado para a Storage Account $sa.StorageAccountName" -BackgroundColor Red
        Write-host "Desativando o Acesso Anonimo ao Blob para a Storage Account" $sa.StorageAccountName
        Set-AzStorageAccount -Name $sa.StorageAccountName -ResourceGroupName $sa.ResourceGroupName -AllowBlobPublicAccess $false

    }
    
    else {

        Write-host "Acesso Anonimo ao Blob desativado para a Storage Account:" $sa.StorageAccountName "ativado" -BackgroundColor Green
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