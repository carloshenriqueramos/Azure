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
var pipName = 'pip-nat-poc-${location}-001'

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

// Exibe IP Publico
output ip string = pip.properties.ipAddress

// Como usar?
// az deployment group create -g rg-network-poc-001 --template-file new-pip.bicep
