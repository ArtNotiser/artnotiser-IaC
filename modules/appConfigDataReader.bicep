param functionAppName string

resource appConfigDataReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '516239f1-63e1-4d78-a4de-a74fb236a071'
}

resource functionApp 'Microsoft.Web/sites@2020-06-01' existing = {
  name: functionAppName
  scope: resourceGroup()
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, functionAppName)
  properties: {
    roleDefinitionId: appConfigDataReaderRoleDefinition.id
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
