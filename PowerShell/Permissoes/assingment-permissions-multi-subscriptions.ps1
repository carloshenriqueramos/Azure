<#
.SYNOPSIS
    Atribui permissao a um ou mais usuarios em uma ou mais Subscriptions

.DESCRIPTION
    Atribui permissao a um ou mais usuarios em uma ou mais Subscriptions

.EXAMPLE
    .\assingment-permissions-multi-subscriptions.ps1

.NOTES
    Nome: assingment-permissions-multi-subscriptions
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Permissoes/assingment-permissions-multi-subscriptions.ps1
#>

# Connect ao Azure
Connect-AzAccount

# UPN dos usuarios
$users = "user1@dominio.com","user2@dominio.com"

# IDs das Subscriptions
$subs = "ID1","ID2"

# Guardando dados no Array
$output = @()

# Analisando cada subscription
foreach($sub in $subs){

    Get-AzSubscription -SubscriptionId $sub | Set-AzContext
    
    # Analisando cada Usuario
    foreach ($user in $users){

        # Atribuindo a permissao
        New-AzRoleAssignment -SignInName $user -RoleDefinitionName "Reader" -Scope "/subscriptions/$sub"
       
        # Get das Permissoes do Usuario
        $permission = Get-AzRoleAssignment -SignInName $user -Scope "/subscriptions/$sub" | Select DisplayName, SignInName, RoleDefinitionName 

        # Criando estrutura para o arquivo de Export
        $outputObject = [PSCustomObject]@{

            Subscription           = $sub
            DisplayName            = $permission.DisplayName | Select-Object -Unique # Remove a duplicidade de Nome
            SignInName             = $permission.SignInName | Select-Object -Unique  # Remove a duplicidade de UPN
            RoleDefinitionName     = $permission.RoleDefinitionName -join ","

        }

        # Adicionando os objetos de consulta no Array de saida
        $output += $outputObject

    }

}

# Report Permissions
$output | ft