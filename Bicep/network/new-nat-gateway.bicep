// Definicao das Tags dos Recursos
param dateTime string = utcNow('d')
param tags object = {
  AMBIENTE: 'POC'
  DATACRIACAO: dateTime
  APLICACAO: 'MTP Authorizer'
  MANAGEBY: 'Azure Bicep'
  CLIENTE: 'PagoNxt'
  RESPONSAVEL: 'Alex'
}

// Definicao de Localizacao         
param location string = resourceGroup().location

// Definicao das Variaveis
var pipName = 'pip-nat-poc-${location}-001'
var natGwName = 'ngw-poc-${location}-001'

resource pip 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: pipName
  location: location
  sku: {
    name:'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
  tags: tags
}

resource natgw 'Microsoft.Network/natGateways@2024-01-01' = {
  name: natGwName
  location: location
  sku:{
    name: 'Standard'
  }
  properties:{
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: pip.id
      }
    ]
  }
  tags: tags
}

// Exibe IP Publico
output ip string = pip.properties.ipAddress

// Como usar?
// az deployment group create -g rg-network-poc-001 --template-file new-nat-gateway.bicep
