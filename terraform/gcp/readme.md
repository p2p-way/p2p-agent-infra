# P2P agent on GCP

 1. [Description](#description)
 2. [Considerations](#considerations)
 3. [Limitations](#limitations)
 4. [Regions](#regions)
 5. [Costs](#costs)
 6. [Requirements](#requirements)
 7. [Deployment](#deployment)
 8. [Cleanup](#cleanup)
 9. [Known issues](#known-issues)


## [Description](#p2p-agents-on-gcp)

 This code provides [Terraform](../readme.md) configuration for [Google Cloud Platform](https://cloud.google.com/) stack deployment for P2P content distribution.
 1. [Cloud Functions](https://cloud.google.com/functions) - Run a function which will act as watcher and orchestrate VM provisioning via Autoscaler.
 2. [Cloud Scheduler](https://cloud.google.com/scheduler) - Provides a scheduler to invoke the function.
 3. [Cloud VPC](https://cloud.google.com/vpc) - Provides a network for the VM instances.
 4. [Cloud Instance groups](https://cloud.google.com/compute/docs/instance-groups/) - Manage VM instances.
 5. [Cloud Autoscaling groups](https://cloud.google.com/compute/docs/autoscaler/) - Scale and manage VM instances.
 6. [Cloud Compute Engine](https://cloud.google.com/compute/) - VM provisioning.
 7. [Cloud Logging](https://cloud.google.com/logging/) - Logs.
 8. [Cloud Monitoring](https://cloud.google.com/monitoring/) - Metrics.


 Generally, this configuration will do the following

**Watcher and scheduler**
 > [!NOTE]
 > Watcher and scheduler is not implemented yet
 1. Create a function.
 2. Create a scheduler.

**Agent**
 1. Create a VPC for VM instances.
 2. Create an Instance template for the instances.
 3. Create an Instance group using Instance template.
 4. Create an Autoscaling group using Instance group


## [Considerations](#p2p-agents-on-gcp)

 1. Check [Considerations](../readme.md#considerations).
 2. We use auto mode VPC network for easier management.


## [Limitations](#p2p-agents-on-gcp)

 1. Watcher is not implemented yet and we should set variable [`start_time`](../readme.md#agent) only as `now` or specify a custom time.
 2. [Remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/remote) for Terraform is not implemented yet and state will be stored locally.


## [Regions](#p2p-agents-on-gcp)

 - [Global Locations - Regions & Zones](https://cloud.google.com/about/locations)
 - [Geography and regions](https://cloud.google.com/docs/geography-and-regions)
 - [List regions](https://cloud.google.com/sdk/gcloud/reference/compute/regions/list)
 - [Read virtual machine types](https://cloud.google.com/sdk/gcloud/reference/compute/machine-types)

   ```shell
   # List Google Compute Engine regions
   gcloud compute regions list

   # List Google Compute Engine zones
   gcloud compute zones list --sort-by REGION,NAME

   # List Google Compute Engine machine types in a zone
   gcloud compute machine-types list \
     --filter="zone:( europe-west3-a )" \
     --format="table(NAME,CPUS,MEMORY_GB,DEPRECATED,ZONE)" \
     --sort-by=NAME,CPUS

   # List Google Compute Engine machine types in a region
   gcloud compute machine-types list --filter="zone~europe-west3"

   # List Google Compute Engine small machine types in a zone
   gcloud compute machine-types list --filter="zone=europe-west3-a AND CPUS=(1 2)" --sort-by=NAME

   # Describe a Compute Engine machine type
   gcloud compute machine-types describe --zone=europe-west3-a e2-micro
   ```


## [Costs](#p2p-agents-on-gcp)

 [Google Cloud Pricing Calculator](https://cloud.google.com/products/calculator/)

 | Resource                                                              | Price          | Costs          | Comment                                             |
 | --------------------------------------------------------------------- | -------------- | -------------- | --------------------------------------------------- |
 | [VM Instance](https://cloud.google.com/compute/vm-instance-pricing)   | `0.013296 $/h` | `9.89 $/m`     | e2-micro / Osasco, São Paulo, Brazil, South America |
 | [Disk](https://cloud.google.com/compute/disks-image-pricing#disk)     | `0.15 $/GB/m`  | `1.5 $/10GB/m` |                                                     |
 | [Virtual Private Cloud](https://cloud.google.com/vpc/network-pricing) | `0.15 $/GB`    | `15 $/100GB`   |                                                     |
 | [Metrics](https://cloud.google.com/monitoring/#pricing)               | `-`            | `-`            | Free allotment                                      |
 | [Logs](https://cloud.google.com/logging/#pricing)                     | `-`            | `-`            | Free allotment                                      |
 | TOTAL                                                                 |                | `26.39 $/m`    |                                                     |

```
26.39 $/m/i / 31 d =  0.85 $/d/i   # 1 day / 1 instance / 1 region
 0.85 $/d/i x 42 r = 35.70 $/d/i/r # 1 day / 1 instance / all regions
```

 Run **1 instance** in **all public regions**, during **1 day**, may cost ~ **35.70 $**

 > [!NOTE]
 > Provided costs are very approximate because we use a highest instance price and traffic across all the regions. Also, free allotment may not cover multiple instances running for a long period of time.


## [Requirements](#p2p-agents-on-gcp)

 In order to proceed with this deployment, we need
 1. Linux host with [Terraform](https://developer.hashicorp.com/terraform/install) and [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) installed.
 2. GCP user account with the administrative permissions.


## [Deployment](#p2p-agents-on-gcp)

 1. Get Terraform code from GitHub repository
    ```shell
    git clone https://github.com/p2p-way/p2p-agent-infra

    cd p2p-agent-infra/terraform/gcp
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

 4. Authenticate on GCP
    ```shell
    # Authenticate
    gcloud auth application-default login

    # Set project id
    export GCLOUD_PROJECT="<poject id>"
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


### [Update configuration](#p2p-agents-on-gcp)

 After we deployed initial configuration, it maybe required to update nodes capacity or add more regions. And next steps mainly depends on the start time we set.

 **Nodes not started yet**

 Update is very transparent and we need just to set `desired_capacity` with the required number and run Terraform.

 > [!NOTE]
 > Please note, that computed start/stop time value will not be changed and in case we need that, we should increase `time_offset_version`.

 **Nodes already started**

 When nodes already started, following things are happened
 - Capacity of the Instance groups was changed by the Autoscaler, from 0 to the value we set at the apply, and Terraform will try to set it back to 0 and it will lead to the termination of the running instances and new instances will be run by the new Autoscaler start and it will lead to the down-time.
 - We should also note that `"Resizing of autoscaled regional managed instance groups is not allowed."`.

 To overcome this, we should set `initial_deploy = false` and `autoscaling_policy_mode = "OFF"` and Terraform will change it's behavior in the following way
 - Capacity for Autoscaler, which is initially set to 0, will use value from `desired_capacity`.
 - We will be able to update instance group settings.

 Update variables in the *variables.auto.tfvars* file
 ```shell
 vi variables.auto.tfvars
 ```
 ```
 initial_deploy          = false
 autoscaling_policy_mode = "OFF"
 ```


#### [Update capacity](#p2p-agents-on-gcp)

 1. Set `initial_deploy = false` and `autoscaling_policy_mode = "OFF"` in the *variables.auto.tfvars*.
 2. Set `desired_capacity` in the *variables.auto.tfvars* globaly, or set it per region in the module configuration.
 3. Run `terraform plan`.
 4. Run `terraform apply`.
 5. Set `autoscaling_policy_mode = "ON"` in the *variables.auto.tfvars*.
 6. Run `terraform plan`.
 7. Run `terraform apply`.


#### [Add new region](#p2p-agents-on-gcp)

 1. Set `initial_deploy = false` in the *variables.auto.tfvars*.
 2. Add a configuration file for the new region.
 3. Set `initial_deploy = true` in the module configuration, for this new region only.
 4. Run `terraform init`.
 5. Run `terraform plan`.
 6. Run `terraform apply`.
 7. Set back `initial_deploy = var.initial_deploy` in the module configuration, for this new region, and it will imply usage of the globaly defined value in the *variables.auto.tfvars*.
 8. Run `terraform plan`.
 9. Run `terraform apply`.


## [Cleanup](#p2p-agents-on-gcp)

 In order to cleanup all created resources we should use the following steps
 1. Cleanup resources created by Terraform
    ```shell
    terraform destroy
    ```


## [Known issues](#p2p-agents-on-gcp)

 1. [Arm VMs on Compute](https://cloud.google.com/compute/docs/instances/arm-on-compute) is limited only to the [Tau T2A machine series](https://cloud.google.com/compute/docs/general-purpose-machines#t2a_machines) which is available only in select [regions and zones](https://cloud.google.com/compute/docs/regions-zones#available).

 2. When we depoy regional network `global_network["create": false]` and health check - `global_health_check["create": false]` in all the regions, it will be required to [increase default service quota](https://cloud.google.com/docs/quotas/view-manage) for Compute Engine API Networks/Firewall rules and a whole deployment will take much longer.

 3. When we set `agent_logs` and `agent_metrics` to `true`, it imply additional IAM resources creation which might fill the [limits](https://cloud.google.com/iam/quotas#limits), especialy because [roles are not deleted immediately](https://cloud.google.com/iam/docs/creating-custom-roles#deleting-custom-role).

 4. In some regions instances were not tested due to the errors or limits.
    <details>
    <summary>More details</summary>

    **Resources canot be created**
    ```shell
    ╷
    │ Error: Error creating RegionHealthCheck: googleapi: Error 403: Permission denied on 'locations/me-central2' (or it may not exist).
    │ Details:
    │ [
    │   {
    │     "@type": "type.googleapis.com/google.rpc.ErrorInfo",
    │     "domain": "googleapis.com",
    │     "metadata": {
    │       "consumer": "projects/<project-id>",
    │       "location": "me-central2",
    │       "service": ""
    │     },
    │     "reason": "LOCATION_POLICY_VIOLATED"
    │   },
    │   {
    │     "@type": "type.googleapis.com/google.rpc.LocalizedMessage",
    │     "locale": "en-US",
    │     "message": "Permission denied on 'locations/me-central2' (or it may not exist)."
    │   },
    │   {
    │     "@type": "type.googleapis.com/google.rpc.Help",
    │     "links": [
    │       {
    │         "description": "Access to the region is unavailable. Please contact our sales team at https://cloud.google.com/contact for further assistance."
    │       }
    │     ]
    │   }
    │ ]
    │ , forbidden
    │
    │   with module.me-central2.google_compute_region_health_check.agent[0],
    │   on modules/agent/agent-health-check.tf line 2, in resource "google_compute_region_health_check" "agent":
    │    2: resource "google_compute_region_health_check" "agent" {
    │
    ╵
    ```
    - `1-region-me-central2.tf` - [Dammam region access](https://cloud.google.com/docs/dammam-region-access)
    </details>
