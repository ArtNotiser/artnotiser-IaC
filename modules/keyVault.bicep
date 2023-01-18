param name string
param appConfigName string
param functionAppName string
param location string = resourceGroup().location

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2020-06-01' existing = {
  name: appConfigName
}

resource functionApp 'Microsoft.Web/sites@2020-06-01' existing = {
  name: functionAppName
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  properties: {
    enableSoftDelete: true
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: [
      {
        tenantId: functionApp.identity.tenantId
        objectId: functionApp.identity.principalId
        permissions: {
          keys: [
            'get'
          ]
          secrets: [
            'get'
          ]
        }
      }
      {
        tenantId: appConfig.identity.tenantId
        objectId: appConfig.identity.principalId
        permissions: {
          keys: [
            'get'
          ]
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}
