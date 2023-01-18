param name string
param location string = resourceGroup().location

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2022-05-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'standard'
  }
  properties: {
    softDeleteRetentionInDays: 1
  }
}

resource appConfigValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  name: 'ArtportalenApiUrl'
  parent: appConfig
  properties: {
    value: 'https://api.artportalen.se/v1'
  }
}
