<#
.SYNOPSIS
    Lista as permissoes de uma ou "N" Storage Account

.DESCRIPTION
    Lista as permissoes de uma ou "N" Storage Account

.EXAMPLE
    .\get-permissions-mult-storages.ps1

.NOTES
    Nome: get-permissions-mult-storages
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/get-permissions-mult-storages.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Solicita nome das Storage Accounts
$storages = Read-Host "Informe o nome das Storage Accounts = Ex: sa1,sa2,sa3"

# Separando as Storages
$sas = $storages -split ','

# Guardando dados no Array
$output = @()

# Definindo diretorio de destino do export do arquivo CSV
$outputCsv = "C:\TEMP\Storages.csv"

# Analisando cada Storage Account
foreach($sa in $sas){

    $select = Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts' -Name $sa | Select Name, ResourceGroupName
    $permissoes = Get-AzRoleAssignment -ResourceGroupName $select.ResourceGroupName -ResourceName $select.Name -ResourceType 'Microsoft.Storage/storageAccounts' `
        | Select @{N='Storage';E={$select.Name}}, DisplayName, SignInName, RoleDefinitionName, ObjectType, Scope `

    # Analisando cada Permissao
    foreach ($permissao in $permissoes) {
        
        # Criando estrutura para para o arquivo de Export
        $outputObject = [PSCustomObject]@{
        
            StorageAccount          = $permissao.Storage
            DisplayName             = $permissao.DisplayName
            SignInName              = $permissao.SignInName
            RoleDefinitionName      = $permissao.RoleDefinitionName
            ObjectType              = $permissao.ObjectType
            Scope                   = $permissao.Scope

        }

        $output += $outputObject
    }
}

# Export para o arquivo CSV
$output | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Output "Export completed. CSV file saved to $outputCsv"