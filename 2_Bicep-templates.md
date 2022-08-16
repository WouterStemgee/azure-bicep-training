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
- Resource dependencies: **implicit dependency**, Bicep will first deploy the plan before it deploys the app
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

### 2.3 Create and deploy a Bicep template that includes modules
- **Group related resources by using modules**
    - create individual Bicep files, called modules, for different parts of your deployment
    - the main Bicep template can reference these modules
    - behind the scenes, modules are transpiled into a single JSON template for deployment
    - makes Bicep code more reusable
- **Outputs**
    - a way for your Bicep code to send data back to whoever or whatever started the deployment
    - example use-cases: 
        - return the public IP address so you can SSH into the created machine
        - composed name of the app the template has deployed so it can be used within a deployment pipeline to publish the application binaries
    - code: `output appServiceAppName string = appServiceAppName`
        - `output`: tells Bicep you're defining an output.
        - `appServiceAppName`: name of the output, when someone deploys the template successfully, the output values will include the name you specified so they can access the values they're expecting
        - `string`: type of the output, outputs support the same types as parameters
    - note: a value must be specified for each output, unlike parameters, outputs always need to have values
        - output values can be expressions, references to parameters or variables, or properties of resources that are deployed within the file
