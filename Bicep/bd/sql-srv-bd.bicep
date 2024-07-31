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
var sqlSrvName = ''
var sqlUser = ''
var sqlPass = ''
var sqlDbName = ''
var sqlDbEdition = ''
var sqlDbObjective = ''
var sqlDbMaxSize = ''

resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: sqlSrvName
  location: location
  tags: tags
  properties: {
    administratorLogin: sqlUser
    administratorLoginPassword: sqlPass
    version: '12.0'
  }
}

// Verificar as edicoes das databases por regiao
// az sql db list-editions -l eastus -o table

resource sqlServerDatabase 'Microsoft.Sql/servers/databases@2014-04-01' = {
  parent: sqlServer
  name: sqlDbName
  location: location
  tags: tags
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    edition: sqlDbEdition
    maxSizeBytes: sqlDbMaxSize // https://convertlive.com/pt/u/converter/gigabytes/em/bytes#1
    requestedServiceObjectiveName: sqlDbObjective
  }
}
