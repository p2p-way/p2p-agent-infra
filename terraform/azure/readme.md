# P2P agent on Azure

 1. [Description](#description)
 2. [Considerations](#considerations)
 3. [Limitations](#limitations)
 4. [Regions](#regions)
 5. [Costs](#costs)
 6. [Requirements](#requirements)
 7. [Deployment](#deployment)
 8. [Cleanup](#cleanup)
 9. [Known issues](#known-issues)


## [Description](#p2p-agents-on-azure)

 This code provides [Terraform](../readme.md) configuration for [Microsoft Azure](https://azure.microsoft.com/) stack deployment for P2P content distribution.
 1. [Azure Functions](https://azure.microsoft.com/en-us/products/functions) - Run a function which will act as watcher and orchestrate VM provisioning via Azure Monitor.
 2. [Azure Functions](https://azure.microsoft.com/en-us/products/functions) - Provides a scheduler to invoke the function.
 3. [Azure Blob Storage](https://azure.microsoft.com/en-us/products/storage/blobs) - Provides storage for the function.
 4. [Azure Virtual Network](https://azure.microsoft.com/en-us/products/virtual-network) - Provides a network for the VM.
 5. [Azure Monitor](https://azure.microsoft.com/en-us/products/monitor) - Scale VM instances.
 6. [Azure Virtual Machine Scale Sets](https://azure.microsoft.com/en-us/products/virtual-machine-scale-sets) - VM provisioning and management.
 7. [Azure Monitor Log Analytics Workspace](https://azure.microsoft.com/en-us/products/monitor) - Logs.
 8. [Azure Data Explorer Insights](https://azure.microsoft.com/en-us/products/monitor) - Metrics.

 Generally, this configuration will do the following

**Watcher and scheduler**
 > [!NOTE]
 > Watcher and scheduler is not implemented yet
 1. Create a blob storage for the function.
 2. Create a function with the scheduler.

**Agent**
 1. Create a Virtual Network for VM instances.
 2. Create Virtual Machine Scale Sets for the VMs.
 3. Create an Monitor to scale VMs.


## [Considerations](#p2p-agents-on-azure)

 1. Check [Considerations](../readme.md#considerations).


## [Limitations](#p2p-agents-on-azure)

 1. Most of the Azure Regions have 3 Availability Zones, but some of them haven't, for more information please read [Availability zone service and regional support](https://learn.microsoft.com/en-us/azure/reliability/availability-zones-service-support).
 2. Watcher is not implemented yet and we should set variable [`start_time`](../readme.md#configuration) only as `now` or specify a custom time.
 3. [Remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/remote) for Terraform is not implemented yet and state will be stored locally.


## [Regions](#p2p-agents-on-azure)

 - [Azure geographies](https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/)
 - [Explore the core elements of Azure’s global infrastructure](https://infrastructuremap.microsoft.com/explore)
 - [Products available by region](https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/)
 - [Availability zone service and regional support](https://learn.microsoft.com/en-us/azure/reliability/availability-zones-service-support)
 - [List regions](https://learn.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az-account-list-locations)

   ```shell
   # List supported regions for the current subscription
   az account list-locations --output table

   # Regions
   az account list-locations \
     --query '[?type==`Region`].{"Geography group":metadata.geographyGroup, Name:name, "Display Name":displayName, Geography:metadata.geography, Location:metadata.physicalLocation, Category:metadata.regionCategory, Type:type, "Region type":metadata.regionType}' \
     --output table

   # Physical regions
   az account list-locations \
     --query 'sort_by([?metadata.regionType==`Physical`].{"Geography group":metadata.geographyGroup, Name:name, "Display Name":displayName, Geography:metadata.geography, Location:metadata.physicalLocation, Category:metadata.regionCategory, Type:type, "Region type":metadata.regionType}, &"Geography group")' \
     --output table

   # Europe regions
   az account list-locations \
     --query '[?metadata.geographyGroup==`Europe`].{"Geography group":metadata.geographyGroup, Name:name, "Display Name":displayName, Geography:metadata.geography, Location:metadata.physicalLocation, Category:metadata.regionCategory, Type:type, "Region type":metadata.regionType}' \
     --output table

   # List availability zones (~ 25 seconds, ~ 57 MB)
   az vm list-skus --zone --resource-type virtualMachines \
     | jq -r '
     [group_by(.locationInfo[].location | ascii_upcase)[]
     | { Location: .[0].locationInfo[].location,
      Count:[.[] | .locationInfo[].zones] | add | unique | length,
      Zones: [.[] | .locationInfo[].zones] | add | sort | unique | join(" ") }]
     | to_entries | (["#", "Location", "Count", "Zones"]
     | (., map(length*"-"))), (.[] |[.key, .value.Location, .value.Count, .value.Zones])
     | @tsv' \
     | column -ts$'\t'

   # List available sizes for VMs in a region
   az vm list-sizes -l eastus2 \
     --query '[].{Name:name, Cores:numberOfCores, Memory:memoryInMB, "OS Disk":osDiskSizeInMB, "Resource Disk":resourceDiskSizeInMB}' \
     --output table

   # List small VMs in a region
   az vm list-sizes -l eastus2 \
     --query '[?numberOfCores<=`2`].{Name:name, Cores:numberOfCores, Memory:memoryInMB, "OS Disk":osDiskSizeInMB, "Resource Disk":resourceDiskSizeInMB}' \
     --output table

   # Check AZ for instance type in all regions
   az vm list-skus --zone --size standard_b1s --output table

   # Check AZ for instance type in a region
   az vm list-skus --location eastus2 --zone --size standard_b1s --output table
   ```


## [Costs](#p2p-agents-on-azure)

 [Pricing calculator](https://azure.microsoft.com/en-us/pricing/calculator/)

 | Resource                                                                                             | Price            | Costs           | Comment                                       |
 | ---------------------------------------------------------------------------------------------------- | ---------------- | --------------- | --------------------------------------------- |
 | [Virtual Machine](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/#pricing) | `0.0218 $/h`     | `16.22 $/m`     | Standard_B1s / Brazil South - São Paulo State |
 | [Managed Disk](https://azure.microsoft.com/en-us/pricing/details/managed-disks/#pricing)             | `6.74 $/32GiB/m` | `6.32 $/30GB/m` |                                               |
 | [Bandwidth](https://azure.microsoft.com/en-us/pricing/details/bandwidth/#pricing)                    | `0.12 $/GB`      | `12 $/100GB`    |                                               |
 | TOTAL                                                                                                |                  | `34.54 $/m`     |                                               |

```
34.54 $/m/i / 31 d =  1.11 $/d/i   # 1 day / 1 instance / 1 region
 1.11 $/d/i x 47 r = 52.17 $/d/i/r # 1 day / 1 instance / all regions
```

 Run **1 instance** in **all public regions**, during **1 day**, may cost ~ **52.17 $**

 > [!NOTE]
 > Provided costs are very approximate because we use a highest instance price and traffic across all the regions. Also, free grants may not cover multiple instances running for a long period of time.


## [Requirements](#p2p-agents-on-azure)

 In order to proceed with this deployment, we need
 1. Linux host with [Terraform](https://developer.hashicorp.com/terraform/install) and [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed.
 2. Azure user account with the administrative permissions.


## [Deployment](#p2p-agents-on-azure)

 1. Get Terraform code from GitHub repository
    ```shell
    git clone https://github.com/p2p-way/p2p-agent-infra

    cd p2p-agent-infra/terraform/azure
    ```

 2. Select the required regions where to run agents
    ```shell
    mv regions/region-* .
    ```
    Pleasee check [Known issues](#known-issues) for more information about [Regions](#regions).

 3. Configure input data for deployment in *variables.auto.tfvars* file
    ```shell
    vi variables.auto.tfvars
    ```
    For more information, please see [Configuration](../readme.md#configuration).

 4. Authenticate on Azure
    ```shell
    az login

    export ARM_SUBSCRIPTION_ID="00000000-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    ```

 5. Run Terraform
    ```shell
    # Initialize
    terraform init

    # View execution plan
    terraform plan

    # Apply changes
    terraform apply
    ```

 6. Get SSH keys
    ```shell
    # Agent - Private key
    terraform output -raw instance_private_key

    # Agent - Public key
    terraform output -raw instance_public_key

    # Repository - Private key
    terraform output -raw repository_private_key

    # Repository - Public key
    terraform output repository_public_key
    ```

 7. Add value of the `repository_public_key` output to the Git repository
    - GitHub: Repository --> Settings --> Security --> Deploy keys

 After some period of time all resources will be created and nodes will start. After the start, they will connect to the control center and will setup all configuration required to support P2P content distribution.


### [Update configuration](#p2p-agents-on-azure)

 After we deployed initial configuration, it maybe required to update nodes capacity or add more regions. And next steps mainly depends on the start time we set.

 **Nodes not started yet**

 Update is very transparent and we need just to set `desired_capacity` with the required number and run Terraform.

 > [!NOTE]
 > Please note, that computed start/stop time value will not be changed and in case we need that, we should increase `time_offset_version`.

 **Nodes already started**

 When nodes already started, following things are happened
 - Desired capacity of the Virtual Machine Scale Sets was changed by the start Scaling, from 0 to the value we set at the apply, and Terraform will try to set it back to 0 and it will lead to the termination of the running instances and new instances will be run by the new Scaling start and it will lead to the down-time.

 To overcome this, we should set `initial_deploy = false` and Terraform will change it's behavior in the following way
 - Capacity for Scaling, which is initially set to 0, will use value from `desired_capacity`.

 Update variable in the *variables.auto.tfvars* file
 ```shell
 vi variables.auto.tfvars
 ```
 ```
 initial_deploy = false
 ```


#### [Update capacity](#p2p-agents-on-azure)

 1. Set `initial_deploy = false` in the *variables.auto.tfvars*.
 2. Set `desired_capacity` in the *variables.auto.tfvars* globaly, or set it per region in the module configuration.
 3. Run `terraform plan`.
 4. Run `terraform apply`.


#### [Add new region](#p2p-agents-on-azure)

 1. Set `initial_deploy = false` in the *variables.auto.tfvars*.
 2. Add a configuration file for the new region.
 3. Set `initial_deploy = true` in the module configuration, for this new region only.
 4. Run `terraform init`.
 5. Run `terraform plan`.
 6. Run `terraform apply`.
 7. Set back `initial_deploy = var.initial_deploy` in the module configuration, for this new region, and it will imply usage of the globaly defined value in the *variables.auto.tfvars*.
 8. Run `terraform plan`.
 9. Run `terraform apply`.


## [Cleanup](#p2p-agents-on-azure)

 In order to cleanup all created resources we should use the following steps
 1. Cleanup resources created by Terraform
    ```shell
    terraform destroy
    ```


## [Known issues](#p2p-agents-on-azure)

 1. [Arm-based VM solutions](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview) are limited only to the some series, which are available only in select regions.

 2. In some regions instances were not tested due to the errors or limits.
    <details>
    <summary>More details</summary>

    [Resolve errors for SKU not available](https://learn.microsoft.com/en-us/azure/azure-resource-manager/troubleshooting/error-sku-not-available?tabs=azure-cli)
    ```shell
    az vm list-skus --location eastus2euap --size Standard_B --all --output table
    ```

    **Virtual Machine Scale Sets is created but instances fail to start**
    ```
    The requested VM size for resource 'Following SKUs have failed for Capacity Restrictions: Standard_B1s' is currently not available in location 'centralus'. Please try another size or deploy to a different location or different zone. See https://aka.ms/azureskunotavailable for details.
    ```
    And UI show the following errors
    > Standard_B1s: This size is not available in zone 1,2,3. Zones '3,1' are supported 

    > Your subscription doesn't support virtual machine creation in West India. Choose a different location.

    - `1-region-south-central-us.tf / (zone 1, 2 failed)`
    - `1-region-west-india.tf / (no zones in the region)`
    - `1-region-west-europe.tf / (zone 2 failed)`

    **DisallowedLocation**
    ```
    Error: creating Resource Group "p2p-agent-jio-india-west": resources.GroupsClient#CreateOrUpdate: Failure responding to request: StatusCode=400 -- Original Error: autorest/azure: Service returned an error. Status=400 Code="DisallowedLocation" Message="The provided location 'jioindiawest' is not permitted for subscription. List of permitted regions is 'australiacentral,australiacentral2,australiaeast,australiasoutheast,austriaeast,belgiumcentral,brazilsouth,brazilsoutheast,canadacentral,canadaeast,centralindia,centralus,centraluseuap,chilecentral,denmarkeast,eastasia,eastus,eastus2,eastus2euap,francecentral,francesouth,germanynorth,germanywestcentral,indonesiacentral,israelcentral,israelnorthwest,italynorth,japaneast,japanwest,koreacentral,koreasouth,malaysiasouth,malaysiawest,mexicocentral,newzealandnorth,northcentralus,northeurope,norwayeast,norwaywest,polandcentral,qatarcentral,southafricanorth,southafricawest,southcentralus,southcentralus2,southeastasia,southeastus,southindia,spaincentral,swedencentral,swedensouth,switzerlandnorth,switzerlandwest,taiwannorth,taiwannorthwest,uaecentral,uaenorth,uksouth,ukwest,westcentralus,westeurope,westindia,westus,westus2,westus3,asia,asiapacific,australia,brazil,canada,devfabric,europe,global,india,japan,northwestus,uk,france,germany,switzerland,korea,norway,uae,southafrica,unitedstates,unitedstateseuap,westuspartner,singapore,sweden,italy,israel,newzealand,poland,qatar,indonesia,mexico,spain,taiwan,malaysia,eastus3,eastusslv,southeastus3,southeastus5,southwestus'. Please contact support to change your supported regions."
    ```
    - `2-region-jio-india-west.tf`
    </details>

 3. Some [regions](#regions) which are listed in the `az account list-locations` output, does not support some resources
    <details>
    <summary>More details</summary>

    **LocationNotAvailableForResourceGroup**
    ```
    Error: creating Resource Group "p2p-agent-brazil-southeast": resources.GroupsClient#CreateOrUpdate: Failure responding to request: StatusCode=400 -- Original Error: autorest/azure: Service returned an error. Status=400 Code="LocationNotAvailableForResourceGroup" Message="The provided location 'brazilsoutheast' is not available for resource group. List of available regions is 'eastasia,southeastasia,australiaeast,australiasoutheast,brazilsouth,canadacentral,canadaeast,switzerlandnorth,germanywestcentral,eastus2,eastus,centralus,northcentralus,francecentral,uksouth,ukwest,centralindia,southindia,jioindiawest,italynorth,japaneast,japanwest,koreacentral,koreasouth,mexicocentral,northeurope,norwayeast,polandcentral,qatarcentral,swedencentral,uaenorth,westcentralus,westeurope,westus2,westus,southcentralus,westus3,southafricanorth,australiacentral,australiacentral2,israelcentral,westindia'."
    ```

    **LocationNotAvailableForResourceType**
    ```
    Error: creating/updating Virtual Network (Subscription: "ad9b3337-5cb5-6c83-2421-156ffc29dd1b"
    Resource Group Name: "p2p-agent-australia-central-2"
    Virtual Network Name: "p2p-agent-australia-central-2"): network.VirtualNetworksClient#CreateOrUpdate: Failure sending request: StatusCode=400 -- Original Error: Code="LocationNotAvailableForResourceType" Message="The provided location 'australiacentral2' is not available for resource type 'Microsoft.Network/virtualNetworks'. List of available regions for the resource type is 'westus,eastus,northeurope,westeurope,eastasia,southeastasia,northcentralus,southcentralus,centralus,eastus2,japaneast,japanwest,brazilsouth,australiaeast,australiasoutheast,centralindia,southindia,westindia,canadacentral,canadaeast,westcentralus,westus2,ukwest,uksouth,koreacentral,koreasouth,francecentral,australiacentral,southafricanorth,uaenorth,switzerlandnorth,germanywestcentral,norwayeast,westus3,jioindiawest,swedencentral,qatarcentral,polandcentral,italynorth,israelcentral,mexicocentral'."
    ```
    - `3-region-australia-central-2.tf`
    - `3-region-brazil-southeast.tf`
    - `3-region-brazil-us.tf`
    - `3-region-france-south.tf`
    - `3-region-germany-north.tf`
    - `3-region-jio-india-central.tf`
    - `3-region-norway-west.tf`
    - `3-region-south-africa-west.tf`
    - `3-region-switzerland-west.tf`
    - `3-region-uae-central.tf`

    **was not found in the list of supported Azure Locations**

    [Validate service updates to avoid disruption to your production API Management instances](https://learn.microsoft.com/en-us/azure/api-management/validate-service-updates)
    ```
    Error: "eastusstg" was not found in the list of supported Azure Locations: "australiacentral,australiacentral2,australiaeast,australiasoutheast,brazilsouth,brazilsoutheast,brazilus,canadacentral,canadaeast,centralindia,centralus,centraluseuap,eastasia,eastus,eastus2,eastus2euap,francecentral,francesouth,germanynorth,germanywestcentral,israelcentral,italynorth,japaneast,japanwest,jioindiacentral,jioindiawest,koreacentral,koreasouth,malaysiasouth,mexicocentral,northcentralus,northeurope,norwayeast,norwaywest,polandcentral,qatarcentral,southafricanorth,southafricawest,southcentralus,southeastasia,southindia,spaincentral,swedencentral,swedensouth,switzerlandnorth,switzerlandwest,uaecentral,uaenorth,uksouth,ukwest,westcentralus,westeurope,westindia,westus,westus2,westus3,austriaeast,chilecentral,eastusslv,indonesiacentral,israelnorthwest,malaysiawest,newzealandnorth"
    ```
    - `East US STG - Virginia / eastusstg`
    - `Central US EUAP - Canary / centraluseuap`
    - `East US 2 EUAP - Canary / eastus2euap`
    </details>
