<#
.SYNOPSIS
    Lista todos os Resource Groups sem Recursos

.DESCRIPTION
    Lista todos os Resource Groups sem Recursos

.EXAMPLE
    .\get-all-resource-group-empty.ps1

.NOTES
    Nome: get-all-resource-group-empty
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/Storage/get-all-resource-group-empty.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Guardando dados no Array
$output = @()

# Definindo diretorio de destino do export do arquivo CSV
$outputCsv = "C:\TEMP\ResourceGroupsEmpty.csv"

# Get de todas as subscriptions habilitadas
$subs = Get-AzSubscription | Where-Object {$_.State -eq "Enabled"}

# Analisando cada subscription
foreach ($sub in $subs) {

	# Set the current subscription context
    Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext

	# Get de todos os Resource Groups
	$rgs = Get-AzResourceGroup

	# Analisando cada Resource Group
	foreach ($rg in $rgs){
		
		# Obtem os recursos existentes no Resource Group
		$resources = Get-AzResource -ResourceGroupName $rg.ResourceGroupName 
		
		# Valida se o Resource Group esta vazio
		if ($resources -eq $null) {
				
			# Analisando cada Resource Group Vazio
			ForEach ($rgempty in $rg){

				# Criando estrutura para o arquivo de Export
				$outputObject = [PSCustomObject]@{
					
					Subscription	   = $sub.Name
					ResourceGroupEmpty = $rg.ResourceGroupName

				}
				
				# Adicionando os objetos de consulta no Array de saida
				$output += $outputObject 

			}
		
		}
			
	}

}

# Export para o arquivo CSV
$output | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Output ""
Write-Output "Export completed. CSV file saved to $outputCsv"