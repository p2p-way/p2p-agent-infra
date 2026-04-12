# P2P agent on Alibaba

 1. [Description](#description)
 2. [Considerations](#considerations)
 3. [Limitations](#limitations)
 4. [Regions](#regions)
 5. [Costs](#costs)
 6. [Requirements](#requirements)
 7. [Deployment](#deployment)
 8. [Cleanup](#cleanup)
 9. [Known issues](#known-issues)


## [Description](#p2p-agent-on-alibaba)

 This code provides [Terraform](../readme.md) configuration for [Alibaba Cloud](https://www.alibabacloud.com) stack deployment for P2P content distribution.
 1. [Resource Access Management (RAM)](https://www.alibabacloud.com/en/product/ram) - Provides access for Function and VM instance to update  Auto Scaling group and Function trigger.
 2. [Function Compute](https://www.alibabacloud.com/en/product/function-compute) - Run a function which will act as a watcher and setup a trigger which will act as a scheduler and orchestrate VM provisioning via autoscaler.
 3. [Virtual Private Cloud (VPC)](https://www.alibabacloud.com/en/product/vpc) - Provides a network for the VM instances.
 4. [Auto Scaling](https://www.alibabacloud.com/en/product/auto-scaling) - Scale and manage VM instances.
 5. [Elastic Compute Service](https://www.alibabacloud.com/en/product/ecs) - VM provisioning.
 6. [Simple Log Service](https://www.alibabacloud.com/en/product/log-service) - VM and function logs.
 7. [CloudMonitor](https://www.alibabacloud.com/en/product/cloud-monitor) - VM metrics.

 Generally, this configuration will do the following

**Watcher and scheduler**
 1. Create RAM role with policies.
 2. Create Simple Log Service project and Logstore.
 3. Create OSS bucket and upload Function layer package into it.
 4. Create Function layer from the package located on OSS.
 5. Create scheduler using Function trigger which will invoke function.

**Agent**
 1. Create VPC for ECS instances.
 2. Create RAM instance role with policies.
 3. Create ECS Launch template for the instances.
 4. Create Auto Scaling group using ECS Launch template.
 5. Create Simple Log Service project and Logstore.


## [Considerations](#p2p-agent-on-alibaba)

 1. Check [Considerations](../readme.md#considerations).


## [Limitations](#p2p-agent-on-alibaba)

 1. Alibaba [ECS Availability Zones](https://www.alibabacloud.com/help/en/ecs/regions-and-zones) vary by region and can be from 1 up to 12, please check [Supported regions and zones](https://www.alibabacloud.com/help/en/ecs/regions-and-zones#concept-nwo-3ho-q3v) for more details.
 2. Watcher can be used just in several regions, please check [Known issues](#known-issues) for more details.
 3. [Remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/remote) for Terraform is not implemented yet and state will be stored locally.


## [Regions](#p2p-agent-on-alibaba)

 - [Data Centers Around the World](https://www.alibabacloud.com/en/global-locations)
 - [Regions and zones](https://www.alibabacloud.com/help/en/ecs/regions-and-zones)
 - [Products by Regions](https://www.alibabacloud.com/en/global-locations)
 - [Elastic Compute Service - Supported regions and zones](https://www.alibabacloud.com/help/en/ecs/regions-and-zones#concept-nwo-3ho-q3v)
 - [Elastic Compute Service - Query the regions supported by ECS](https://www.alibabacloud.com/help/en/ecs/regions-and-zones#100e5a1cee6s0)
 - [Instance Types Available for Each Region](https://ecs-buy.aliyun.com/instanceTypes/)
 - [ECS instance type selection](https://www.alibabacloud.com/help/en/ecs/user-guide/best-practices-for-instance-type-selection)

   ```shell
   # Query the regions supported by ECS
   aliyun ecs DescribeRegions --AcceptLanguage en-US --output cols="RegionId,LocalName" rows="Regions.Region" num=true

   # List availability zones
   for region in $(aliyun ecs DescribeRegions --AcceptLanguage en-US | jq -r '.Regions.Region | sort_by(.RegionId) | .[].RegionId'); do
     zones=$(aliyun ecs DescribeZones --RegionId "${region}" | jq -r '[.Zones.Zone[].ZoneId] | sort')
     zones_count=$(jq -r 'length' <<< "${zones}")
     zones_list=$(jq -r 'join("\n\t\t\t\t")' <<< "${zones}")
     echo -e "${region}\t\t${zones_count}\t${zones_list}\n"
   done

   # List instance type provided by ECS
   aliyun ecs DescribeInstanceTypes \
     --output cols="InstanceTypeId,CpuArchitecture,CpuCoreCount,MemorySize,InstanceCategory" \
     rows="InstanceTypes.InstanceType" \
     num=true

   # List small instance type provided by ECS
   aliyun ecs DescribeInstanceTypes \
     --MaximumCpuCoreCount 2 \
     --output cols="InstanceTypeId,CpuArchitecture,CpuCoreCount,MemorySize,InstanceCategory" \
     rows="InstanceTypes.InstanceType" \
     num=true

    # List resources available in a region first AZ
    aliyun ecs DescribeZones --RegionId eu-central-1 | jq -r '.Zones.Zone[0].AvailableDiskCategories.DiskCategories[]'
    aliyun ecs DescribeZones --RegionId eu-central-1 | jq -r '.Zones.Zone[0].AvailableInstanceTypes.InstanceTypes[]' | sort

   # List ECS quotas by instance type
   aliyun quotas ListProductQuotas --ProductCode ecs-spec \
     --output cols="Dimensions.regionId,QuotaCategory,QuotaActionCode,QuotaUnit,TotalUsage,TotalQuota,Adjustable" \
     rows="Quotas" \
     num=true
   ```


## [Costs](#p2p-agent-on-alibaba)

 [Alibaba Cloud Product Price Calculator](https://www.alibabacloud.com/en/pricing-calculator)

 | Resource                                                                                  | Price              | Costs            | Comment                                    |
 | ----------------------------------------------------------------------------------------- | ------------------ | ---------------- | ------------------------------------------ |
 | [ECS Instance](https://www.alibabacloud.com/en/product/ecs)                               | `0.0199 $/h`       | `14.81 $/m`      | ecs.e-c1m1.large / China (Hong Kong)       |
 | [Elastic Block Storage](https://www.alibabacloud.com/product/disk/pricing)                | `0.000106 $/GiB/h` | `1.53 $/20GiB/m` | Enhanced SSD Entry                         |
 | [ECS Bandwidth](https://www.alibabacloud.com/en/product/ecs)                              | `17 $/m`           | `17 $/m`         | Pay-By-Bandwidth 5Mbps / China (Hong Kong) |
 | [CloudMonitor](https://www.alibabacloud.com/help/en/cms/product-overview/pay-as-you-go-1) | `-`                | `-`              | Free quota                                 |
 | [Function Compute](https://www.alibabacloud.com/en/product/function-compute/pricing)      | `0.2 $/mil calls`  | `-`              | Free quota                                 |
 | [Simple Log Service](https://www.alibabacloud.com/en/product/log-service/pricing)         | `-`                | `-`              | Free quota                                 |
 | TOTAL                                                                                     |                    | `33.34 $/m`      |                                            |

```
33.34 $/m/i / 31 d =  1.08 $/d/i    # 1 day / 1 instance / 1 region
 1.08 $/d/i x 28 r =  30.24 $/d/i/r # 1 day / 1 instance / all regions
```

 Run **1 instance** in **all public regions**, during **1 day**, may cost ~ **30.24 $**

 > [!NOTE]
 > Provided costs are very approximate because we use a highest instance price and traffic across all the regions. Also, free quota may not cover multiple instances running for a long period of time.


## [Requirements](#p2p-agent-on-alibaba)

 In order to proceed with this deployment, we need
 1. Linux host with [Terraform](https://developer.hashicorp.com/terraform/install) installed.
 2. Alibaba Cloud [RAM user](https://www.alibabacloud.com/help/en/ram/user-guide/overview-of-ram-users) with the following programmatic access permissions
      * `AliyunFCFullAccess`
      * `AliyunVPCFullAccess`
      * `AliyunRAMFullAccess`
      * `AliyunECSFullAccess`
      * `AliyunLogFullAccess`
      * `AliyunCloudMonitorFullAccess`


## [Deployment](#p2p-agent-on-alibaba)

 1. Get Terraform code from GitHub repository
    ```shell
    git clone https://github.com/p2p-way/p2p-agent-infra

    cd p2p-agent-infra/terraform/alibaba
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

 4. Authenticate on Alibaba
    ```shell
    export ALIBABA_CLOUD_ACCESS_KEY_ID="<access key>"
    export ALIBABA_CLOUD_ACCESS_KEY_SECRET="<secret access key>"
    ```

 5. When we set `start_time = "watcher"` it is required to prepare a function layer package.
    <details><summary>More details</summary>

    Default runtime does not contain all required dependencies and [public layers](https://www.alibabacloud.com/help/en/functioncompute/fc/user-guide/configure-common-layers-for-a-function-1) as well and we have to use a custom layer - [Install third-party dependencies for a function](https://www.alibabacloud.com/help/en/functioncompute/fc/user-guide/install-third-party-dependencies-for-a-function). One of the way to [Create a custom layer](https://www.alibabacloud.com/help/en/functioncompute/fc/user-guide/create-a-custom-layer-1) would be to follow [Use a Dockerfile to build a layer](https://www.alibabacloud.com/help/en/functioncompute/fc/user-guide/use-a-dockerfile-to-build-a-layer-1)
    ```shell
    layer_folder="watcher-python-layer"
    layer_package="watcher-python-layer.zip"
    base_image="aliyunfc/runtime-custom.debian10"

    docker run -it \
      --entrypoint=bash \
      --volume ./:/opt \
      ${base_image} \
      -c "pip install --upgrade pip; \
        pip install --target /opt/python \
          alibabacloud_fc20230330 \
          alibabacloud_ess20220222 \
          alibabacloud_credentials \
          alibabacloud_tea_openapi \
          alibabacloud_tea_util; \
        cd /opt; \
        zip -r /opt/${layer_package} python; \
        rm -rf /opt/python"
    ```

    By the end we will get a *watcher-python-layer.zip* archive which will be used by Terraform at function layer creation.
    </details>

 6. Run Terraform
    ```shell
    # Initialize
    terraform init

    # View execution plan
    terraform plan

    # Apply changes
    terraform apply
    ```

 7. Get SSH keys
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

 8. Add value of the `repository_public_key` output to the Git repository
    - GitHub: Repository --> Settings --> Security --> Deploy keys

 After some period of time all resources will be created and nodes will start. After the start, they will connect to the control center and will setup all configuration required to support P2P content distribution.


### [Update configuration](#p2p-agent-on-alibaba)

 After we deployed initial configuration, it may be required to update nodes capacity or add more regions. And next steps mainly depends on the start time we set.

 We also should keep in mind that, when we use autoscaling with a control center which is managed outside of this code, we might get a configuration drift which can be solved by sync variables with the values from a control center.

 **Nodes not started yet**

 Update is very transparent and we need just to set `desired_capacity` with the required number and run Terraform.

 > [!NOTE]
 > Please note, that computed start/stop time value will not be changed and in case we need that, we should increase `time_offset_version`.

 **Nodes already started**

 When nodes already started, following things are happened
 - Desired capacity of the Auto Scaling group was changed already by start scheduler, from 0 to the value we set at the apply, and Terraform will try to set it back to 0 and it will lead to the termination of the running instances and new instances will be run by the new scheduler start and it will lead to a down-time.

 To overcome both cases, we should set `initial_deploy = false` and Terraform will change it's behavior in the following way
 - Capacity for Auto Scaling group, which is initially set to 0, will use value from `desired_capacity`.

 Update variable in the *variables.auto.tfvars* file
 ```shell
 vi variables.auto.tfvars
 ```
 ```
 initial_deploy = false
 ```


#### [Update capacity](#p2p-agent-on-aws)

 1. Set `initial_deploy = false` in the *variables.auto.tfvars*.
 2. Set `desired_capacity` in the *variables.auto.tfvars* globaly, or set it per region in the module configuration.
 3. Run `terraform plan`.
 4. Run `terraform apply`.


#### [Add new region](#p2p-agent-on-aws)

 1. Set `initial_deploy = false` in the *variables.auto.tfvars*.
 2. Add a configuration file for the new region.
 3. Set `initial_deploy = true` in the module configuration, for this new region only.
 4. Run `terraform init`.
 5. Run `terraform plan`.
 6. Run `terraform apply`.
 7. Set back `initial_deploy = var.initial_deploy` in the module configuration, for this new region, and it will imply usage of the globaly defined value in the *variables.auto.tfvars*.
 8. Run `terraform plan`.
 9. Run `terraform apply`.


## [Cleanup](#p2p-agent-on-alibaba)

 In order to cleanup all created resources we should use the following steps
 1. Cleanup resources created by Terraform
    ```shell
    terraform destroy
    ```

 2. Cleanup created zip archives when `start_time = "watcher"`
    ```shell
    rm -f *.zip
    ```


## [Known issues](#p2p-agent-on-alibaba)

 1. We rely on the [system route table](https://www.alibabacloud.com/help/en/vpc/user-guide/routing-table/), because we got an intermittent error when trying to attach custom route table to vSwitches.

 2. Before enabling `agent_metrics`, we should make sure that [`AliyunServiceRoleForCloudMonitor` linked role](https://www.alibabacloud.com/help/en/cms/user-guide/manage-the-service-linked-role-for-cloudmonitor) was already created.

 3. On newly created account, you might not be able to run instances due to "`This operation is forbidden by Aliyun RiskControl system.`" error and we should contact support for [ID Verification - KYC](https://www.alibabacloud.com/help/en/ekyc/latest/product-introduction).

 4. Some regions endpoints are flaky and it might be required to re-run Terraform apply/destroy
    > `Error: [ERROR] terraform-provider-alicloud/alicloud/data_source_alicloud_regions.go:72: Datasource alicloud_regions DescribeRegions Failed!!! [SDK alibaba-cloud-sdk-go ERROR]:`
    - `region-cn-chengdu.tf`
    - `region-cn-shenzhen.tf`
    - `region-cn-fuzhou.tf`
    - `region-cn-shanghai.tf`
    - `region-cn-guangzhou.tf`
    - `region-cn-heyuan.tf`

 5. In some regions instances were not tested due to the errors or limits.
    <details>
    <summary>More details</summary>

    **Scaling Group is created but instances failed to start**
    > `Fail to scale instances for scaling group(code:"InvalidInstanceType.NotAuthorized", msg:"Instance types are not authorized.").`
    - `1-region-cn-wuhan-lr.tf`

    > `Fail to scale instances for scaling group(code:"RecommendEmpty.DiskTypeNoStock", msg:"The diskTypes are out of usage.").`
    - `2-region-cn-beijing.tf`

    > `Fail to scale instances for scaling group(code:"RecommendEmpty.InstanceTypeNoStock", msg:"The instanceTypes are out of usage.").`
    - `3-region-cn-hangzhou.tf`
    - `3-region-cn-qingdao.tf`
    - `3-region-cn-zhangjiakou.tf`

    **Scaling group can't be created**
    ```
    module.me-east-1.alicloud_ess_scaling_group.agent[0]: Creating...
    ╷
    │ Error: [ERROR] terraform-provider-alicloud/alicloud/resource_alicloud_ess_scaling_group.go:279: Resource alicloud_ess_scaling_group CreateScalingGroup Failed!!! [SDK alibaba-cloud-sdk-go ERROR]:
    │ [ERROR] terraform-provider-alicloud/alicloud/resource_alicloud_ess_scaling_group.go:264: Resource alicloud_ess_scaling_group CreateScalingGroup Failed!!! [SDK alibaba-cloud-sdk-go ERROR]:
    │ SDKError:
    │    StatusCode: 400
    │    Code: InvalidScalingGroupName.Duplicate
    │    Message: code: 400, The specified value of parameter "ScalingGroupName" is duplicated. request id: 78581C3F-A349-3D14-871A-6F5C7507DA3A
    │    Data: {"Code":"InvalidScalingGroupName.Duplicate","HostId":"ess.me-east-1.aliyuncs.com","Message":"The specified value of parameter \"ScalingGroupName\" is duplicated.","Recommend":"https://api.alibabacloud.com/troubleshoot?intl_lang=EN_US&q=InvalidScalingGroupName.Duplicate&product=Ess&requestId=78581C3F-A349-3D14-871A-6F5C7507DA3A","RequestId":"78581C3F-A349-3D14-871A-6F5C7507DA3A"}
    │
    │
    │   with module.me-east-1.alicloud_ess_scaling_group.agent[0],
    │   on modules/agent/agent-scaling-group.tf line 2, in resource "alicloud_ess_scaling_group" "agent":
    │    2: resource "alicloud_ess_scaling_group" "agent" {
    │
    ╵
    ```
    - `4-region-me-east-1.tf`
    </details>

 6. Download from GitHub is very slow (limited?) in China regions, at least in Guangzhou.

 7. When we use `start_time = "watcher"` and recreate resources, [Service-linked role of Function Compute](https://www.alibabacloud.com/help/en/functioncompute/fc/service-linked-role-of-function-compute) does not work properly and we get an error
    > `"errorMessage": "Error: Forbidden.Unauthorized code: 403, {\"effectMap\":{\"0\":\"DENY\"},\"ramAuthResponseList\":[{\"accessDeniedDetail\":{\"authAction\":\"ess:DescribeScalingGroups\",\"authPrincipalDisplayName\":\"p2p-watcher-eu-central-1:FunctionCompute\",\"authPrincipalOwnerId\":\"<1111111111111111>\",\"authPrincipalType\":\"AssumedRoleUser\",\"encodedDiagnosticMessage\"`

    As a workaround, we add a random suffix to roles names at creation.

 8. [Alibaba  Function Compute](https://www.alibabacloud.com/en/product/function-compute) does not work properly in some regions and we can't use `start_time = "watcher"` for them

    **Functions Compute service is not available in all re regions** - check [Endpoints of Function Compute](https://www.alibabacloud.com/help/en/functioncompute/fc/developer-reference/fc-endpoints) as a reference
    - `region-ap-southeast-6.tf`
    - `region-cn-guangzhou.tf`
    - `region-cn-fuzhou.tf`
    - `region-cn-nanjing.tf`
    - `region-cn-heyuan.tf`
    - `region-na-south-1.tf`

    **Functions executes with an error**
    > Error: Function timed out after 5 seconds
    <details>
    <summary>Error details</summary>

    > `'  File "/var/fc/runtime/python3.12/bootstrap.py", line 631, in <module>\n    main()\n', '  File "/var/fc/runtime/python3.12/bootstrap.py", line 619, in main\n    handler.handle_request()\n', '  File "/var/fc/runtime/python3.12/bootstrap.py", line 252, in handle_request\n    valid_handler, request_handler = _concurrent_get_handler(handler)\n', '  File "/var/fc/runtime/python3.12/bootstrap.py", line 87, in _concurrent_get_handler\n    return _get_handler(handler)\n', '  File "/var/fc/runtime/python3.12/bootstrap.py", line 108, in _get_handler\n    m = importlib.import_module(modname.replace("/", "."))\n', '  File "/var/fc/lang/python3.12/lib/python3.12/importlib/__init__.py", line 90, in import_module\n    return _bootstrap._gcd_import(name[level:], package, level)\n', '  File "<frozen importlib._bootstrap>", line 1387, in _gcd_import\n', '  File "<frozen importlib._bootstrap>", line 1360, in _find_and_load\n', '  File "<frozen importlib._bootstrap>", line 1331, in _find_and_load_unlocked\n', '  File "<frozen importlib._bootstrap>", line 935, in _load_unlocked\n', '  File "<frozen importlib._bootstrap_external>", line 995, in exec_module\n', '  File "<frozen importlib._bootstrap>", line 488, in _call_with_frames_removed\n', '  File "/code/watcher.py", line 8, in <module>\n    from alibabacloud_ess20220222.client import Client as Ess20220222Client\n', '  File "<frozen importlib._bootstrap>", line 1360, in _find_and_load\n', '  File "<frozen importlib._bootstrap>", line 1331, in _find_and_load_unlocked\n', '  File "<frozen importlib._bootstrap>", line 935, in _load_unlocked\n', '  File "<frozen importlib._bootstrap_external>", line 995, in exec_module\n', '  File "<frozen importlib._bootstrap>", line 488, in _call_with_frames_removed\n', '  File "/opt/python/alibabacloud_ess20220222/client.py", line 7, in <module>\n    from alibabacloud_ess20220222 import models as main_models\n', '  File "<frozen importlib._bootstrap>", line 1415, in _handle_fromlist\n', '  File "<frozen importlib._bootstrap>", line 488, in _call_with_frames_removed\n', '  File "<frozen importlib._bootstrap>", line 1360, in _find_and_load\n', '  File "<frozen importlib._bootstrap>", line 1331, in _find_and_load_unlocked\n', '  File "<frozen importlib._bootstrap>", line 935, in _load_unlocked\n', '  File "<frozen importlib._bootstrap_external>", line 995, in exec_module\n', '  File "<frozen importlib._bootstrap>", line 488, in _call_with_frames_removed\n', '  File "/opt/python/alibabacloud_ess20220222/models/__init__.py", line 237, in <module>\n    from ._modify_scaling_configuration_request import ModifyScalingConfigurationRequest\n', '  File "<frozen importlib._bootstrap>", line 1360, in _find_and_load\n', '  File "<frozen importlib._bootstrap>", line 1331, in _find_and_load_unlocked\n', '  File "<frozen importlib._bootstrap>", line 935, in _load_unlocked\n', '  File "<frozen importlib._bootstrap_external>", line 991, in exec_module\n', '  File "<frozen importlib._bootstrap_external>", line 1129, in get_code\n', '  File "<frozen importlib._bootstrap_external>", line 1059, in source_to_code\n', '  File "<frozen importlib._bootstrap>", line 488, in _call_with_frames_removed\n', '  File "/var/fc/runtime/python3.12/bootstrap.py", line 31, in dump_stacks\n    detail_msg = traceback.format_stack(stack)\n'`
    </details>

    - `region-ap-northeast-2.tf`
    - `region-ap-southeast-3.tf`
    - `region-ap-southeast-5.tf`
    - `region-ap-southeast-7.tf`
    - `region-cn-chengdu.tf`
    - `region-eu-west-1.tf`
    - `region-cn-wulanchabu.tf`


    > Name or service not known
    <details>
    <summary>Error details</summary>

    > `"errorMessage": "{'message': 'HTTPSConnectionPool(host=\\'ess.cn-shanghai.aliyuncs.com\\', port=443): Max retries exceeded with url: /?RegionId=cn-shanghai&ScalingGroupName=p2p-agent-cn-shanghai (Caused by NameResolutionError(\"HTTPSConnection(host=\\'ess.cn-shanghai.aliyuncs.com\\', port=443): Failed to resolve \\'ess.cn-shanghai.aliyuncs.com\\' ([Errno -2] Name or service not known)\"))'}"`
    </details>

    - `region-cn-shanghai.tf`
