//Definicao dos parametros
param location string
param sqlSrvName string
param sqlUser string

@secure()
param sqlPass string

param sqlDbName string
param sqlDbEdition string
param sqlDbObjective string
param sqlDbMaxSize string
param tags object = {}

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
