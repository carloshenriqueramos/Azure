param location string = resourceGroup().location

// Criacao de Storage, Vnet e Subnet

// resource mystg 'Microsoft.Storage/storageAccounts@2023-05-01' = {
//   name: 'stochrbicep'
//   location: location
//   sku: {
//     name: 'Standard_LRS'
//   }
//   kind: 'StorageV2'
//   tags:{
//     'Manage-by': 'Bicep'
//   }
// }

// resource myvnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
//   name: 'vnet-bicep'
//   location: location
//   properties: {
//     addressSpace:{
//       addressPrefixes: [
//         '192.168.0.0/23'
//       ]
//     }
//     subnets: [
//       {
//         name: 'vnet-vms'
//         properties: {
//           addressPrefix: '192.168.0.0/24'
//         }
//       }
//       {
//         name: 'vnet-aks'
//         properties: {
//           addressPrefix: '192.168.1.0/27'
//         }
//       }
//     ]
//   }
//   tags:{
//     'Manage-by': 'Bicep'
//   }
// }
// FIM - Criacao de Storage, Vnet e Subnet

// Uso de Vnet existente
// resource vnetexist 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
//   name: 'vnet-chr'
// }

// resource subnetaks 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
//   name: 'vnet-aks2'
//   parent: vnetexist
//   properties: {
//     addressPrefix: '10.0.1.0/27'
//   }
// }
// FIM - Uso de Vnet existente

// Criacao de Vnets por ambiente
param environmets array = [
  'dev'
  'qa'
  'prod'
]

resource vnet 'Microsoft.Network/virtualNetworks@2019-11-01' = [for (env, index) in environmets: {
  name: 'vnet-${env}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.${index}.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.${index}.0.0/24'
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '10.${index}.1.0/24'
        }
      }
    ]
  }
}
]
// FIM - Criacao de Vnets por ambiente
