// Modulo de VNET
//Definicao dos parametros
param location string
param vnetName string
param addressSpaceVnet string
param subnets array
param tags object = {}

resource virtualnetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpaceVnet
      ]
    }
    subnets: subnets
  }
    tags: tags
}

output id string = virtualnetwork.id
