targetScope = 'subscription'

// Definicao das Tags dos Recursos
param dateTime string = utcNow('d')
param tags object = {
            AMBIENTE: ''
            DATACRIACAO: dateTime
            APLICACAO: ''
            MANAGEBY: 'Azure Bicep'
            CLIENTE: ''
            RESPONSAVEL: ''
         }

// Definicao de Localizacao         
param location string = 'eastus'

// Definicao dos Resource Groups
param rgs array = [
  'rg-network-poc-${location}-001'
  'rg-vms-poc-${location}-001'
]

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = [for rg in rgs: {
  name: '${rg}'
  location: location
  tags: tags
}]

// Como usar?
// az deployment sub create --template-file new-rgs-looping.bicep -l eastus
