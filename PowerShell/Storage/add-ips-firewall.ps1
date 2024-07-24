<#
.SYNOPSIS
    Adiciona IPs para acesso a Storage Account em seguida, lista todos os IPs permitidos

.DESCRIPTION
    Adiciona IPs para acesso a Storage Account em seguida, lista todos os IPs permitidos

.EXAMPLE
    O arquivo TXT com todos os IPs que você quer liberar o acesso deve conter um IP abaixo do outro
    .\add-ips-firewall.ps1

.NOTES
    Nome: add-ips-firewall
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/add-ips-firewall.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Guardando dados no Array
$output = @()

# Definindo diretorio de destino do export do arquivo CSV
$outputCsv = "C:\TEMP\Storages.csv"

# Solicita as informacoes de Resource Group, nome da Storage Account e arquivo com os IPs
$resourceGroupName = read-host "Informe o nome do Resource Group"
$storageAccountName = read-host "Informe o nome da Storage Account"
$file = Read-Host "Informe o caminho contendo o arquivo TXT com os IPs a serem adicionados ao Firewall"

# Definindo local onde esta o arquivo txt com os IPs a serem inseridos na Storage Account
$ips = get-content $file

# Analisando cada IP
ForEach ($ip in $ips) {
    
    # Inserindo cada IP como autorizado a acessar a Storage Account
    Write-Output ""
    Write-Output "Permitindo o IP $ip acessar a Storage Account $storageAccountName"
    Add-AzStorageAccountNetworkRule -ResourceGroupName $resourceGroupName -AccountName $storageAccountName -IPAddressOrRange $ip

} 

Write-Output "Exibindo os IPs permitidos na Storage Account $storageAccountName"

# Get de todos os IPs configurados
$ipsPermitidos = (Get-AzStorageAccountNetworkRuleSet -AccountName $storageAccountName -ResourceGroupName $resourceGroupName).IpRules

# Analisando cada IP Permitido
ForEach ($permitido in $ipsPermitidos){

    # Criando estrutura para para o arquivos de Export
    $output += New-Object PSObject -property $([ordered]@{
       
        StorageAccount = $storageAccountName
        Ip             = $permitido.IPAddressOrRange
        Action         = $permitido.Action

    })
}

# Export para o arquivo CSV
$output | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Output "Export completed. CSV file saved to $outputCsv"