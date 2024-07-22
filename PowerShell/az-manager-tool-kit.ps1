<#
.SYNOPSIS
    Instala Kit de Ferramentas para Administração do Ambiente Azure via PowerShell, Az CLI e Azure Bicep.

.DESCRIPTION
    As ferramentas para Administração do Azure, disponíveis nesse script, são instaladas via WinGet, portanto, garanta que você o tenha instalado em sua estação de trabalho.
    Caso exista alguma ferramenta da qual você não utilize, basta comentar a linha que faz referência ou excluí-la antes da execução.

.EXAMPLE
    Execute o script como Administrador.

.NOTES
    Nome: az-manager-tool-kit
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/az-manager-tool-kit.ps1
#>

##### Instala Kit de Ferramentas para Administração do Ambiente Azure
winget install Microsoft.AzureStorageExplorer
winget install Microsoft.Bicep
winget install Microsoft.AzureCLI
winget install -e --id Microsoft.Azure.AZCopy.10
winget install Microsoft.WindowsTerminal
winget install Microsoft.PowerShell
winget install Microsoft.VisualStudioCode
winget install Git.Git
winget install GitHub.cli

##### Instala o Modulo "Az" para o PowerShell
pwsh.exe
Install-Module Az

##### Instala as Extensões Úteis para Agilizar o Desenvolvimento dos Scripts 
code --install-extension ms-azuretools.vscode-bicep #Bicep
code --install-extension ms-azuretools.vscode-docker #Docker
code --install-extension ms-dotnettools.vscode-dotnet-runtime #.NET Install Tool
code --install-extension ms-vscode.azurecli #Azure CLI Tools
code --install-extension ms-vscode.powershell #PowerShell
code --install-extension msazurermtools.azurerm-vscode-tools #Azure Resource Manager (ARM) Tools
code --install-extension dracula-theme.theme-dracula #Dracula Theme