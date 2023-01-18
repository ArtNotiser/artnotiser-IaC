param name string
param location string = resourceGroup().location

resource serviceBus 'Microsoft.ServiceBus/namespaces@2021-01-01-preview' = {
  name: name
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
