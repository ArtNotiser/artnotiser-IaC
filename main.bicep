var location = resourceGroup().location
var appNameSuffix = 'dev'
var functionAppName = 'fa-artnotiser-${appNameSuffix}'
var appServicePlanName = 'asp-artnotiser-${appNameSuffix}'
var appInsightsName = 'ai-artnotiser-${appNameSuffix}'
var functionStorageAccountName = 'fnsaartnotiser${appNameSuffix}'
var businessStorageAccountName = 'saartnotiser${appNameSuffix}'
var keyVaultName = 'kv-artnotiser-${appNameSuffix}'
var serviceBusName = 'sb-artnotiser-${appNameSuffix}'

resource functionStorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: functionStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource businessStorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: businessStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource serviceBus 'Microsoft.ServiceBus/namespaces@2021-01-01-preview' = {
  name: serviceBusName
  location: location
  sku: {
    name: 'Basic'
  }
}

resource newobservations_queue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  name: '${serviceBus.name}/newobservations'
}

resource notifications_queue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  name: '${serviceBus.name}/notifications'
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource plan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appServicePlanName
  location: location
  kind: 'functionapp'
  sku: {
    name: 'Y1'
  }
  properties: {}
}

resource functionApp 'Microsoft.Web/sites@2020-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: plan.id
    siteConfig: {
    }
    httpsOnly: true
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
  }
}

var functionStorageAccountConnection = 'DefaultEndpointsProtocol=https;AccountName=${functionStorageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(functionStorageAccount.id, functionStorageAccount.apiVersion).keys[0].value}'

var functionAppStandardSettings = {
  APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
  APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.properties.ConnectionString
  AzureWebJobsStorage: functionStorageAccountConnection
  FUNCTIONS_EXTENSION_VERSION: '~4'
  FUNCTIONS_WORKER_RUNTIME: 'dotnet'
  WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: functionStorageAccountConnection
  WEBSITE_CONTENTSHARE: functionAppName
}

var serviceBusEndpoint = '${serviceBus.id}/AuthorizationRules/RootManageSharedAccessKey'
var businessStorageAccountConnection = 'DefaultEndpointsProtocol=https;AccountName=${businessStorageAccount.name};AccountKey=${listKeys(businessStorageAccount.id, businessStorageAccount.apiVersion).keys[0].value};EndpointSuffix=core.windows.net'

var functionAppCustomSettings = {
  StorageAccountConnectionString: businessStorageAccountConnection
  ServiceBusConnectionString: 'Endpoint=sb://${serviceBus.name}.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=${listKeys(serviceBusEndpoint, serviceBus.apiVersion).primaryKey}'
}

var functionAppSettings = union(functionAppStandardSettings, functionAppCustomSettings)

module functionAppSettingsModule 'modules/appSettings.bicep' = {
  name: 'functionAppSettings'
  params: {
    appSettings: functionAppSettings
    currentAppSettings:list(resourceId('Microsoft.Web/sites/config', functionApp.name, 'appsettings'), '2022-03-01').properties
    webAppName: functionAppName
  }
}
