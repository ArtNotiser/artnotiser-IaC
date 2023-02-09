param location string = resourceGroup().location
param name string
param hostingPlanName string
param appInsightsName string
param storageAccountName string
param functionStorageAccountName string
param serviceBusName string
param appConfigName string

resource appInsights 'Microsoft.Insights/components@2015-05-01' existing = {
  name: appInsightsName
}

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2020-06-01' existing = {
  name: appConfigName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: storageAccountName
}

resource functionStorageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: functionStorageAccountName
}

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusName
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  kind: 'functionapp'
  sku: {
    name: 'Y1'
  }
  properties: { }
}

var endpoint = '${serviceBus.id}/AuthorizationRules/RootManageSharedAccessKey'

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    
    siteConfig: {
      netFrameworkVersion: 'v6.0'
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      appSettings: [] /* Settings are configured in main.bicep */
    }
  }
}
