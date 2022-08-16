param location string = resourceGroup().location
param namePrefix string = 'toylaunch'
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

// storage account
var storageAccountName = '${namePrefix}${uniqueString(resourceGroup().id)}'
var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

// app services
param appServiceAppName string = '${namePrefix}${uniqueString(resourceGroup().id)}'
module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    location: location
    appServiceAppName: appServiceAppName
    environmentType: environmentType
  }
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName
