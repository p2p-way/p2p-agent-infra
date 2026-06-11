# P2P agents on OCI

 1. [Description](#description)
 2. [Considerations](#considerations)
 3. [Limitations](#limitations)
 4. [Regions](#regions)
 5. [Costs](#costs)
 6. [Requirements](#requirements)
 7. [Deployment](#deployment)
 8. [Cleanup](#cleanup)
 9. [Known issues](#known-issues)


## [Description](#p2p-agents-on-oci)

 This code provides [Terraform](https://www.terraform.io) configuration for [Oracle Cloud Infrastructure](https://cloud.oracle.com) stack deployment for P2P content distribution.
 1. [OCI Functions](https://www.oracle.com/cloud/cloud-native/functions/) - Run a function which will act as watcher and orchestrate VM provisioning via instance pool.
 2. [OCI Resource Scheduler](https://docs.oracle.com/en-us/iaas/Content/resource-scheduler/home.htm) - Provides a scheduler to invoke a function.
 3. [OCI Virtual Cloud Network](https://www.oracle.com/cloud/networking/virtual-cloud-network/) - Provides a network for the VM.
 4. [OCI Autoscaling](https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/autoscalinginstancepools.htm) - Scale and manage VM instances.
 5. [OCI Virtual Machines](https://www.oracle.com/cloud/compute/virtual-machines/) - VM provisioning.
 6. [OCI Logging service](https://docs.oracle.com/en-us/iaas/Content/Logging/home.htm) - Logs and Metrics.

 Generally, this configuration will do the following

**Watcher and scheduler**
 > [!NOTE]
 > Watcher and scheduler is not implemented yet
 1. Create a function.
 2. Create a scheduler using Resource Scheduler which will invoke a function.

**Agent**
 1. Create a VCN for VM instances.
 2. Create a instance configuration.
 3. Create a instance pool using instance configuration.
 4. Create a auto scaling configuration using instance pool.
 5. Create a log group.


## [Considerations](#p2p-agents-on-oci)

**Agent**
 1. Check [Agent consideration](../readme.md#agent-considerations).


## [Limitations](#p2p-agents-on-oci)

 1. Almost all of the OCI Regions have 1 Availability Domain and just some of supports thee AD's.
 2. Watcher is not implemented yet and we should set variable [`start_time`](../readme.md#agent) only as `now` or specify a custom time.
 3. [Remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/remote) for Terraform is not implemented and state will be stored locally.


## [Regions](#p2p-agents-on-oci)

 - [Public Cloud Regions](https://www.oracle.com/cloud/public-cloud-regions/)
 - [Regions and Availability Domains](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm)
 - [List the available regions based on subscription ID](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/index.html)
   ```shell
   # export OCI_CLI_AUTH=security_token

   # Lists all the regions offered by Oracle Cloud Infrastructure
   oci iam region list \
     | jq -r '.data |= sort_by(.name) | .data[] | join(" - ")'

   # Lists the shapes that can be used to launch an instance within the specified compartment
   oci compute shape list \
     --compartment-id <compartment-id> \
     --shape VM.Standard.A1.Flex
     # VM.Standard1.1

   # Lists a subset of images available in the specified compartment
   oci compute image list \
     --compartment-id <compartment-id> \
     --operating-system "Canonical Ubuntu" \
     | jq -r '.data |= sort_by(."time-created") | .data[]."display-name"'
   ```


## [Costs](#p2p-agents-on-oci)

 [Estimate Cloud Costs Easily | Oracle](https://www.oracle.com/cloud/costestimator.html)

 | Resource                                                                                         | Price            | Costs            | Comment             |
 | ------------------------------------------------------------------------------------------------- | --------------- | ---------------- | ------------------- |
 | [Ampere (Arm)-based instances](https://www.oracle.com/cloud/price-list/#pricing-compute) - CPU    | `0.0138 $/h`    | `10.2672 $/m`    | VM.Standard.A4.Flex |
 | [Ampere (Arm)-based instances](https://www.oracle.com/cloud/price-list/#pricing-compute) - Memory | `0.0027 $/h`    | `4.0176 $/m`     | VM.Standard.A4.Flex |
 | [Block Volume Storage](https://www.oracle.com/cloud/price-list/#pricing-storage)                  | `0.0255 $/GB/m` | `1.275 $/50GB/m` |                     |
 | [Networking](https://www.oracle.com/cloud/price-list/#pricing-networking)                         | `-`             | `-`              | First 10 TB / Month |
 | TOTAL                                                                                             |                 | `15.56 $/m`      |                     |

```
15.56 $/m/i / 31 d =  0.50 $/d/i   # 1 day / 1 instance / 1 region
 0.50 $/d/i x 44 r = 22.00 $/d/i/r # 1 day / 1 instance / all regions
```

 Run **1 instance** in **all public regions**, during **1 day**, may cost ~ **22.00 $**

 > [!NOTE]
 > Provided costs are very approximate because we use a highest instance price across all the regions. Also, free tier may not cover multiple instances running for a long period of time.


## [Requirements](#p2p-agents-on-oci)

 In order to proceed with this deployment, we need
 1. Linux host with [Terraform](https://developer.hashicorp.com/terraform/install) and [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) installed.
 2. OCI [IAM user](https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/addingusers.htm) with the following policy permissions
    ```
    Allow group 'p2p-agent-infra' to manage all-resources in tenancy
    ```


## [Deployment](#p2p-agents-on-oci)

 1. Get Terraform code from GitHub repository
    ```shell
    git clone https://github.com/slavasveta/p2p-agent-infra

    cd p2p-agent-infra/oci
    ```

 2. Select regions where to run agents
    ```shell
    mv regions/region-* .
    ```
    Pleasee check [Known issues](#known-issues) for more information about [Regions](#regions).

 3. Configure input data for deployment in *variables.auto.tfvars* file
    ```shell
    vi variables.auto.tfvars
    ```
    For more information, please see [Terraform configuration](../readme.md#terraform-configuration).

 4. Authenticate on [OCI](https://docs.oracle.com/en-us/iaas/Content/dev/terraform/configuring.htm#security-token-auth)
    ```shell
    # Variables
    export OCI_AUTH="SecurityToken"
    export OCI_CONFIG_FILE_PROFILE="<config_file_profile>"
    export OCI_REGION="<region>"
    export OCI_CLI_AUTH="security_token"
    export TF_VAR_tenancy_ocid="<tenancy_ocid or compartment_ocid>"

    # Authenticate
    oci session authenticate

    # Refresh
    oci session refresh
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

 7. Add value of the `repository_public_key` output to the Git repository, only when we [Use a private centralised repository](../readme.md#use-a-private-centralised-repository)
    - GitHub: Repository --> Settings --> Security --> Deploy keys

 After some period of time all resources will be created and nodes will start. After the start, they will connect to the control center and will setup all configuration required to support P2P content distribution.


### [Update configuration](#p2p-agents-on-oci)

 After we deployed initial configuration, it may be required to update nodes capacity or add more regions or even update control center configuration. And next steps mainly depends on the start time we set.

 **Nodes not started yet**

 Update is very transparent and we need just to set `desired_capacity` with the required number and run Terraform.

 > [!NOTE]
 > Please note, that computed start/stop time value will not be changed and in case we need that, we should increase `time_offset_version`.

 **Nodes already started**

 When nodes already started, following things are happened
 - Target instance count of the instance pool was changed by a start scheduler, from 0 to the value we set at the apply, and Terraform will try to set it back to 0 and it will lead to the termination of the running instances and new instances will be run by the new scheduler start and it will lead to the down-time.

 To overcome this, we should set `initial_deploy = false` and Terraform will change it's behavior in the following way
 - Capacity for instance pool, which is initially set to 0, will use value from `desired_capacity`.

 Update variable in the *variables.auto.tfvars* file
 ```shell
 vi variables.auto.tfvars
 ```
 ```
 initial_deploy = false
 ```


#### [Update capacity](#p2p-agents-on-oci)

 1. Set `initial_deploy = false` in the *variables.auto.tfvars*.
 2. Set `desired_capacity` in the *variables.auto.tfvars* globaly, or set it per region in the module configuration.
 3. Run `terraform plan`.
 4. Run `terraform apply`.


#### [Add new region](#p2p-agents-on-oci)

 1. Set `initial_deploy = false` in the *variables.auto.tfvars*.
 2. Add a configuration file for the new region.
 3. Run `terraform init`.
 4. Run `terraform plan`.
 5. Run `terraform apply`.
 6. Run `terraform plan`.
 7. Run `terraform apply`.


## [Cleanup](#p2p-agents-on-oci)

 In order to cleanup all created resources we should use the following steps
 1. Cleanup resources created by Terraform
    ```shell
    terraform destroy
    ```


## [Known issues](#p2p-agents-on-oci)

 1. [OCI Limits by Service](https://docs.oracle.com/en-us/iaas/Content/General/service-limits/default.htm) and [Compute Limits](https://docs.oracle.com/en-us/iaas/Content/General/service-limits/default.htm#computelimits) might not permit to run required number or type of instances and we have to follow [Creating a Limit Increase Request](https://docs.oracle.com/en-us/iaas/Content/General/service-limits/create-request.htm).

 2. Make sure you did subscribe to a region [Using the Console to Manage Infrastructure Regions](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingregions.htm#uconsole) before deployment.

 3. We should be aware about [Subscribed Region Limits](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm#limits) and that "**You can't unsubscribe from a region.**".

 4. In most of the regions instances were not tested due to a number of subscriptions limit
    - `1-region-*.tf`

 5. When we deploy agent in multiple regions and use `create_compartment = true` we could get an error and it will be required to re-run Terraform apply again. We could consider the following workarounds
    - Set `create_compartment = false` and resources will be created in a root compartment
    - Create a compartment manually and pass it using `TF_VAR_tenancy_ocid`
    <details><summary>Error details</summary>

    ```
    ╷
    │ Error: 404-NotAuthorizedOrNotFound, Authorization failed or requested resource not found.
    │ Suggestion: Either the resource has been deleted or service Core Vcn need policy to access this resource. Policy reference: https://docs.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm
    │ Documentation: https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn
    │ API Reference: https://docs.oracle.com/iaas/api/#/en/iaas/20160918/Vcn/CreateVcn
    │ Request Target: POST https://iaas.ap-sydney-1.oraclecloud.com/20160918/vcns
    │ Provider version: 8.18.0, released on 2026-06-10.
    │ Service: Core Vcn
    │ Operation Name: CreateVcn
    │ OPC request ID: 2a12d73d27a523b400b7e6041e293df4/B61B28513FE7E3878397296A535944D8/1B107A88812A1F30C54D9D6171312398
    │
    │
    │   with module.ap-sydney-1.oci_core_vcn.agent[0],
    │   on modules/agent/agent-vcn.tf line 2, in resource "oci_core_vcn" "agent":
    │    2: resource "oci_core_vcn" "agent" {
    │
    ╵
    ╷
    │ Error: 404-NotAuthorizedOrNotFound, Authorization failed or requested resource not found.
    │ Suggestion: Either the resource has been deleted or service Core Vcn need policy to access this resource. Policy reference: https://docs.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm
    │ Documentation: https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn
    │ API Reference: https://docs.oracle.com/iaas/api/#/en/iaas/20160918/Vcn/CreateVcn
    │ Request Target: POST https://iaas.ap-melbourne-1.oraclecloud.com/20160918/vcns
    │ Provider version: 8.18.0, released on 2026-06-10.
    │ Service: Core Vcn
    │ Operation Name: CreateVcn
    │ OPC request ID: 4284c03923631b2491afe43e1bcfea5a/294D729CE589F1C38397296A4D454CDA/B1D83E888FB42DFCD833221C9652C853
    │
    │
    │   with module.ap-melbourne-1.oci_core_vcn.agent[0],
    │   on modules/agent/agent-vcn.tf line 2, in resource "oci_core_vcn" "agent":
    │    2: resource "oci_core_vcn" "agent" {
    │
    ╵
    ```
    </details>

 6. Some resources might generate a configuration drift which disappear after several consequent Terraform apply run.

 7. Instances might fail to start due to a insuficient capacity.
