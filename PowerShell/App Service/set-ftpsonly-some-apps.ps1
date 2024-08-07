<#
.SYNOPSIS
    Define o FTPsOnly como verdadeiro em diversos Apps

.DESCRIPTION
    Define o FTPsOnly como verdadeiro em diversos Apps

.EXAMPLE
    .\set-ftpsonly-some-apps.ps1.ps1

.NOTES
    Nome: set-ftpsonly-some-apps.ps1
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/App%20Service/set-ftpsonly-some-apps.ps1.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Nome da Subscription
$sub = "SUBNAME"

# Nome dos Apps
$apps = "fach1","wachr1"

# Guardando dados no Array
$output = @()

# Set the current subscription context
Get-AzSubscription -SubscriptionName $sub | Set-AzContext

# Analisando cada App
foreach ($app in $apps){

    # Obtem Detalhes do App
    $appInfo = get-azwebapp -Name $app

    # Configura o FTPsOnly como Verdadeiro
    Set-AzWebApp -Name $appInfo.Name -ResourceGroupName $appInfo.ResourceGroup -FtpsState FtpsOnly

}

# Analisando cada App
foreach ($app in $apps){

    # Obtem Detalhes do App
    $appInfo = get-azwebapp -Name $app

    # Criando estrutura para o arquivo de Export
    $outputObject = [PSCustomObject]@{
        
        ResourceGroup  = $appInfo.ResourceGroup 
        AppName        = $appInfo.Name 
        Type           = $appInfo.Type
        HttpsOnly      = $appInfo.HttpsOnly
        FtpsState      = $appInfo.SiteConfig.FtpsState

    }

    $output += $outputObject

}

# Exibe o resultado
$output | ft