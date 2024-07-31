// Definicao das Tags dos Recursos
param dateTime string = utcNow('d')
param tags object = {
  AMBIENTE: ''
  DATACRIACAO: dateTime
  APLICACAO: ''
  MANAGEBY: ''
  CLIENTE: ''
  RESPONSAVEL: ''
}

// Definicao de Localizacao         
param location string = resourceGroup().location

// Definicao das Variaveis
var nsgName = 'nsg-poc-${location}-001'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: nsgName
  tags: tags
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSSH'
        properties: {
          description: ''
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

// Como usar?
// az deployment group create -g rg-network-chr --template-file new-nsg.bicep
