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
- Resource dependencies: implicit dependency, Bicep will first deploy the plan before it deploys the app
    ```bicep
    resource appServicePlan 'Microsoft.Web/serverFarms@2021-03-01' = {
        name: 'toy-product-launch-plan'
        location: 'westus3'
        sku: {
            name: 'F1'
        }
    }
    ```
    ```bicep
    resource appServiceApp 'Microsoft.Web/sites@2021-03-01' = {
        name: 'toy-product-launch-1'
        location: 'westus3'
        properties: {
            serverFarmId: appServicePlan.id // reference to app service plan using the symbolic name, getting the resource ID property
            httpsOnly: true
        }
    }
    ```
    - Resource ID: unique identifier for each resource, includes:
        - Azure subscription ID
        - Resource group name
        - Resource name

### 2.2 Add flexibility to your templates by using parameters, variables, and expressions
- **Parameters and variables**
    - Used for things that can change between different deployments
        - unique names
        - locations
        - pricing: SKUs, tiers, instance counts
        - credentials
    - Add a parameter
        - definition
        - default values
        - usage in templates
        - definition
- **Expressions**
    - Resource locations
    - Resource names
    - Combined strings
    - Selectiing SKUs for resources

### 2.3 Create and deploy a Bicep template that includes modulesa