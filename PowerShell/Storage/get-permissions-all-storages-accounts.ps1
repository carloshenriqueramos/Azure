<#
.SYNOPSIS
    Lista as permissoes de todas as Storage Accounts da Subscricao

.DESCRIPTION
    Lista as permissoes de todas as Storage Accounts da Subscricao

.EXAMPLE
    .\get-permissions-all-storages-accounts.ps1

.NOTES
    Nome: get-permissions-all-storages-accounts
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/get-permissions-all-storages-accounts.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Get todas Storage Accounts
$sas = Get-AzStorageAccount

# Guardando dados no Array
$output = @()

# Definindo diretorio de destino do export do arquivo CSV
$outputCsv = "C:\TEMP\Storages.csv"

# Analisando cada Storage Account
foreach($sa in $sas){

    #$select = Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts' -Name $sa.StorageAccountName | Select Name, ResourceGroupName
    $permissoes = Get-AzRoleAssignment -ResourceGroupName $sa.ResourceGroupName -ResourceName $sa.StorageAccountName -ResourceType 'Microsoft.Storage/storageAccounts' `
        | Select @{N='Storage';E={$sa.StorageAccountName}}, DisplayName, SignInName, RoleDefinitionName, ObjectType, Scope `

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