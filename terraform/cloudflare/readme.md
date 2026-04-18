# Services on Cloudflare

 1. [Description](#description)
 2. [Limitations](#limitations)
 3. [Costs](#costs)
 4. [Requirements](#requirements)
 5. [Deployment](#deployment)
 6. [Cleanup](#cleanup)
 7. [Known issues](#known-issues)


## [Description](#control-center-on-cloudflare)

 This code provides [Terraform](../readme.md) configuration for [Cloudflare](https://www.cloudflare.com) stack deployment for P2P content distribution.
 1. [Cloudflare DNS](https://www.cloudflare.com/application-services/products/dns/) - Control center and radar DNS name
 2. [Cloudflare R2](https://www.cloudflare.com/developer-platform/products/r2/) - Control center origin
 3. [Cloudflare CDN](https://www.cloudflare.com/application-services/products/cdn/) with [Cloudflare Rules](https://developers.cloudflare.com/rules/) - Control center which will return headers
 4. [Cloudflare Workers](https://workers.cloudflare.com/) - Radar endpoint URL
 5. [Cloudflare Workers Analytics Engine](https://developers.cloudflare.com/analytics/analytics-engine/) - Store analytics data

 Generally, this configuration will do the following

**Control center**
 1. Create R2 bucket origin for the CDN.
 2. Enable public access to the R2 bucket with a custom DNS name.
 3. Create response header transform rules.

**Radar**
 1. Create a worker with a binding for Analytics Engine which will provide an API for data collecting.
 1. Create a worker.


## [Limitations](#control-center-on-cloudflare)

 1. All [used services](#description) should be owned by the same account.
 2. [Remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/remote) for Terraform is not implemented yet and state will be stored locally.


## [Costs](#control-center-on-cloudflare)

 [Our Plans | Pricing | Cloudflare](https://www.cloudflare.com/plans/)

 | Resource                                                                            | Price                     | Costs   | Comment                                 |
 | ----------------------------------------------------------------------------------- | ------------------------- | ------- | --------------------------------------- |
 | [Cloudflare DNS](https://www.cloudflare.com/plans/)                                 | `0.00 $/m`                | `-`     | Free plan                               |
 | [Cloudflare CDN](https://www.cloudflare.com/plans/)                                 | `0.00 $/m`                | `-`     | Free plan                               |
 | [Cloudflare Rules](https://www.cloudflare.com/plans/)                               | `0.00 $/rule/m`           | `-`     | Free plan - 10 rules                    |
 | [Cloudflare R2 - Class B Operations](https://developers.cloudflare.com/r2/pricing/) | `0.36 $/million requests` | `-`     | Free tier - 10 million requests / month |
 | [Cloudflare R2 - Data Retrieval](https://developers.cloudflare.com/r2/pricing/)     | `0.00 $/GB`               | `-`     |                                         |
 | [Cloudflare Workers](https://developers.cloudflare.com/workers/platform/pricing/)   | `$5.00 + 0.30 $/million`  | `-`     | Free plan - 100,000 per day             |
 | TOTAL                                                                               |                           | `0 $/m` |                                         |

 Run **1 control center** and **1 radar** may cost ~ **0 $/m**

 > [!NOTE]
 > Provided costs are very approximate because free tier/plan may not cover a high load for a long period of time.


## [Requirements](#control-center-on-cloudflare)

 In order to proceed with this deployment, we need
 1. [Registered Internet domain name](https://en.wikipedia.org/wiki/Domain_registration) added into account or [purchased directly on Cloudflare](https://developers.cloudflare.com/registrar/get-started/register-domain/) for control center and optional for radar.
 2. Linux host with [Terraform](https://developer.hashicorp.com/terraform/install) installed.
 3. Cloudflare [API token](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/) with the following access permissions

    **Control center**
    ```
    Account - <specific account>
      Workers R2 Storage - Edit
      Account Settings   - Read

    Zone - <specific zone>
      Transform Rules - Edit
    ```
    **Radar**
    ```
    Account - <specific account>
      Workers Builds Configuration - Edit
      Account Analytics - Read
      Workers Scripts - Edit
      Account Settings - Read
    ```


## [Deployment](#control-center-on-cloudflare)

 1. Get Terraform code from GitHub repository
    ```shell
    git clone https://github.com/p2p-way/p2p-agent-infra

    cd p2p-agent-infra/terraform/cloudflare
    ```

 2. Configure input data for deployment in *variables.auto.tfvars* file
    ```shell
    vi variables.auto.tfvars
    ```
    **Common**
      - `account_name` - should be set when user has a ccess to multple Cloudflare accounts

    **Control center**
      - `cc_domain_name` - zone name you would like to use for control center
      - `cc_name` - name used for control center resources
      - `cc_prefix` - set a custom prefix to not rely on a generated one
      - `cc_uri` - where to add a random URI the the control center
      - `cc_commands` - commands returned by control center

    **Radar**
      - `radar_domain_name` - zone name you would like to use for radar
      - `radar_name` - name used for radar resources
      - `radar_prefix` - set a custom prefix to not rely on a generated one
      - `radar_auth` - where to enable authentication on radar

    Pleasee check [Known issues](#known-issues) for more information.

 3. Enable Analitycs Engine
    - Dashboard --> Storage & databases --> Analytics Engine --> Enable

 4. Authenticate on Cloudflare
    ```shell
    export CLOUDFLARE_API_TOKEN="<api token>"
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

 After some period of time all resources will be created and will be ready to use.

 We could check deployed services

 **Control center**
 ```shell
 curl control_center_url -sI | grep cc- --color
 ```

 **Radar**
 ```shell
 curl "radar_url?\
 cloud=aws&\
 region=eu-central-1&\
 autoscaler=true&\
 services=ipfs%20radicle%20ton%20torrent&\
 auth=auth"
```


## [Cleanup](#control-center-on-cloudflare)

 In order to cleanup all created resources we should use the following steps
 1. Cleanup resources created by Terraform
    ```shell
    terraform destroy
    ```


## [Known issues](#control-center-on-cloudflare)

 1. We can't deploy more than one control center per zone using current approach
    - [cloudflare_ruleset not working #5247](https://github.com/cloudflare/terraform-provider-cloudflare/issues/5247)
    - ['zone' is not a valid value for kind because exceeded maximum number of │ zone rulesets for phase http_ratelimit (20217) #3444](https://github.com/cloudflare/terraform-provider-cloudflare/issues/3444)

 2. It was observed, that sometimes DNS name assignment take some time and control center and radar migth not be ready immediately after Terraform run.

 3. Terraform output `radar_url` might not be accurate when we add/remove a custom domain and it might be required to run apply one more time to get latest data.

 5. When we set a `radar_domain_name = domain.tld`, our hostname will be publicly known, due to [Certificate Transparency Monitoring](https://developers.cloudflare.com/ssl/edge-certificates/additional-options/certificate-transparency-monitoring/) and we might get unwanted traffic on it. So, a default `radar_auth = true` is helpfull and we also could not assign a custom main name to keep endpoint name private.
