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

// Define location no momento do Deployment
param location string = deployment().location

// Definicao das Variaveis
var rgName = 'rg-network-${location}-poc-001'

var vnetName = 'vnet-poc-${location}-001'
var addressSpaceVnet = '10.0.0.0/8'

var snetVmsName = 'snet-vms-poc-${location}-001'
var snetAksName = 'snet-aks-poc-${location}-001'
var snetPeName = 'snet-pe-poc-${location}-001'

var addressSpaceSnetVms = '10.0.0.0/27'
var addressSpaceSnetAks = '10.0.0.32/27'
var addressSpaceSnetPe = '10.0.0.64/27'

var pipGwName = 'pip-nat-poc-${location}-001'
var natGwName = 'ngw-poc-${location}-001'

var nsgName = 'nsg-snet-vms-poc-${location}-001'

// Cria o Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
  tags: tags
}

// Carrega o Modulo do Public IP
module pip 'pip/pip.bicep' = {
  scope: resourceGroup
  name: pipGwName
  params: {
    location: location
    pipGwName: pipGwName
    tags: tags
  }
}

// Carrega o Modulo do Nat Gateway
module natgw 'nat-gateway/nat-gateway.bicep' = {
  scope: resourceGroup
  name: natGwName
  params: {
    location: location
    natGwName: natGwName
    pipGwIp: pip.outputs.id
    tags: tags
  }
}

// Carrega o Modulo da VNET
module vnet 'vnet/vnet.bicep' = {
  scope: resourceGroup
  name: vnetName
  params: {
    tags: tags
    location: location
    addressSpaceVnet: addressSpaceVnet
    subnets: [
      {
        name: snetVmsName
        properties: {
          addressPrefix: addressSpaceSnetVms
          networkSecurityGroup: {
            id: nsg.outputs.id
          }
          natGateway:{
            id: natgw.outputs.id
           }
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
    vnetName: vnetName
  }
}

// Carrega o Modulo do NSG
module nsg 'nsg/nsg.bicep' = {
  scope: resourceGroup
  name: nsgName
  params: {
    location: location
    nsgName: nsgName
    tags: tags
  }
}

// Como usar?
// az deployment sub create -l eastus --template-file poc-main.bicep
