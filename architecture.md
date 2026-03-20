# Architecture

 1. [Description](#description)
 2. [Architecture](#architecture)
 3. [Scheduler](#scheduler)
 4. [Watcher](#watcher)
 5. [Control center](#control-center)
 6. [Autoscaler](#autoscaler)
 7. [Agent](#agent)
 8. [Agent side watcher](#agent-side-watcher)


## [Description](#architecture)

 We may consider to use major [Cloud Providers](https://en.wikipedia.org/wiki/Cloud-computing_comparison) like [Alibaba](https://alibabacloud.com), [AWS](https://aws.amazon.com), [Azure](https://azure.microsoft.com) and [GCP](https://cloud.google.com), to run and configure P2P helper nodes in an automatic way.

 Other providers, like [Akamai](https://www.linode.com), [DigitalOcean](https://www.digitalocean.com) or [Hetzner](https://www.hetzner.com) can be considered as well, even if they does not support [Function as a service](https://en.wikipedia.org/wiki/Function_as_a_service), [Autoscaling](https://en.wikipedia.org/wiki/Autoscaling) and [IAM](https://en.wikipedia.org/wiki/Identity_and_access_management), to implement a [Watcher](#watcher) or [Agent side watcher](#agent-side-watcher).

 The idea is to be able to run multiple [Agent](#agent) instances in an easy way and have a simple mechanism to scale them up and down from a single [Control center](#control-center) and to have a more resilient environment, we could use multiple control centers or use agent side watcher which will be managed via P2P network.


## [Architecture](#architecture)

```
                        ---- Autoscaler ----       ---------------         IPFS
                      /                      \   /                 \     /
Scheduler --- Watcher --- Control center     Agent     Setup ------- P2P - TON
                                       \        \      /   \       /     \
                                         ----- Scheduler   Repository      Torrent
```

 General workflow might be the following
 1. [Scheduler](#scheduler) run a [Watcher](#watcher).
 2. Watcher contact [Control center](#control-center) and check the variables returned over HTTP with the following prefixes
    - `cc-w-a` - Agent settings
    - `cc-w-s` - Scheduler settings
 3. If variable `cc-w-a-start` contains the current or past time, watcher will
      - add a `watcher-start` scheduler to the autoscaler with the date from variable value
      - with the offset based on the `cc-w-a-start-offset` variable
      - with the count based on `cc-w-a-desired-capacity` variable

 4. If variable `cc-w-a-stop` contains the future time, watcher will add a `watcher-stop` scheduler to the autoscaler based on the variable value and with the count 0.
 5. If variables `cc-w-a-start` and `cc-w-a-stop` are not defined or supported, watcher will update autoscaler directly using the value from `cc-w-a-desired-capacity`.
 6. When agent was activated, watcher might change scheduler based on the `cc-w-s-expression` variable value.
 7. [Autoscaler](#autoscaler) will run instances based on the created `watcher-start` scheduler.
 8. Scheduler on VM will run [Agent](#agent) and it will contact control center for the variables returned over HTTP with the `cc-a` prefix.
 9. Also, agent can be configured with some defaults to be able to work without relying on a control center.
 10. Agent will get configuration for execution from Git repository specified in the `cc-a-repository` variable.
 11. Agent will execute code specified in the `cc-a-main-run` variable based on the executor type from `cc-a-type` variable.
 12. Also, agent can run commands specified in the `cc-a-pre-run` and `cc-a-post-run` variables.
 13. We also might consider to implement [Agent side watcher](#agent-side-watcher), which is run on VM, only after it was started and it will use values from `cc-a` variables to manage autoscaler.

 > [!NOTE]
 > We also, might consider to use P2P protocols instead of the centralised platforms control centers.


## [Scheduler](#architecture)

 We can implement scheduler in the Cloud, based on the [Serverless computing](https://en.wikipedia.org/wiki/Serverless_computing), which will trigger a [Watcher](#watcher).


## [Watcher](#architecture)

 We can implement watcher in the Cloud, based on the [Function as a service](https://en.wikipedia.org/wiki/Function_as_a_service), which will be triggered by [Scheduler](#scheduler).


## [Control center](#architecture)

 For control center we might use the following options
   - [Cloudflare HTTP Response Header Modification Rules](https://developers.cloudflare.com/rules/transform/response-header-modification/)
   - [Amazon CloudFront with functions for viewer request](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cloudfront-functions.html)
   - [IPNS](https://docs.ipfs.tech/concepts/ipns/) can be used to implement a fully decentralized control center

| Variable                  | Scope     | Value                                                  | Description                             |
| ------------------------- | --------- | ------------------------------------------------------ | --------------------------------------- |
| **Watcher**               |           |                                                        |                                         |
| `cc-w-s-expression`       | `watcher` | `rate(15 minutes)`                                     | Watcher set scheduler expression        |
| `cc-w-a-desired-capacity` | `watcher` | `3` `{"all": 3, "aws": {"all": 2, "eu-central-1": 1}}` | Watcher set agent desired count         |
| `cc-w-a-start`            | `watcher` | `2022-11-28T13:00:00Z`                                 | Watcher set agent start time            |
| `cc-w-a-start-offset`     | `watcher` | `3 minutes`                                            | Watcher set agent start time offset     |
| `cc-w-a-stop`             | `watcher` | `2022-12-05T13:00:00Z`                                 | Watcher set agent stop time             |
| **Agent**                 |           |                                                        |                                         |
| `cc-a-delay`              | `agent`   | `60`                                                   | Max delay for agent run                 |
| `cc-a-force-run`          | `agent`   | `true`                                                 | Force run, even if code was not updated |
| `cc-a-main-run`           | `agent`   | `ansible/playbook.yml`                                 | Main run scripts for agent              |
| `cc-a-pre-run`            | `agent`   | `echo "Start: $(date)"`                                | Command for agent pre-run               |
| `cc-a-post-run`           | `agent`   | `echo "Finish: $(date)"`                               | Command for agent post-run              |
| `cc-a-repository`         | `agent`   | `https://github.com/p2p-way/p2p-agent-infra`           | Git repository with files for agent     |
| `cc-a-type`               | `agent`   | `ansible`                                              | Agent executor type                     |
| **Agent side watcher**    |           |                                                        |                                         |
| `cc-a-desired-capacity`   | `agent`   | `3` `{"all": 3, "aws": {"all": 2, "eu-central-1": 1}}` | Agent set agent desired count           |
| `cc-a-start`              | `agent`   | `2022-11-28T13:00:00Z`                                 | Agent set agent start time              |
| `cc-a-stop`               | `agent`   | `2022-12-05T13:00:00Z`                                 | Agent set agent stop time               |

 > [!NOTE]
 > Not all commands are implemented and provided for future elaboration


## [Autoscaler](#architecture)

 Autoscaling is the mechanism to dynamically adjust resources amount based on the load, but in our case we will use it in a manual mode to change count of the nodes using [Watcher](#watcher) or [Agent side watcher](#agent-side-watcher) and only when it is supported by the cloud.

 Autoscaler permits us to have the following options
  - Zero initial instances which can be scaled up/down by the watcher, based on control center data
  - Zero initial instances which can be later scaled up and down(can't scale back from 0) by the agent side watcher based on control center or code in a repository data
  - Zero initial instances which will be running for a specific duration, based on an single autoscaler scheduler predefined at deployment

 For the [Cloud Providers](terraform/readme.md#cloud-providers), where autoscaling is not supported, we have to deploy instances right at the moment when we need them.


## [Agent](#architecture)

 Agent is a shell script, which is running on the instance and triggered by cron. Its main functionality is to
 1. Contact control center.
 2. Get information about code repository and executor type, which should be used for instance configuration.
 3. Get the code and run it.

 Relying to the control center adds more flexibility as we can update most important configuration dynamically, without having access to the Git repository or even switch to a different one. But in some cases it may be required to stick with just a static configuration, fully managed via repository code. We can find more information in the [Deployment scenarios](terraform/readme.md#deployment-scenarios).


## [Agent side watcher](#architecture)

 As for now, [Watcher](#watcher) is not implemented for all the clouds and also, services required for watcher implementation may not be accessible in all the regions and we need a way to manage autoscaler settings.

 We can implement very basic watcher functionality on agent side and control center will return the following variables for it
| Variable                | Value                                                  | Description                    |
| ----------------------- | ------------------------------------------------------ | ------------------------------ |
| `cc-a-desired-capacity` | `3` `{"all": 3, "aws": {"all": 2, "eu-central-1": 1}}` | Agent set desired agents count |

 And we apply the following logic using received values
 1. By applying value from `cc-a-desired-capacity` variable to autoscaler we can manage the number or running agents.
 2. When `cc-a-desired-capacity` value is 0, autoscaler will stop all agents and by this will stop their functionality.

 - On Alibaba we use [Instance RAM roles](https://www.alibabacloud.com/help/en/ecs/user-guide/attach-an-instance-ram-role-to-an-ecs-instance) to provide access to the Scaling group configuration using Alibaba Cloud CLI. We manage number of instances by updating Scaling group directly. Initialy created `stop scheduler` will run at its own time and will stop all the instances.

 - On AWS we use [IAM role attached to the EC2 Instance](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html) to provide access to the Auto Scaling group configuration using AWS CLI. Initially, after the autoscaler `start scheduler` run, that scheduler is deleted automatically and in order to scale-in/out instances we update Auto Scaling group directly. Initialy created `stop scheduler` will run at its own time and will stop all the instances.

 - On Azure we use [Managed identities](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) to provide access to the Monitor and Virtual machine scale set configuration using Azure CLI. We manage number of instances by updating scheduler profile.

 - On GCP we use [Authenticate workloads using service accounts](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances) to provide access to the autoscaler configuration using Google Cloud CLI. We manage number of instances by updating Instance Group max instances count and scheduler minimum count.
