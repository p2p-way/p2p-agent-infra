# P2P agent on DigitalOcean

 1. [Description](#description)
 2. [Considerations](#considerations)
 3. [Limitations](#limitations)
 4. [Regions](#regions)
 5. [Costs](#costs)
 6. [Requirements](#requirements)
 7. [Deployment](#deployment)
 8. [Cleanup](#cleanup)
 9. [Known issues](#known-issues)


## [Description](#p2p-agents-on-digitalocean)

 This code provides [Terraform](../readme.md) configuration for [DigitalOcean](https://www.digitalocean.com) stack deployment for P2P content distribution.
 1. [DigitalOcean VPC](https://docs.digitalocean.com/products/networking/vpc/) - Provides a network for the VM.
 2. [DigitalOcean Droplets](https://www.digitalocean.com/products/droplets) - VM provisioning.

 Generally, this configuration will do the following

**Agent**
 1. Create a VPC for Droplets.
 2. Create and launch Droplets.


## [Considerations](#p2p-agents-on-digitalocean)

 1. Check [Considerations](../readme.md#considerations).


## [Limitations](#p2p-agents-on-digitalocean)

 1. DigitalOcean does not provide Autoscaling or other services to implement a [Watcher](../../architecture.md#watcher) or [Agent side watcher](../../architecture.md#agent-side-watcher) and instances will be started right during applying Terraform configuration.
 2. [Remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/remote) for Terraform is not implemented yet and state will be stored locally.


## [Regions](#p2p-agents-on-digitalocean)

 - [Regional Availability](https://docs.digitalocean.com/platform/regional-availability/)
 - [Droplet Availability](https://docs.digitalocean.com/products/droplets/details/availability/)
 - [Droplet Features](https://docs.digitalocean.com/products/droplets/details/features/)
 - [Choosing the Right CPU Droplet Plan](https://docs.digitalocean.com/products/droplets/concepts/choosing-a-plan/)
 - [doctl compute](https://docs.digitalocean.com/reference/doctl/reference/compute/)

   ```shell
   # Retrieves a list of datacenter regions
   doctl compute region list

   # List available Droplet sizes
   doctl compute size list

   # List available distribution images
   doctl compute image list-distribution
   ```


## [Costs](#p2p-agents-on-digitalocean)

 [DigitalOcean - Pricing Calculator](https://www.digitalocean.com/pricing/calculator)

 | Resource                                                  | Price         | Costs      | Comment     |
 | --------------------------------------------------------- | ------------- | ---------- | ----------- |
 | [Droplets](https://www.digitalocean.com/pricing/droplets) | `0.00893 $/h` | `6.64 $/m` | s-1vcpu-1gb |
 | TOTAL                                                     |               | `6.64 $/m` |             |

```
6.64 $/m/i / 31 d = 0.21 $/d/i   # 1 day / 1 instance / 1 region
0.21 $/d/i x 13 r = 2.73 $/d/i/r # 1 day / 1 instance / all regions
```

 Run **1 instance** in **all public regions**, during **1 day**, may cost ~ **2.73 $**

 > [!NOTE]
 > Provided costs are very approximate because we use a highest instance price across all the regions.


## [Requirements](#p2p-agents-on-digitalocean)

 In order to proceed with this deployment, we need
 1. Linux host with [Terraform](https://developer.hashicorp.com/terraform/install) installed.
 2. DigitalOcean [PAT](https://docs.digitalocean.com/reference/api/create-personal-access-token/) with the following custom scopes
     - `actions` - read
     - `droplet` - create, read, update, delete
     - `firewall` - create, read, update, delete
     - `image` - read
     - `kubernetes` - read
     - `load_balancer` - read
     - `regions` - read
     - `sizes` - read
     - `ssh_key` - create, read, update, delete
     - `tag` - create, read, delete
     - `vpc` - create, read, update, delete


## [Deployment](#p2p-agents-on-digitalocean)

 1. Get Terraform code from GitHub repository
    ```shell
    git clone https://github.com/p2p-way/p2p-agent-infra

    cd p2p-agent-infra/terraform/digitalocean
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

 4. Authenticate on DigitalOcean
    ```shell
    export DIGITALOCEAN_TOKEN="<api token>"
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


### [Update configuration](#p2p-agents-on-digitalocean)

 After we deployed initial configuration, it maybe required to update nodes capacity or add more regions.

 Update is very transparent and we need just to set `desired_capacity` with the required number and run Terraform.


#### [Update capacity](#p2p-agents-on-digitalocean)

 1. Set `desired_capacity` in the *variables.auto.tfvars* globaly, or set it per region in the module configuration.
 2. Run `terraform plan`.
 3. Run `terraform apply`.


#### [Add new region](#p2p-agents-on-digitalocean)

 1. Add a configuration file for the new region.
 2. Run `terraform init`.
 3. Run `terraform plan`.
 4. Run `terraform apply`.


## [Cleanup](#p2p-agents-on-digitalocean)

 In order to cleanup all created resources we should use the following steps
 1. Cleanup resources created by Terraform
    ```shell
    terraform destroy
    ```


## [Known issues](#p2p-agents-on-digitalocean)

 1. [DigitalOcean Droplet Availability](https://docs.digitalocean.com/products/droplets/details/availability/) might vary by regions and it might be required to adjust droplet size to every region.

 2. Default droplet limit is low and it might be required to send a [Request Increase from Team Settings](https://cloud.digitalocean.com/account/team) to request a limit increase.

 3. When a first VPC is created in a region, it becomes a default one and a default VPC can't be deleted - [Unable to destroy the VPC provisioned with terraform #472](https://github.com/digitalocean/terraform-provider-digitalocean/issues/472).

    We could consider the following workarounds
      - Add manually a default VPC to all the regions, before running a Terraform
      - Create all resources and after failed VPC destroy, list remained resource and remove just failed VPC's
        ```shell
        terraform state list
        terraform state rm 'module.syd1.digitalocean_vpc.agent[0]'
        terraform destroy
        ```
     Login into DigitalOcean account and rename the VPC to something like `syd1-default-vpc`.

 4. Sometimes, we may get and intermitent error and re-run solve the issue
    > Error: Error creating VPC: POST https://api.digitalocean.com/v2/vpcs: 422 (request "e488edda-0bca-424c-9283-f1f543510e7d") This range/size overlaps with another VPC network in your account: p2p-agent-sfo3 10.124.16.0/20.

 5. Resources destroy might fail with the following error
    > Error: Error deleting VPC: DELETE https://api.digitalocean.com/v2/vpcs/59bc7f31-2952-450c-9348-5670ac327af9: 409 (request "ecb33ca2-7b0c-43a5-83f8-ecf2712fcc5b") Can not delete VPC with members

    And we applying a workaround using [time_sleep](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) resource.
