## 2. Build your first Bicep template
### 2.1 Create and deploy Azure resources by using Bicep
- Bicep resource declaration
    ```bicep
    resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
        name: 'toylaunchstorage'
        location: 'westus3'
        sku: {
            name: 'Standard_LRS'
        }
        kind: 'StorageV2'
        properties: {
            accessTier: 'Hot'
        }
    }
    ```
    - Definitions:
        - `resource`: tells Bicep you are defining a resource
        - `storageAccount`: symbolic name of the resource, used within Bicep to refer to the resource (won't be used in Azure)
        - `Microsoft.Storage/storageAccounts@2021-08-01`: resource type and API version of the resource
            - `Microsoft.Storage/storageAccounts`: Bicep will create a resource of type 'Azure storage account'
            - `2021-08-01`: version of the Azure Storage API that Bicep will use to create the resource
        - `name`: the name the resource will be assigned in Azure
        - other details: location, SKU (pricing tier), kind
        - properties: can be different depending on the API version
- Resource dependencies

### 2.2 Add flexibility to your templates by using parameters, variables, and expressions

### 2.3 Create and deploy a Bicep template that includes modules