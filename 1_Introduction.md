## 1. Introduction to infrastructure as code using Bicep
Infrastructure as code, sometimes referred to as IaC, is the process of provisioning infrastructure resources similar to how software is deployed.

![](assets/iac_template.png)

### 1.1 Benefits of infrastructure as code
- Increase confidence in deployments
    - **integration with current processes**: peer reviews on infrastructure configuration changes
    - **consistency**: helps teams to follow well-established processes to deploy infrastructure, reduce human error
    - **automated scanning**: automated scanning of the infrastructure configuration to ensure that security and performance practices are followed
    - **secret management**: integrate with secret stores (eg: Key Vault) to access secrets securely at deployment
    - **access control**: ability to use managed identities or service accounts, prevent unauthorized configuration changes, if necessary, this process can be overriden using an emergency access account (break glass account)
    - **avoid configuration drift**: idempotence, provide the same result each deployment
- Manage multiple environments
    - **provision new environments**: scale to multiple instances of the application
    - **non-production environments**: use the same configuration files for each environment, but supply different input parameters to create uniqueness
    - **disaster recovery**: recreate environemnt in another region because of a service outage, provision new instance to fail over instead of manually deploying and reconfiguring everything
- Better understand cloud resources
    - **audit trail**: changes to the infrastructure as code configurations are version-controlled in the same way as application source code
    - **documentation**: add metadata (like comments) to the infrastructure as code configurations which describes the purpose of the code in your configurations
    - **unified system**: using a common system for application and infrastructure code, it is easier to understand the relationship between applications and the infrastructure
    - **better understanding of cloud infrastructure**: when using graphical user interfaces (eg: Azure Portal) to provision resources, many of the processes are abstracted from view, infrastructure as code can help provide a better understanding of how Azure works and how to troubleshoot issues that might arise

### 1.2 Difference between declarative and imperative infrastructure as code
- **Imperative code**: execute a sequence of commands, in a specific order, to reach an end configuration.
    - defines what the code should accomplish
    - defines how to accomplish the task
    - "step-by-step instruction manual"
    - accomplished programmatically by using a scripting language (Bash, Azure PowerShell)
    - Azure CLI example:
        ```bash
        #!/usr/bin/env bash
        az group create \
            --name storage-resource-group \
            --location eastus

        az storage account create \
            --name mystorageaccount \
            --resource-group storage-resource-group \
            --kind StorageV2 \
            --access-tier Hot \
            --https-only true
        ```
    - disadvantages:
        - scripts can become complex to manage in a growing architecture
        - commands may be updated or deprecated, which requires modifications to existing scripts
- **Declarative code**
    - declarative approach is like the "exploded-view drawing" of an instruction manual, showing the different components and the relationship between them
    - accomplished by using **templates**, many types are available:
        - JSON
        - Azure Bicep
        - Ansible (by RedHat)
        - Terraform (by HashiCorp)
    - Azure Bicep template example:
        ```bash
        resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
            name: 'mystorageaccount'
            location: 'eastus'
            sku: {
                name: 'Standard_LRS'
            }
            kind: 'StorageV2'
            properties: {
                accessTier: 'hot'
                supportsHttpsTrafficOnly: true
            }
        }
        ```
    - disadvantages:
        - the template doesn't define how to accomplish the task, the actual steps are executed behind the scenes


### 1.3 What is Bicep? How does it fits into an infrastructure as code approach?