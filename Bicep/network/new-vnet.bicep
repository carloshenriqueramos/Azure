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
var vnetName = 'vnet-poc-${location}-001'
var addressSpaceVnet = '10.0.0.0/8'

var snetVmsName = 'snet-vms-poc-${location}-001'
var snetAksName = 'snet-aks-poc-${location}-001'
var snetPeName = 'snet-pe-poc-${location}-001'

var addressSpaceSnetVms = '10.0.0.0/27'
var addressSpaceSnetAks = '10.0.0.32/27'
var addressSpaceSnetPe = '10.0.0.64/27'

resource myvnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
   name: vnetName
   location: location
   properties: {
     addressSpace:{
       addressPrefixes: [
        addressSpaceVnet
       ]
     }
     subnets: [
       {
         name: snetVmsName
         properties: {
           addressPrefix: addressSpaceSnetVms
         }
       }
       {
         name: snetAksName
         properties: {
           addressPrefix: addressSpaceSnetAks
         }
       }
       {
        name: snetPeName
        properties: {
          addressPrefix: addressSpaceSnetPe
        }
      }
     ]
   }
   tags: tags
}

// Como usar?
// az deployment group create -g rg-network-poc-001 --template-file new-vnet.bicep
