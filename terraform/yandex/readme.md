# P2P agent on Yandex

 1. [Description](#description)
 2. [Considerations](#considerations)
 3. [Limitations](#limitations)
 4. [Regions](#regions)
 5. [Costs](#costs)
 6. [Requirements](#requirements)
 7. [Deployment](#deployment)
 8. [Cleanup](#cleanup)
 9. [Known issues](#known-issues)


## [Description](#p2p-agent-on-yandex)

 This code provides [Terraform](../readme.md) configuration for [Yandex Cloud](https://yandex.cloud/) stack deployment for P2P content distribution.
 1. [Yandex Identity and Access Management](https://yandex.cloud/en/services/iam/) - Provides access for function and VM instances to update Instance group and function trigger.
 2. [Yandex Cloud Functions](https://yandex.cloud/en/services/functions) - Run a function which will act as watcher and orchestrate VM provisioning via Instance group.
 3. [Yandex Virtual Private Cloud](https://yandex.cloud/en/services/vpc/) - Provides a network for the VM.
 4. [Instance Groups](https://yandex.cloud/en/docs/compute/concepts/instance-groups/) - Scale and manage VM instances.
 5. [Yandex Compute Cloud](https://yandex.cloud/en/services/compute/) - VM provisioning.
 6. [Yandex Cloud Logging](https://yandex.cloud/en/services/logging/) - Logs.
 7. [Yandex Monium Metrics](https://yandex.cloud/en/services/monitoring/) - Metrics.


 Generally, this configuration will do the following

**Watcher and scheduler**
 1. Create IAM Service Account and assign roles.
 2. Create a function.
 3. Create a trigger which will invoke function.

**Agent**
 1. Create VPC for VM instances.
 2. Create IAM Service Account and assign roles.
 3. Create Instance group with a template for the VM instances.
 4. Create Log group.


## [Considerations](#p2p-agent-on-yandex)

**Agent**
 1. Check [Agent consideration](../readme.md#agent-considerations).


## [Limitations](#p2p-agent-on-yandex)

 1. Yandex does not provide Autoscaling by time and [Watcher](../../architecture.md#watcher) is not implemeneted yet and instances will be started right during applying Terraform configuration.
 2. There is no way to deploy resources simultaneously in multiple regions, please check [Known issues](#known-issues) for more details.
 3. [Remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/remote) for Terraform is not implemented yet and state will be stored locally.


## [Regions](#p2p-agent-on-yandex)

 - [Regions](https://yandex.cloud/en/docs/overview/concepts/region)
 - [Availability zones](https://yandex.cloud/en/docs/overview/concepts/geo-scope)
   ```shell
   # Show availability zones
   yc compute zone list
   ```


## [Costs](#p2p-agent-on-yandex)

 - [Price calculator](https://yandex.cloud/en/prices)
 - [Yandex Cloud pricing policy](https://yandex.cloud/en/docs/billing/pricing)

 | Resource                                                                                                                               | Price                 | Costs                  | Comment                      |
 | -------------------------------------------------------------------------------------------------------------------------------------- | --------------------- | ---------------------- | ---------------------------- |
 | [Compute - Regular VM computing resources, CPU](https://yandex.cloud/en/price-list?installationCode=kz&services=dt02pas77ftg9h3f2djj)  | `0.0055999982 $/h`    | `8.287997336 $/m`      | Intel Ice Lake, 20% 2 x vCPU |
 | [Compute - Regular VM computing resources, RAM](https://yandex.cloud/en/price-list?installationCode=kz&services=dt02pas77ftg9h3f2djj)  | `0.0035999989 $/h`    | `2.663999186 $/m`      | Intel Ice Lake               |
 | [Compute - Fast network drive (SSD)](https://yandex.cloud/en/price-list?installationCode=kz&services=dt02pas77ftg9h3f2djj)             | `0.0002117777 $/GB/h` | `0.156715498 $/10GB/m` | 10 GB                        |
 | [VPC - Public IP address](https://yandex.cloud/en/price-list?installationCode=kz&services=dt01qssbrdtcaus362kp)                        | `0.003119999 $/h`     | `2.30879926 $/m`       |                              |
 | [VPC - Outgoing traffic, from 100 billing units](https://yandex.cloud/en/price-list?installationCode=kz&services=dt01qssbrdtcaus362kp) | `0.0195999938 $/GB/m` | `1.95999938 $/100GB`   | Free first 100 GB / Month    |
 | TOTAL                                                                                                                                  |                       | `15.37 $/m`            |                              |

```shell
15.37 $/m/i / 31 d = 0.50 $/d/i # 1 day / 1 instance / 1 region
```

 > [!NOTE]
 > Provided costs are very approximate because we use a highest instance price across all the regions. Also, free tier may not cover multiple instances running for a long period of time.


## [Requirements](#p2p-agent-on-yandex)

 In order to proceed with this deployment, we need
 1. Linux host with [Terraform](https://developer.hashicorp.com/terraform/install) and [Yandex Cloud CLI](https://yandex.cloud/en/docs/cli/quickstart) installed.
 2. [Yandex Cloud service account](https://yandex.cloud/en/docs/terraform/quickstart#get-credentials) with the following roles attached
      - `vpc:admin`
      - `iam:admin`
      - `logging:admin`
      - `functions.admin`
      - `resource-manager.admin`
      - `compute:editor`


## [Deployment](#p2p-agent-on-yandex)

 1. Get Terraform code from GitHub repository
    ```shell
    git clone https://github.com/p2p-way/p2p-agent-infra

    cd p2p-agent-infra/terraform/yandex
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
    For more information, please see [Configuration](../readme.md#configuration).

 4. Authenticate on [Yandex](https://yandex.cloud/en/docs/terraform/quickstart#get-credentials)
    ```shell
    # Variables
    yc_profile="ru-central1"
    service_account="terraform-${yc_profile}"
    service_account_id=$(yc iam service-accounts list --jq '.[] | select(.name=='\"$service_account\"') | .id')

    # Authenticate
    export YC_TOKEN=$(yc iam create-token --impersonate-service-account-id "${service_account_id}" --profile "${yc_profile}")
    export YC_CLOUD_ID=$(yc config get cloud-id --profile "${yc_profile}")
    export YC_FOLDER_ID=$(yc config get folder-id --profile "${yc_profile}")
    export TF_VAR_folder_id="${YC_FOLDER_ID}"
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


### [Update configuration](#p2p-agent-on-yandex)

 After we deployed initial configuration, it may be required to update nodes capacity or add more regions.

 Update is very transparent and we need just to set `desired_capacity` with the required number and run Terraform.


#### [Update capacity](#p2p-agent-on-yandex)

 1. Set `desired_capacity` in the *variables.auto.tfvars* globaly, or set it per region in the module configuration.
 2. Run `terraform plan`.
 3. Run `terraform apply`.


#### [Add new region](#p2p-agent-on-yandex)

 1. Add a configuration file for the new region.
 2. Run `terraform init`.
 3. Run `terraform plan`.
 4. Run `terraform apply`.


## [Cleanup](#p2p-agent-on-yandex)

 In order to cleanup all created resources we should use the following steps
 1. Cleanup resources created by Terraform
    ```shell
    terraform destroy
    ```

 2. Cleanup created zip archives when `start_time = "watcher"`
    ```shell
    rm -f *.zip
    ```


## [Known issues](#p2p-agent-on-yandex)

 1. [Folder deletion](https://yandex.cloud/en/docs/resource-manager/operations/folder/delete) might take very long and this is why we use a manual creation/deletion or rely on a default one.

 2. Based on the experiments and Yandex Cloud support response, it is not easy/possible to create resources in multiple regions simultaneously. In case we want to deploy in multiple regions, they needs to be handled using separate folders. Probably a [Controlled organizations](https://yandex.cloud/en/docs/organization/concepts/controlled-org) could be a solution, but they are in preview and needs to be tested.

    Due to this, `1-region-kz1.tf` was not tested.

    At the moment of testing, the blocking part is the following
    - Each regions have it's own organizations/clouds/folders/users
    - We can't pass simultaneously multiple `zone`, `token`, `cloud_id`, `fodler_id`, `endpoint` unless hardcode them in provider block or bunch of variables
    - Provider ignores `token` and `shared_credentials_file` values
      <details><summary>details</summary>

      ```terraform
      provider "yandex" {
        alias            = "kz1"
        zone             = "kz1-a"
        token            = "t1...."
        endpoint         = "api.yandexcloud.kz:443"
      }
      ```

      > Planning failed. Terraform encountered an error while generating this plan.
      >
      > Error: Invalid provider configuration
      >
      > Provider "registry.terraform.io/yandex-cloud/yandex" requires explicit configuration. Add a provider block to the root module and configure the provider's required arguments as described in the provider
      > documentation.
      >
      >
      >
      > Error: Failed to configure
      >
      >   with provider["registry.terraform.io/yandex-cloud/yandex"],
      >   on <empty> line 0:
      >   (source code not available)
      >
      > one of 'token' or 'service_account_key_file' should be specified; if you are inside compute instance, you can attach service account to it in order to authenticate via instance service account
      </details>

 3. When we have multiple scaling activities, we might get an erron on a VM creation
    > `[RESOURCE_EXHAUSTED] Quota vpc.externalAddressesCreation.rate exceeded`

    That quota is not listed in a [Yandex Cloud Quota Manager](https://yandex.cloud/en/services/quota-manager) and support request might be declined with pleasure
    ```shell
    yc quota-manager \
      quota-limit list \
      --service=vpc \
      --resource-type=resource-manager.cloud \
      --resource-id=$(yc config get cloud-id)
    ```
