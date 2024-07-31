param location string
param pipGwIp string
param natGwName string
param tags object = {}

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
        id: pipGwIp
      }
    ]
  }
  tags: tags
}

output id string = natgw.id
