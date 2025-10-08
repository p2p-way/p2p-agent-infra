# Architecture

 1. [Description](#description)
 2. [Architecture](#architecture)
 3. [Watcher](#watcher)
 4. [Control center](#control-center)
 5. [Agent](#agent)
 6. [Agent side watcher](#agent-side-watcher)


## [Description](#architecture)

 We may consider to use major [Cloud Providers](https://en.wikipedia.org/wiki/Cloud-computing_comparison) like [Alibaba](https://alibabacloud.com), [AWS](https://aws.amazon.com), [Azure](https://azure.microsoft.com) and [GCP](https://cloud.google.com), to run and configure P2P helper nodes in an automatic way.

 Other providers, like [Akamai](https://www.linode.com), [DigitalOcean](https://www.digitalocean.com) or [Hetzner](https://www.hetzner.com) can be considered as well, even if they does not support [Function as a service](https://en.wikipedia.org/wiki/Function_as_a_service), [Autoscaling](https://en.wikipedia.org/wiki/Autoscaling) and [IAM](https://en.wikipedia.org/wiki/Identity_and_access_management), to implement a [Watcher](#watcher) or [Agent side watcher](#agent-side-watcher).


## [Architecture](#architecture)

```
                        ---- Autoscaler ----       ---------------         IPFS
                      /                      \   /                 \     /
Scheduler --- Watcher --- Control center     Agent     Setup ------- P2P - TON
                                       \        \      /   \       /     \
                                         ----- Scheduler   Repository      Torrent
```

 General workflow might be the following
 1. [Scheduler](#watcher) run a [Watcher](#watcher).
 2. Watcher contact [Control center](#control-center) and check the variables returned over HTTP with the `cc-w` prefix.
 3. If variable `cc-w-a-start` contains the current or past time, watcher will
      - add a `watcher-start` scheduler to the Autoscaler with the date from variable value
      - with the offset based on the `cc-w-a-start-offset` variable
      - with the count based on `cc-w-a-desired-capacity` variable

 4. If variable `cc-w-a-stop` contains the future time, watcher will add a `watcher-stop` scheduler to the Autoscaler based on the variable value and with the count 0.
 5. When agent was activated, watcher might change self scheduler based on the `cc-w-scheduler` variable value.
 6. Autoscaler will run instances based on the created `watcher-start` scheduler.
 7. Scheduler on VM will run [Agent](#agent) and it will contact control center for the variables returned over HTTP with the `cc-a` prefix.
 8. Also, agent can be configured with some defaults to be able to work without relying on a control center.
 9. Agent will get configuration for execution from Git repository specified in the `cc-a-repository` variable.
 10. Agent will execute code specified in the `cc-a-main-run` variable based on the executor type from `cc-a-type` variable.
 11. Also, agent can run commands specified in the `cc-a-pre-run` and `cc-a-post-run` variables.
 12. We also might consider to implement [Agent side watcher](#agent-side-watcher), which is run on VM, only after it was started and it will use values from `cc-a` variables to manage Autoscaler.

 > [!NOTE]
 > We also, might consider to use P2P protocols instead of the centralised platforms control centers.


## [Watcher](#architecture)

 We can implement watcher in the Cloud, based on the [Function as a service](https://en.wikipedia.org/wiki/Function_as_a_service), which will be triggered by scheduler
| # | Cloud                                             | Watcher                                                                      | Scheduler                                                                   |
| - | ------------------------------------------------- | ---------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| 1 | [Alibaba Cloud](https://www.alibabacloud.com)     | [Function Compute](https://www.alibabacloud.com/en/product/function-compute) | [EventBridge](https://www.alibabacloud.com/en/product/eventbridge)          |
| 2 | [Amazon Web Services](https://aws.amazon.com)     | [AWS Lambda](https://aws.amazon.com/lambda/)                                 | [Amazon EventBridge](https://aws.amazon.com/eventbridge/)                   |
| 3 | [Microsoft Azure](https://azure.microsoft.com)    | [Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/)  | [Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/) |
| 4 | [Google Cloud Platform](https://cloud.google.com) | [Cloud Functions](https://cloud.google.com/functions/)                       | [Cloud Scheduler](https://cloud.google.com/scheduler/)                      |

 > [!NOTE]
 > Watcher is not implemented yet and we can use a [Agent side watcher](#agent-side-watcher) only.


## [Control center](#architecture)

 For control center we might use the following options
   - [Cloudflare HTTP Response Header Modification Rules](https://developers.cloudflare.com/rules/transform/response-header-modification/)
   - [Amazon CloudFront with functions for viewer request](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cloudfront-functions.html)
   - [IPNS](https://docs.ipfs.tech/concepts/ipns/) can be used to implement a fully decentralized control center

| Variable                  | Scope     | Value                                                  | Description                             |
| ------------------------- | --------- | ------------------------------------------------------ | --------------------------------------- |
| **Watcher**               |           |                                                        |                                         |
| `cc-w-scheduler`          | `watcher` | `*/10 * * * *`                                         | Scheduler for watcher                   |
| `cc-w-a-desired-capacity` | `watcher` | `3`                                                    | Watcher set agent desired count         |
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


## [Agent](#architecture)

 Agent is a shell script, which is running on the instance and triggered by cron. Its main functionality is to
 1. Contact control center.
 2. Get information about code repository and executor type, which should be used for instance configuration.
 3. Get the code and run it.

 Relying to the control center adds more flexibility as we can update most important configuration dynamically, without having access to the Git repository or even switch to a different one. But in some cases it may be required to stick with just a static configuration, fully managed via repository code. We can find more information in the [Deployment scenarios](terraform/readme.md#deployment-scenarios).


## [Agent side watcher](#architecture)

 As for now, [Watcher](#watcher) is not implemented yet and also, scheduler may not be accessible in all the regions and we need a way to manage Autoscaler settings.

 We can implement very basic watcher functionality on agent side and control center will return the following variables for it
| Variable                | Value                                                  | Description                    |
| ----------------------- | ------------------------------------------------------ | ------------------------------ |
| `cc-a-desired-capacity` | `3` `{"all": 3, "aws": {"all": 2, "eu-central-1": 1}}` | Agent set desired agents count |

 And we apply the following logic using received values
 1. By applying value from `cc-a-desired-capacity` variable to Autoscaler we can manage the number or running agents.
 2. When `cc-a-desired-capacity` value is 0, Autoscaler will stop all agents and by this will stop their functionality.

 - On Alibaba we use [Instance RAM roles](https://www.alibabacloud.com/help/en/ecs/user-guide/attach-an-instance-ram-role-to-an-ecs-instance) to provide access to the Scaling group configuration using Alibaba Cloud CLI. We manage number of instances by updating Scaling group directly. Initialy created `stop scheduler` will run at its own time and will stop all the instances.

 - On AWS we use [IAM role attached to the EC2 Instance](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html) to provide access to the Auto Scaling group configuration using AWS CLI. Initially, after the Autoscaler `start scheduler` run, that scheduler is deleted automatically and in order to scale-in/out instances we update Auto Scaling group directly. Initialy created `stop scheduler` will run at its own time and will stop all the instances.

 - On Azure we use [Managed identities](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) to provide access to the Monitor and Virtual machine scale set configuration using Azure CLI. We manage number of instances by updating scheduler profile.

 - On GCP we use [Authenticate workloads using service accounts](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances) to provide access to the Autoscaler configuration using Google Cloud CLI. We manage number of instances by updating Instance Group max instances count and scheduler minimum count.
