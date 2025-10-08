# P2P agent on AWS

 1. [Description](#description)
 2. [Considerations](#considerations)
 3. [Limitations](#limitations)
 4. [Regions](#regions)
 5. [Costs](#costs)
 6. [Requirements](#requirements)
 7. [Deployment](#deployment)
 8. [Cleanup](#cleanup)
 9. [Known issues](#known-issues)


## [Description](#p2p-agents-on-aws)

 This code provides [Terraform](../readme.md) configuration for [Amazon Web Services](https://aws.amazon.com/) stack deployment for P2P content distribution.
 1. [Amazon CloudFront](https://aws.amazon.com/cloudfront/) - Control center which will return headers based on the CloudFront Functions.
 2. [Amazon S3](https://aws.amazon.com/s3/) - Origin for control center CloudFront distribution.
 3. [AWS WAF](https://aws.amazon.com/waf/) - Protect control center.
 4. [AWS Lambda](https://aws.amazon.com/lambda/) - Run a function which will act as watcher and orchestrate VM provisioning via Auto Scaling groups.
 5. [Amazon EventBridge](https://aws.amazon.com/eventbridge/) - Provides a scheduler to invoke the Lambda function.
 6. [Amazon VPC](https://aws.amazon.com/vpc/) - Provides a network for the VM.
 7. [AWS Auto Scaling](https://aws.amazon.com/autoscaling/) - Scale and manage VM instances.
 8. [Amazon EC2](https://aws.amazon.com/ec2/) - VM provisioning.
 9. [Amazon CloudWatch](https://aws.amazon.com/cloudwatch/) - Logs and Metrics.

 Generally, this configuration will do the following

**Control center**
 1. Create S3 bucket origin for the CloudFront.
 2. Create CloudFront Function with headers and their values.
 3. Create CloudFront distribution with S3 bucket origin and attach function to the viewer request event.
 4. Create AWS WAF and assign it to the CloudFront distribution.

**Watcher and scheduler**
 > [!NOTE]
 > Watcher and scheduler is not implemented yet
 1. Create an S3 bucket and upload Lambda code into it.
 2. Create a Lambda function from the code located on S3.
 3. Create a scheduler using EventBridge which will invoke Lambda function.

**Agent**
 1. Create a VPC for EC2 instances.
 2. Create IAM instance profile.
 3. Create an EC2 Launch template for the instances.
 4. Create an Auto Scaling group using EC2 Launch template.
 5. Create CloudWatch Log group.


## [Considerations](#p2p-agents-on-aws)

**Control center**
 1. WAF is disabled by default for costs optimisations and because control center hostname is known only by the agents.

**Watcher and scheduler**
 1. We use `x86_64` instead of `arm64` for Lambda functions architecture because `arm64` may not be accessible in all regions.

**Agent**
 1. Check [Considerations](../readme.md#considerations).


## [Limitations](#p2p-agents-on-aws)

 1. Almost all of the AWS Regions have 3 Availability Zones and some of them like *Northern California* and *São Paulo* may provide access just to two AZ's.
 2. Watcher is not implemented yet and we should set variable [`start_time`](../readme.md#configuration) only as `now` or specify a custom time.
 3. Control center [alternate domain name](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-https-alternate-domain-names.html) is not implemented yet and a distribution default domain name will be used.
 4. [Remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/remote) for Terraform is not implemented yet and state will be stored locally.


## [Regions](#p2p-agents-on-aws)

 - [Regions and Availability Zones](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/)
 - [AWS Regional Services](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/)
 - [List regions](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/account/list-regions.html)
 - [Describe regions](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ds/describe-regions.html)
 - [Describes Availability Zones](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-availability-zones.html)
 - [Amazon EC2 instance types by Region](https://docs.aws.amazon.com/ec2/latest/instancetypes/ec2-instance-regions.html)

   ```shell
   # Lists all the Regions for a given account
   aws account list-regions --output table

   # Describes the Regions that are enabled for your account, or all Regions
   aws ec2 describe-regions \
     --query 'sort_by(Regions[], &RegionName)[].{RegionName: RegionName, RegionOptStatus: OptInStatus}' \
     --output table

   # List Availability Zones for enabled regions
   echo -e "\nRegion\t\t\tCount\tAZ"
   for region in $(aws ec2 describe-regions --output text --query 'sort_by(Regions[], &RegionName)[].RegionName'); do
     zones=$(aws ec2 describe-availability-zones --region "${region}" --output json --query 'sort_by(AvailabilityZones[], &ZoneName)[].ZoneName')
     zones_count=$(jq -r 'length' <<< "${zones}")
     zones_list=$(jq -r 'join("\n\t\t\t\t")' <<< "${zones}")
     echo -e "${region}\t\t${zones_count}\t${zones_list}\n"
   done

   # List available instances in the region
   aws ec2 describe-instance-types \
     --region eu-central-1 \
     --query 'sort_by(InstanceTypes[], &InstanceType)[].{"  Instance": InstanceType, " vCPU": VCpuInfo.DefaultVCpus, Memory: MemoryInfo.SizeInMiB}' \
     --output table

    # List small instances in the region
    aws ec2 describe-instance-types \
      --region eu-central-1 \
      --query 'sort_by(InstanceTypes[], &InstanceType)[?VCpuInfo.DefaultVCpus<=`2`].{"  Instance": InstanceType, " vCPU": VCpuInfo.DefaultVCpus, Memory: MemoryInfo.SizeInMiB}' \
      --output table

   # Lists the applied quota values for the EC2 service
   echo -e "\nRegion\t\t\tValue\tAdjustable"
   for region in $(aws ec2 describe-regions --output text --query 'sort_by(Regions[], &RegionName)[].RegionName'); do
     quotas=$(aws service-quotas list-service-quotas --region "${region}" --service-code ec2 --query 'Quotas[?QuotaName==`Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances`].{Value: Value, Adjustable: Adjustable}')
     value=$(jq -r '.[].Value' <<< "${quotas}")
     adjustable=$(jq -r '.[].Adjustable' <<< "${quotas}")
     echo -e "${region}\t\t${value}\t${adjustable}"
   done
   ```


## [Costs](#p2p-agents-on-aws)

 [AWS Pricing Calculator](https://calculator.aws/)

 | Resource                                                                | Price          | Costs          | Comment                              |
 | ----------------------------------------------------------------------- | -------------- | -------------- | ------------------------------------ |
 | [EC2 Instance](https://aws.amazon.com/ec2/pricing/on-demand/)           | `0.0168 $/h`   | `12.50 $/m`    | t3.micro / South America - São Paulo |
 | [EC2 EBS](https://aws.amazon.com/ebs/pricing/)                          | `0.152 $/GB/m` | `1.22 $/8GB/m` |                                      |
 | [EC2 Traffic](https://aws.amazon.com/ec2/pricing/on-demand/)            | `0.15 $/GB`    | `15 $/100GB`   |                                      |
 | [EC2 CloudWatch Metrics](https://aws.amazon.com/cloudwatch/pricing/)    | `0.30 $/m/m`   | `1.5 $/50000`  |                                      |
 | [EC2 CloudWatch Logs](https://aws.amazon.com/cloudwatch/pricing/)       | `-`            | `-`            | Free Tier                            |
 | [CloudFront Traffic](https://aws.amazon.com/cloudfront/pricing/)        | `-`            | `-`            | Free Tier                            |
 | [CloudFront HTTPS Requests](https://aws.amazon.com/cloudfront/pricing/) | `-`            | `-`            | Free Tier                            |
 | [CloudFront Functions](https://aws.amazon.com/cloudfront/pricing/)      | `-`            | `-`            | Free Tier                            |
 | TOTAL                                                                   |                | `30.22 $/m`    |                                      |

```
30.22 $/m/i / 31 d =  0.97 $/d/i   # 1 day / 1 instance / 1 region
 0.97 $/d/i x 34 r = 32.98 $/d/i/r # 1 day / 1 instance / all regions
```

 Run **1 instance** in **all public regions**, during **1 day**, may cost ~ **32.98 $**

 > [!NOTE]
 > Provided costs are very approximate because we use a highest instance price and traffic across all the regions. Also, free tier may not cover multiple instances running for a long period of time.


## [Requirements](#p2p-agents-on-aws)

 In order to proceed with this deployment, we need
 1. Linux host with [Terraform](https://developer.hashicorp.com/terraform/install) installed.
 2. AWS [IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users.html) with the following programmatic access permissions
      * `AWSLambda_FullAccess`
      * `AmazonEventBridgeFullAccess`
      * `AmazonVPCFullAccess`
      * `IAMFullAccess`
      * `AmazonEC2FullAccess`
      * `AmazonS3FullAccess`
      * `CloudFrontFullAccess`
      * `AWSWAFFullAccess`
      * `CloudWatchFullAccess`


## [Deployment](#p2p-agents-on-aws)

 1. Get Terraform code from GitHub repository
    ```shell
    git clone https://github.com/p2p-way/p2p-agent-infra

    cd p2p-agent-infra/terraform/aws
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

    Optionally, enable control center creation by setting `cc_create=true` and adjust its configuration, please see [Control center](../../architecture.md#control-center) for more information.

 4. Authenticate on AWS
    ```shell
    export AWS_ACCESS_KEY_ID="<access key>"
    export AWS_SECRET_ACCESS_KEY="<secret access key>"
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


### [Update configuration](#p2p-agents-on-aws)

 After we deployed initial configuration, it maybe required to update nodes capacity or add more regions or even update control center configuration. And next steps mainly depends on the start time we set.

 **Nodes not started yet**

 Update is very transparent and we need just to set `desired_capacity` with the required number and run Terraform.

 > [!NOTE]
 > Please note, that computed start/stop time value will not be changed and in case we need that, we should increase `time_offset_version`.

 **Nodes already started**

 When nodes already started, following things are happened
 - Start scheduler in Auto Scaling group was executed and deleted, at the apply, and Terraform will try to re-create it and will fail because of the past time passed at re-creation.
 - Desired capacity of the Auto Scaling group was changed already by start scheduler, from 0 to the value we set at the apply, and Terraform will try to set it back to 0 and it will lead to the termination of the running instances and new instances will be run by the new scheduler start and it will lead to the down-time.

 To overcome both cases, we should set `initial_deploy = false` and Terraform will change it's behavior in the following way
 - Start scheduler will not be re-created.
 - Capacity for Auto Scaling group, which is initially set to 0, will use value from `desired_capacity`.

 Update variable in the *variables.auto.tfvars* file
 ```shell
 vi variables.auto.tfvars
 ```
 ```
 initial_deploy = false
 ```


#### [Update capacity](#p2p-agents-on-aws)

 1. Set `initial_deploy = false` in the *variables.auto.tfvars*.
 2. Set `desired_capacity` in the *variables.auto.tfvars* globaly, or set it per region in the module configuration.
 3. Run `terraform plan`.
 4. Run `terraform apply`.


#### [Add new region](#p2p-agents-on-aws)

 1. Set `initial_deploy = false` in the *variables.auto.tfvars*.
 2. Add a configuration file for the new region.
 3. Set `initial_deploy = true` in the module configuration, for this new region only.
 4. Run `terraform init`.
 5. Run `terraform plan`.
 6. Run `terraform apply`.
 7. Set back `initial_deploy = var.initial_deploy` in the module configuration, for this new region, and it will imply usage of the globaly defined value in the *variables.auto.tfvars*.
 8. Run `terraform plan`.
 9. Run `terraform apply`.


## [Cleanup](#p2p-agents-on-aws)

 In order to cleanup all created resources we should use the following steps
 1. Cleanup resources created by Terraform
    ```shell
    terraform destroy
    ```


## [Known issues](#p2p-agents-on-aws)

 1. [AWS service quotas](https://docs.aws.amazon.com/general/latest/gr/aws_service_limits.html) may not permit to run required number of instances, especialy on newly created accounts or accounts with the low expenses and we should contact AWS for [Requesting a quota increase](https://docs.aws.amazon.com/servicequotas/latest/userguide/request-quota-increase.html).

 2. Please make sure you did [Enable or disable AWS Regions in your account](https://docs.aws.amazon.com/accounts/latest/reference/manage-acct-regions.html) before deployment.
