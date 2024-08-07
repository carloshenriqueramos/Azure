<#
.SYNOPSIS
    Atribui permissao a um ou mais usuarios em um Resource Group

.DESCRIPTION
    Atribui permissao a um ou mais usuarios em um Resource Group

.EXAMPLE
    .\assingment-permission-rg.ps1

.NOTES
    Nome: assingment-permission-rg
    VersÃ£o 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Permissoes/assingment-permission-rg.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Solicita as informacoes
$sub = read-host "Informe o nome da Subscription"
$rg = Read-Host "Informe o nome do Resource Group"
$role = Read-Host "Informe a Role a ser Atribuida"
$users = read-host "Informe o nome dos Usuarios ou Grupo"

# Guardando dados no Array
$output = @()

# Set the current subscription context
Get-AzSubscription -SubscriptionName $sub | Set-AzContext

# Obtem o ResourceId do Resource Group
$rgId = (Get-AzResourceGroup -Name $rg).ResourceId

# Analisando cada Usuario
foreach ($user in $users){

    # Atribuindo a permissao
    New-AzRoleAssignment -SignInName $user -RoleDefinitionName $role -Scope "$rgId"
       
    # Get das Permissoes do Usuario no Resource Group
    $permission = Get-AzRoleAssignment -SignInName $user -Scope "$rgId" | Select DisplayName, SignInName, RoleDefinitionName 

    # Criando estrutura para o arquivo de Export
    $outputObject = [PSCustomObject]@{

        Subscription           = $sub
        DisplayName            = $permission.DisplayName | Select-Object -Unique # Remove a duplicidade de Nome
        SignInName             = $permission.SignInName | Select-Object -Unique  # Remove a duplicidade de UPN
        RoleDefinitionName     = $permission.RoleDefinitionName -join ","

    }

    $output += $outputObject

}

# Report Permissions
$output | ft