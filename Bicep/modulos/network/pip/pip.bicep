param location string
param pipGwName string
param tags object = {}

resource pip 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: pipGwName
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

output id string = pip.id
