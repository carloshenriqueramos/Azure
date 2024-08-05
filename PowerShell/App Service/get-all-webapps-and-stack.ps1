<#
.SYNOPSIS
    Lista todos os WebApps, Function Apps e sua Stack

.DESCRIPTION
    Lista todos os WebApps, Function Apps e sua Stack

.EXAMPLE
    .\get-all-webapps-and-stack.ps1

.NOTES
    Nome: get-all-webapps-and-stack
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/App%20Service/get-all-webapps-and-stack.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Guardando dados no Array
$output = @()

# Definindo diretorio de destino do export do arquivo CSV
$outputCsv = "C:\TEMP\Apps.csv"

# Solicita as informacoes da Subscription
$subName = read-host "Digite o nome da Subscription" 

# Set the current subscription context
Set-azcontext $subName

# Get de todos os WebApps e Function Apps
$apps = get-azwebapp

# Analisando cada App
foreach($app in $apps){
    
    # Criando estrutura para o arquivo de Export
    $outputObject = [PSCustomObject]([ordered]@{

        Name = $app.name
        Hostname = $app.hostnames -join ","                    # Caso possuam mais de um custom domain, sera acrescentado aos a virgula
        State = $app.state
        Location = $app.Location
        Kind = $app.Kind
        Type = $app.Type
        LinuxFXConfig = $app.siteconfig.linuxfxversion         # Caso o App seja baseado em Linux
        WindowsFXConfig = $app.siteconfig.windowsfxversion     # Caso o App seja baseado em Windows

    })

    # Adicionando os objetos de consulta no Array de saida
    $output += $outputObject

}

# Export para o arquivo CSV
$output | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Output ""
Write-Output "Export completed. CSV file saved to $outputCsv"