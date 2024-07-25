<#
.SYNOPSIS
    Verifica o tamanho de um Container e de seus Blobs

.DESCRIPTION
    Verifica o tamanho de um Container e de seus Blobs

.EXAMPLE
    .\calculate-container-size.ps1

.NOTES
    Nome: calculate-container-size
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/calculate-container-size.ps1
#>

# Funcao para determinar se o resultado da variavel tamanho e em B, KB, MB, GB, TB ou PB
Function Get-Format {
    Begin{
        $sufixo = @("B", "KB", "MB", "GB", "TB", "PB")
    }
    Process {

        for ($i=0; $tamanho -ge 1024 -and $i -lt $sufixo.Length; $i++) {
          $tamanho = $tamanho / 1024
        }
        return "" + [System.Math]::Round($tamanho,2) + " " + $sufixo[$i]
    }
}

# Connect ao Azure
Connect-AzAccount

# Solicita as informacoes de Resource Group e nome da Storage Account
$resourceGroupName = read-host "Informe o nome do Resource Group"
$storageAccountName = read-host "Informe o nome da Storage Account"
$containerName = read-host "Informe o nome do Container"

# Obtendo informacoes da Storage
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName 

# Definindo o contexto da Storage
$ctx = $storageAccount.Context 

# Obtendo a lista de blobs no Container 
$blobs = Get-AzStorageBlob -Container $containerName -Context $ctx 

# Variavel para controle do tamanho do Container
$tamanho = 0

# Analisando cada Blob do Container, coletando seu tamanho e adicionando ao total
$blobs | ForEach-Object {
    $tamanho = $tamanho + $_.Length
}

# Lista os Blobs existentes no Container e seu tamanho
Write-Host ""
Write-Host "Listando os Blobs existentes no Container" $containerName
$blobs | select Name, Length

Write-Host ""
Write-Host "Tamanho dos Blobs no Container" $containerName "e de:" (Get-Format)