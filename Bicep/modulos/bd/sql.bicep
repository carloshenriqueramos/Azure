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
var rgName = 'rg-bd-${location}-poc-001'

var sqlsrvName = 'sql-srv-poc-${location}-001'
var sqlUser = 'sqladminpoc'
var sqlPass = 'w?RUWB6yzw89v91i'

// Verificar as edicoes das databases por regiao - az sql db list-editions -l eastus -o table
var dbName = 'db_mtp_authorizer'
var dbEdition = 'Basic'
var dbObjective = 'Basic'
var dbMaxSize = '2147483648' //Valor em Bytes - https://convertlive.com/pt/u/converter/gigabytes/em/bytes#1

// Cria o Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
  tags: tags
}

// Carrega Modulo de Azure SQL
module azsql 'sql/sql-srv-bd.bicep' = {
  scope: resourceGroup
  name: sqlsrvName
  params: {
    location: location
    sqlDbName: dbName
    sqlDbEdition: dbEdition
    sqlDbMaxSize: dbMaxSize
    sqlDbObjective: dbObjective
    sqlPass: sqlPass
    sqlSrvName: sqlsrvName
    sqlUser: sqlUser
    tags: tags
  }
}

// Como usar?
// az deployment sub create -l eastus --template-file bd.bicep
