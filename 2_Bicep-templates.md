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
    - Parameters: used for things that can change between different deployments
        - code: `param appServiceAppName string = 'toy-product-launch-1'`
        - usage:
            - unique names
            - locations
            - pricing: SKUs, tiers, instance counts
            - credentials
    - Variables: good option when you'll use the same values for each deployment, but you want to make a value reusable within the template, or you want to use expressions to create a complex value
        - code: `var appServicePlanName = 'toy-product-launch-plan'`
        - usage:
            - definition
            - override default values
            - usage in templates
- **Expressions**
    - Expressions: you often don't want to use hard-code values, or even ask for them to be specified in a parameter, instead, you want to discover values when the template runs
        - usage:
            - Resource locations: `param location string = resourceGroup().location`
                - note: some resources in Azure can be deployed only into certain locations, you might need separate parameters to set the locations of these resources
            - Resource names: `param storageAccountName string = uniqueString(resourceGroup().id)`
                - note: it's often a good idea to use template expressions to create resource names, many Azure resource types have rules about the allowed characters and length of their names, embedding the creation of resource names in the template means that anyone who uses the template doesn't have to remember to follow these rules themselves
            - Combined strings: `param storageAccountName string = 'toylaunch${uniqueString(resourceGroup().id)}'`
                - note: sometimes the `uniqueString()` function will create strings that start with a number, some Azure resources, like storage accounts, don't allow their names to start with numbers, this means it's a good idea to use string interpolation to create resource names
            - Selectiing SKUs for resources:
                - ```bicep
                    @allowed([
                    'nonprod'
                    'prod'
                    ])
                    param environmentType string
                  ```
                - ```bicep
                    var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'
                    var appServicePlanSkuName = (environmentType == 'prod') ? 'P2V3' : 'F1'
                  ```

### 2.3 Create and deploy a Bicep template that includes modules
- **Modules: group related resources**
    - create individual Bicep files, called modules, for different parts of your deployment
    - the main Bicep template can reference these modules
    - behind the scenes, modules are transpiled into a single JSON template for deployment
    - makes Bicep code more reusable
    - ![](assets\bicep-templates-modules.png)
    - defining a module
        - ```bicep
            module myModule 'modules/mymodule.bicep' = {
                name: 'MyModule'
                params: {
                    location: location
                }
            }
          ```
            - `module`: tells Bicep you're about to use another Bicep file as a module
            - `<symbolic name>`: use the symbolic name when you refer to the module's outputs in other parts of the template
            - `modules/mymodule.bicep`: the path to the module file, relative to the template file, this is just a regular Bicep file
            - `name`: mandatory, Azure uses the name of the module because it creates a separate deployment for each module within the template file
            - `params`: specify any parameters of the module, when you set the values of each parameter within the template, you can use expressions, template parameters, variables, properties of resources deployed within the template, and outputs from other modules, Bicep will automatically understand the dependencies between the resources.
    - design principles:
        - **A module should have a clear purpose**: use modules to define all of the resources related to a specific part of your solution
        - **Don't put every resource into its own module**: if you have a resource that has lots of complex properties, it might make sense to put that resource into its own module, but in general, it's better for modules to combine multiple resources
        - **A module should have clear parameters and outputs that make sense**: 
            - consider the purpose of the module, think about whether the module should be manipulating parameter values, or whether the parent template should handle that and then pass a single value through to the module. 
            - think about the outputs a module should return, and make sure they're useful to the templates that will use the module
        - **A module should be as self-contained as possible**: if a module needs to use a variable to define a part of a module, the variable should generally be included in the module file rather than in the parent template
        - **A module should not output secrets**: just like templates, don't create module outputs for secret values like connection strings or keys
- **Outputs**
    - a way for your Bicep code to send data back to whoever or whatever started the deployment
    - example use-cases: 
        - return the public IP address so you can SSH into the created machine
        - return the composed name of the app the template has deployed so it can be used within a deployment pipeline to publish the application binaries
    - code: `output appServiceAppName string = appServiceAppName`
        - `output`: tells Bicep you're defining an output.
        - `appServiceAppName`: name of the output, when someone deploys the template successfully, the output values will include the name you specified so they can access the values they're expecting
        - `string`: type of the output, outputs support the same types as parameters
    - note: a value must be specified for each output, unlike parameters, outputs always need to have values
        - output values can be expressions, references to parameters or variables, or properties of resources that are deployed within the file
