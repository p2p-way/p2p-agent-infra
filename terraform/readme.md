# Peer-to-peer agent Terraform

 1. [Description](#description)
 2. [Cloud Providers](#cloud-providers)
 3. [Considerations](#considerations)
 4. [Configuration](#configuration)
 5. [Deployment scenarios](#deployment-scenarios)
 6. [Before deployment](#before-deployment)
 7. [Run control centers](#run-control-centers)
 8. [Run agents](#run-agents)


## [Description](#peer-to-peer-agent-terraform)

 This folder contains [Terraform](https://www.terraform.io) code to deploy instances for P2P agent.


## [Cloud Providers](#peer-to-peer-agent-terraform)

 To cover entire planet, we can run agents on every continent based on Cloud Providers Regions and Availability Zones.

 **Criterias:** `Services availability --> Area/`[`Connections`](https://en.wikipedia.org/wiki/Submarine_communications_cable)` --> Costs`

| # | Cloud                                  | Services                                            | Public regions                         | Availability Zones | Costs, $/d/i                           |
| - | -------------------------------------- | --------------------------------------------------- | -------------------------------------- | ------------------ | -------------------------------------- |
| 1 | [Alibaba Cloud](alibaba/readme.md)     | [used services](alibaba/readme.md#description)      | [`28`](alibaba/readme.md#regions)      | `1/2/3/6/8/11/12`  | [`1.08`](alibaba/readme.md#costs)      |
| 2 | [Amazon Web Services](aws/readme.md)   | [used services](aws/readme.md#description)          | [`33`](aws/readme.md#regions)          | `2/3/4/6`          | [`0.97`](aws/readme.md#costs)          |
| 3 | [Microsoft Azure](azure/readme.md)     | [used services](azure/readme.md#description)        | [`47`](azure/readme.md#regions)        | `1/3`              | [`1.11`](azure/readme.md#costs)        |
| 4 | [Google Cloud Platform](gcp/readme.md) | [used services](gcp/readme.md#description)          | [`42`](gcp/readme.md#regions)          | `3/4`              | [`0.85`](gcp/readme.md#costs)          |
| 5 | [Akamai Cloud](akamai/readme.md)       | [used services](akamai/readme.md#description)       | [`31`](akamai/readme.md#regions)       | `1`                | [`0.25`](akamai/readme.md#costs)       |
| 6 | [DigitalOcean](digitalocean/readme.md) | [used services](digitalocean/readme.md#description) | [`13`](digitalocean/readme.md#regions) | `1`                | [`0.21`](digitalocean/readme.md#costs) |
| 7 | [Hetzner Cloud](hetzner/readme.md)     | [used services](hetzner/readme.md#description)      | [`6`](hetzner/readme.md#regions)       | `1`                | [`0.29`](hetzner/readme.md#costs)      |


## [Considerations](#peer-to-peer-agent-terraform)

 1. We use `x86_64` instead of `arm64` instances architecture, by default, because not all the software may be accessible on `arm64` and not all Cloud Providers may have such instances support in general or across all the regions.
 2. We generate SSH key pairs, by default, for the instances, but we can pass a custom public key or disable it (excluding Azure) and then access the nodes using
    - Alibaba - [Connect to an instance through Workbench](https://www.alibabacloud.com/help/en/ecs/user-guide/workbench-overview)
    - AWS - [EC2 Instance Connect](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-methods.html)
    - GCP - [Connect to Linux VMs](https://cloud.google.com/compute/docs/connect/standard-ssh)
    - Akamai - [Access your system console using Lish](https://techdocs.akamai.com/cloud-computing/docs/access-your-system-console-using-lish)
 3. We don't create SSH access rule, by default, for the instances as they are managed by the code in the Git repository and in case of need we may add rule manually.
 4. We generate and pass SSH private key by default to the instances, which can be used to access private repository, because it is not so easy to do it when instance was already run.
 5. We use Ubuntu OS because it is cloud agnostic and provides great software support.
 6. For Cloud Providers, which support logging and monitoring, both options are disabled by default to minimize the costs and decrease instances load.
 6. For Cloud Providers, which support [Agent side watcher](../architecture.md#agent-side-watcher), that option is enabled by default to have a way to manage instances count.


## [Configuration](#peer-to-peer-agent-terraform)

 We can [Run agents](#run-agents) on [Cloud Providers](#cloud-providers) using Terraform and common settings are following
  - We should **pay attention to the instance type**. While defaults for AWS and Azure works well, GCP is ~ 6 times slower and Alibaba cheapest instances are unusable.

    <details><summary><b>Ansible roles execution duration</b></summary>

    | Cloud        | First run      | Second run       | Instance           | Resources       |
    | ------------ | -------------- | ---------------- | ------------------ | --------------- |
    | Alibaba      | `~ 3 minutes`  | `~ 40 seconds`   | `ecs.e-c1m1.large` | `2 vCPU / 2 GB` |
    | AWS          | `~ 3 minutes`  | `~ 30 seconds`   | `t3.micro`         | `2 vCPU / 1 GB` |
    | Azure        | `~ 3 minutes`  | `~ 30 seconds`   | `Standard_B1s`     | `1 vCPU / 1 GB` |
    | GCP          | `~ 17 minutes` | `~ 6, 3 minutes` | `e2-micro`         | `2 vCPU / 1 GB` |
    | Akamai       | `~ 3 minutes`  | `~ 25 seconds`   | `g6-nanode-1`      | `1 vCPU / 1 GB` |
    | Hetzner      | `~ 2 minutes`  | `~ 20 seconds`   | `cpx11`            | `2 vCPU / 2 GB` |
    | DigitalOcean | `~ 3 minutes`  | `~ 50 seconds`   | `s-1vcpu-1gb`      | `1 vCPU / 1 GB` |
    </details>

  - Variable `agent_name` sets the name of the created resources, in the default configuration with the value `P2P agent`, all resource will be prefixed with the `p2p-agent-<region>`.
  - Variable `agent_watcher` enable [Agent side watcher](../architecture.md#agent-side-watcher), which imply IAM resources creation.
  - Variable `agent_logs` enable logs in the cloud (Alibaba/AWS/GCP only).
  - Variable `agent_metrics` enable metrics in the cloud (Alibaba/AWS/GCP only).
  - Variable `agent_custom_ports` can be used to open a wide range of TCP/UDP ports like following `["1024-65535", "1024-65535"]`
  - Variable `allow_ssh` specify hosts/subnets for SSH access to the instances.
  - When `public_keys = []`, we generate the keys for instances SSH access, we also can pass own list of keys or skip it (excluding Azure), by set value to `[""]`.
  - Variable `os_name` should be set to `ubuntu`, which defaults to ubuntu 24.04.
  - Set `desired_capacity` with the desired number of the nodes per region. We also can set value per specific region by passing value directly to the specific region module configuration.
  - By default, `start_time = "now"` and it means that nodes will start right after `start_offset = "15 minutes"`, after Terraform apply run. We also can set a custom time in [RFC3339 format](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/offset#optional) - `YYYY-MM-DDTHH:MM:SSZ`, for example `2022-11-28T13:00:00Z`, and in that case `start_offset` will be ignored.

    Cloud Providers resources creation in all the regions, using Terraform, vary and we should consider that when set a custom `start_offset`.

    <details><summary><b>Terraform execution duration</b></summary>

    | Cloud        | `init`, s | `apply`, m | `destroy`, m | Regions | Watcher | Logs/Metrics | Comment |
    | ------------ | --------- | ---------- | ------------ | ------- | ------- | ------------ | ------- |
    | Alibaba      | `13.975`  | `4:00.81`  | `3:44.88`    | `22`    | `true`  | `false`      |         |
    | AWS          | `20.235`  | `3:24.92`  | `3:30.48`    | `34`    | `true`  | `false`      |         |
    | Azure        | `15.444`  | `7:08.80`  | `55:52.37`   | `42`    | `true`  | `false`      |         |
    | GCP          | `10.063`  | `11:31.22` | `14:05.22`   | `41`    | `true`  | `false`      |         |
    | Akamai       | `6.694`   | `4:20.57`  | `2:39.64`    | `27`    | `-`     | `-`          |         |
    | DigitalOcean | `6.196`   | `1:00.09`  | `1:30.80`    | `13`    | `-`     | `-`          | wait    |
    | Hetzner      | `4.552`   | `0:18.720` | `0:35.692`   | `6`     | `-`     | `-`          |         |

    > Thu Jul 24 08:00:00 UTC 2025
    </details>

  - Instances will continue to work for `run_duration = "7 days"` and after this time Autoscaler will delete them. For Cloud Providers where Autoscaler is not supported, we have to delete instances manually.
  - Variable `start_offset` and `run_duration` can be set in one of the following units - `minutes/hours/days/months`.
  - Variable `agent_cron_schedule` defines agen cron schedule on instance and can be specified in a short `*/15` or full form `*/15 * * * *`. It make sense to adjust it for small/slow instances. Because of the default `agent_commands_defaults["DEFAULT_FORCE_RUN"] = true`, ansible-pull will run the code, even if there were no changes in repository and that adds an additional load on the instance.
  - Variable `agent_commands` control which run functions of the agent are enabled.
  - Variable `agent_commands_defaults` define default values for agent commands.
  - Variable `agent_cc_hosts` define control center URLs, the first one who returns the the headers will be used.
  - Variable `agent_cc_commands` define commands whose values from control center will be used to override `agent_commands_defaults` configuration.
  - Variable `agent_cc_commands_prefix` define commands prefix returned by control center for agent configuration.
  - Variable `agent_repository_ssh_key` is used to configure access to private repository via SSH. We are generating by default a private key and pass it to the instance. In that way, we could switch node to use a private repository via SSH. For that it is requred to set appropriate value in `agent_commands_defaults["DEFAULT_REPOSITORY"]` and/or control center, like `git@github.com:<username>/<repository>` for GitHub.
  - Check [Considerations](#considerations) for additional details.


### [Use a private centralised repository](#peer-to-peer-agent-terraform)

#### Use auto generated key

 1. Update *variables.auto.tfvars*
    ```terraform
    agent_repository_ssh_key = null

    agent_commands_defaults = {
      DEFAULT_REPOSITORY      = "git@github.com:<username>/<repository>"
      DEFAULT_REPOSITORY_MODE = "client-server"
    }
    ```

 2. When control center is used, update `cc-a-repository` header - [Agent use control center](#agent-use-control-center).

 3. After deployment, add a public key from Terraform *repository_public_key* output on repository side
    - GitHub: Repository --> Settings --> Security --> Deploy keys


#### Use own key

 1. Generate SSH key pair
    ```shell
    ssh-keygen -t ed25519 -f id_ed25519 -N "" -C p2p-agent
    ```

 2. Encode private key
    ```shell
    base64 -w 0 -i id_ed25519
    ```

 3. Update *variables.auto.tfvars*
    ```terraform
    agent_repository_ssh_key = "<base64 output>"

    agent_commands_defaults = {
      DEFAULT_REPOSITORY      = "git@github.com:<username>/<repository>"
      DEFAULT_REPOSITORY_MODE = "client-server"
    }
    ```

 4. Add a public key *id_ed25519.pub* content on repository side
    - On GitHub: Repository --> Settings --> Security --> Deploy keys


## [Deployment scenarios](#peer-to-peer-agent-terraform)

 We can deploy agent using diferent scenarios, and later, its configuration can be updated using [Ansible Agent role](../ansible/readme.md#agent-role)
 - [Agent use hardcoded commands and Radicle repository](#agent-use-hardcoded-commands-and-radicle-repository)
 - [Agent use hardcoded commands and centralised repository](#agent-use-hardcoded-commands-and-centralised-repository)
 - [Agent use control center](#agent-use-control-center)
 - [Agent Autoscaling is enabled (via Agent side watcher)](#agent-autoscaling-is-enabled-via-agent-side-watcher)
   - [Handled by control center and code in repository](#handled-by-control-center-and-code-in-repository)
   - [Handled by code in repository](#handled-by-code-in-repository)
 - [Agent Autoscaling is disabled (via Agent side watcher)](#agent-autoscaling-is-disabled-via-agent-side-watcher)


### Agent use hardcoded commands and Radicle repository

 Agent will install Radicle, clone Radicle repository and use it's configuration and by thouse can be managed only by code in repository.

 - *variables.auto.tfvars*
   ```terraform
   agent_commands_defaults = {
     DEFAULT_REPOSITORY_MODE    = "radicle"
     DEFAULT_REPOSITORY_RADICLE = "rad:..."
   }
    ```


### Agent use hardcoded commands and centralised repository

 Agent will use only variables hardcoded in the script and by thouse can be managed only by code in repository. It is similar to [Agent use hardcoded commands and Radicle repository](#agent-use-hardcoded-commands-and-radicle-repository) but uses centralised Git services, like GitHub.

 - *variables.auto.tfvars*
   ```terraform
   agent_commands_defaults = {
     DEFAULT_REPOSITORY_MODE = "client-server"
   }

   agent_commands = {
     CC = false
   }

   agent_commands_defaults = {
     DEFAULT_REPOSITORY = "https://..."
   }
   ```

 - And optional [Use a private centralised repository](#use-a-private-centralised-repository)


### Agent use control center

 Agent will contact control center and will use returned data to get repository address, runner type and file to run. Also, we can manage, which values from control center should be taken into account to override default values in the script.

 - *variables.auto.tfvars*
   ```terraform
   agent_commands = {
     CC = true
   }

   agent_commands_defaults = {
     DEFAULT_REPOSITORY_MODE = "client-server"
   }

   agent_cc_hosts = ["cc-url-1", "..."]

   agent_cc_commands = "delay desired-capacity force-run main-run post-run pre-run repository type"
   ```

 - Add headers on control center side, specified in `agent_cc_commands` variable, with a prefix from the `agent_cc_commands_prefix` variable
   ```
   cc-a-delay: -
   cc-a-desired-capacity: {"all": "-", "aws": {"all": "-", "eu-central-1": "-"}}
   cc-a-force-run: -
   cc-a-main-run: ansible/playbook.yml
   cc-a-post-run: echo "Finish: $(date)"
   cc-a-pre-run: echo "Start: $(date)"
   cc-a-repository: https://github.com/p2p-way/p2p-agent-infra
   cc-a-type: ansible
   ```

 - And optional [Use a private centralised repository](#use-a-private-centralised-repository)


### Agent Autoscaling is enabled (via [Agent side watcher](../architecture.md#agent-side-watcher))

 - *variables.auto.tfvars*
   ```terraform
   agent_watcher=true
   ```


#### Handled by control center and code in repository

 Agent will use `desired_capacity` value from Ansible or `cc-a-desired-capacity` returned by control center to manage nodes count.

 - Add header `cc-a-desired-capacity` on control center side

 - Update `desired_capacity` variable in [*ansible/playbook.yml*](../ansible/playbook.yml)


#### Handled by code in repository

 Agent will use only `desired_capacity` value from Ansible to manage nodes count.

 Besides the variables in [Agent use control center](#agent-use-control-center), we should adjust the following

 - *variables.auto.tfvars*
   ```diff
   + agent_cc_commands = "delay                  force-run main-run post-run pre-run repository type"
   - agent_cc_commands = "delay desired-capacity force-run main-run post-run pre-run repository type"
   ```

 - Update `desired_capacity` variable in [*ansible/playbook.yml*](../ansible/playbook.yml)


### Agent Autoscaling is disabled (via [Agent side watcher](../architecture.md#agent-side-watcher))

 - *variables.auto.tfvars*
   ```terraform
   agent_watcher = false
   ```

 - And optional set variable `enable_watcher=false` in [*ansible/playbook.yml*](../ansible/playbook.yml)


## [Before deployment](#peer-to-peer-agent-terraform)

 1. Check control center settings
    ```shell
    curl -sI https://d2d0z7lax5amc3.cloudfront.net | grep cc- --color
    ```
    Or, consider to [Run control centers](#run-control-centers).

 2. Check [Cloud Providers](#cloud-providers) for new regions.

 3. Check [Ansible](../ansible/readme.md) roles for the latest software versions.

 4. Update variables in the [*ansible/readme.md*](../ansible/readme.md) and [*ansible/playbook.yml*](../ansible/playbook.yml) files
    ```yaml
     archivist_cid
     ipfs_cid
     radicle_rid
     ton_bagid
     torrent_magnet
     ```

 5. Push latest changes to Radicle or Git repository.


## [Run control centers](#peer-to-peer-agent-terraform)

 1. [Control center on AWS](aws/readme.md)
 2. [Control center on Cloudflare](cloudflare/readme.md)


## [Run agents](#peer-to-peer-agent-terraform)

 For more information about how to run P2P agents, please see the following guides
 1. [P2P agent on Alibaba](alibaba/readme.md)
 2. [P2P agent on AWS](aws/readme.md)
 3. [P2P agent on Azure](azure/readme.md)
 4. [P2P agent on GCP](gcp/readme.md)
 5. [P2P agent on Akamai](akamai/readme.md)
 6. [P2P agent on DigitalOcean](digitalocean/readme.md)
 7. [P2P agent on Hetzner](hetzner/readme.md)
 8. [P2P agent on generic installation](generic/readme.md)
