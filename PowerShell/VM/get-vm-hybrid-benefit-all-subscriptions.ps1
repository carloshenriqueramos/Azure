<#
.SYNOPSIS
    Obtem informacoes sobre o Hybrid Benefit das VMs

.DESCRIPTION
    Obtem informacoes sobre o Hybrid Benefit das VMs

.EXAMPLE
    .\get-vm-hybrid-benefit-all-subscriptions.ps1

.NOTES
    Nome: get-vm-hybrid-benefit-all-subscriptions
    Versão 1.0.0
    Autor: Carlos Henrique | Azure Cloud Specialist | Azure Infrastructure
    Linkedin: https://www.linkedin.com/in/carloshenriqueramos
    E-mail: carlos.hramos@outlook.com

.LINK
    https://github.com/carloshenriqueramos/Azure/blob/main/PowerShell/VM/get-vm-hybrid-benefit-all-subscriptions.ps1
#>

# Connect ao Azure
Connect-AzAccount

# Guardando dados no Array
$output = @()

# Definindo diretorio de destino do export do arquivo CSV
$outputCsv = "C:\TEMP\VMsInfoHybrid.csv"

# Get de todas as subscriptions habilitadas
$subs = Get-AzSubscription | Where-Object {$_.State -eq "Enabled"}

# Analisando cada subscription
foreach ( $sub in $subs ){

    # Set the current subscription context
    Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext

    # Get de todas as VMs
    $vms = Get-AzVm 

    # Analisando cada VM
    foreach ($vm in $vms) {

        # Definindo as Propriedades da VM a serem inseridas no Relatorio
        $vmProps = $([ordered]@{
            Subscription = $sub.Name      
            ResourceGroup = $vm.ResourceGroupName                  
            VMname = $vm.Name
            VMSize = $vm.hardwareprofile.VmSize
            Region = $vm.Location
            LicenseType = $vm.LicenseType
            OsType = $vm.storageprofile.osdisk.ostype
            Publisher = $vm.storageprofile.imagereference.publisher
            Offer = $vm.storageprofile.imagereference.Offer
            Sku = $vm.storageprofile.imagereference.Sku
            CreationDate = $vm.TimeCreated
        })

        # Criando estrutura para o arquivo de Export
        $outputObject = New-Object -TypeName PSObject -Property $vmProps

        # Adicionando os objetos de consulta no Array de saida
        $output += $outputObject
    }
}

# Export para o arquivo CSV
$output | Export-Csv -Path $outputCsv -NoTypeInformation

Write-Output ""
Write-Output "Export completed. CSV file saved to $outputCsv"