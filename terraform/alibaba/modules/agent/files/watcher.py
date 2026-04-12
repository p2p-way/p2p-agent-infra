import os
import time
import logging
import urllib.request
import json
import ast
from alibabacloud_ess20220222.client import Client as Ess20220222Client
from alibabacloud_ess20220222 import models as ess_20220222_models
from alibabacloud_fc20230330.client import Client as FC20230330Client
from alibabacloud_fc20230330 import models as fc20230330_models
from alibabacloud_credentials.client import Client as CredentialClient
from alibabacloud_tea_openapi import models as open_api_models
from alibabacloud_tea_util import models as util_models


logging.basicConfig(
    level=logging.INFO,
    format="%(message)s",
    force=True
)
log = logging.getLogger()

# Clients
runtime = util_models.RuntimeOptions(
    autoretry=True,
    max_attempts=3,
    read_timeout=3000,
    connect_timeout=3000
)

# Variables
timeout = 3
cloud = os.environ["cloud"]
region = os.environ["region"]
name = os.environ["FC_FUNCTION_NAME"]
cc_hosts = os.environ["cc_hosts"].split()
agent_name = os.environ["agent_name"]
agent_prefix = os.environ["agent_prefix"]
scheduler_name = os.environ["scheduler_name"]
scheduler_prefix = os.environ["scheduler_prefix"]
ess_endpoint = f"ess.{region}.aliyuncs.com"
fc_endpoint = f"{os.environ['account']}.{region}.fc.aliyuncs.com"


def main_handler(event, context):

    # Timing
    start_time = time.time()

    # Functions
    def log_searator():
        log.info("----------------")

    def show_variables():
        log_searator()
        log.info("# event \n %s", event)
        log.info("# context \n %s", context)
        log.info("# variables")
        for var in """
                    region cc_hosts agent_name agent_prefix scheduler_name scheduler_prefix
                """.split():
            log.info("%s: %s", var, globals()[var])
        log_searator()

    def contact_cc(hosts):
        # Contact control center
        for cc in hosts:
            log.info("Control center: %s", cc)

            # Get data from CC
            try:
                with urllib.request.urlopen(
                        urllib.request.Request(url=cc, method="HEAD"), timeout=timeout) as response:
                    headers = response.headers

            # Set headers from HTTPError in case of a non 200 code
            except urllib.error.HTTPError as err:
                if err.code not in [200]:
                    headers = err.headers

            # Lowercase response header names
            headers_lower = {k.lower(): v for k, v in headers.items()}

            # Get agent headers
            agent_commands = dict(
                filter(
                    lambda item: agent_prefix in item[0], headers_lower.items())
            )

            # Get scheduler header
            scheduler_commands = dict(
                filter(
                    lambda item: scheduler_prefix in item[0], headers_lower.items())
            )

            # Log values received from CC
            log.info(headers_lower)
            log.info("agent_commands: %s", agent_commands)
            log.info("scheduler_commands: %s", scheduler_commands)

            # Stop on first CC which returned headers
            if len(agent_commands) > 0:
                break

        log_searator()

        return agent_commands, scheduler_commands

    def rename_headers(commands, prefix):
        # Rename headers
        commands = {
            k.replace(prefix + "-", "").replace("-", "_"): v
            for k, v in commands.items()
        }

        # Log headers
        for k, v in commands.items():
            log.info("%s: %s", k, v)

        if commands != {}:
            log_searator()

        return commands

    def parse_desired_capacity(agent_commands):

        def check_undefined():
            desired_capacity_cc = agent_commands.get(
                "desired_capacity", "undefined")
            return desired_capacity_cc

        def check_int(value):
            try:
                value = int(value)
            except ValueError:
                value = -1
            return value

        def check_dict(desired_capacity_cc):
            try:
                clouds = check_int(
                    desired_capacity_cc.get("all", -1))
                cloud_all = check_int(
                    desired_capacity_cc.get(cloud, {}).get("all", -1))
                cloud_region = check_int(
                    desired_capacity_cc.get(cloud, {}).get(region, -1))
                desired_capacity_cc = cloud_region if cloud_region >= 0 \
                    else cloud_all if cloud_all >= 0 \
                    else clouds
            except AttributeError:
                desired_capacity_cc = check_undefined()
            return desired_capacity_cc

        # Check desired_capacity from CC
        desired_capacity_cc = check_undefined()

        # Check type
        if isinstance(desired_capacity_cc, int):
            # int
            desired_capacity_cc = int(desired_capacity_cc)
        elif isinstance(desired_capacity_cc, dict):
            # dict
            desired_capacity_cc = check_dict(desired_capacity_cc)
        elif isinstance(desired_capacity_cc, str):
            # str
            desired_capacity_cc = desired_capacity_cc.replace("'", '"')
            try:
                desired_capacity_cc = json.loads(desired_capacity_cc)
                try:
                    # int from json str
                    desired_capacity_cc = int(desired_capacity_cc)
                except TypeError:
                    # dict from json str
                    desired_capacity_cc = check_dict(desired_capacity_cc)
                except ValueError:
                    # undefined from json str
                    desired_capacity_cc = check_undefined()
            except json.decoder.JSONDecodeError:
                # undefined from str
                desired_capacity_cc = check_undefined()
        else:
            # undefined type
            desired_capacity_cc = "undefined"

        return desired_capacity_cc

    def create_cloud_service_client(service, endpoint):
        credential = CredentialClient()
        config = open_api_models.Config(
            credential=credential,
            endpoint=endpoint
        )
        return service(config)

    def get_desired_capacity(autoscaler_name):
        # Client
        autoscaling_client = create_cloud_service_client(
            Ess20220222Client, ess_endpoint)

        # Request
        describe_scaling_groups_request = ess_20220222_models.DescribeScalingGroupsRequest(
            region_id=region,
            scaling_group_name=autoscaler_name
        )

        # Get
        autoscaler_config = autoscaling_client.describe_scaling_groups_with_options(
            describe_scaling_groups_request, runtime)

        # Compute
        autoscaler_config = ast.literal_eval(str(autoscaler_config))
        desired_capacity_current = autoscaler_config["body"]["ScalingGroups"][0].get(
            "DesiredCapacity", 0)

        # Return
        return desired_capacity_current, autoscaler_config

    def get_scheduler_expression(function, scheduler):
        # Client
        scheduler_client = create_cloud_service_client(
            FC20230330Client, fc_endpoint)

        # Get
        scheduler_config = scheduler_client.get_trigger_with_options(
            function, scheduler, {}, runtime)

        # Compute
        scheduler_config = ast.literal_eval(str(scheduler_config))
        scheduler_expression_current = scheduler_config["body"]["triggerConfig"]
        scheduler_expression_current = json.loads(
            scheduler_expression_current)
        scheduler_expression_current = scheduler_expression_current["cronExpression"]

        # Return
        return scheduler_expression_current

    def compute_scheduler_expression(expression):
       # Compute
        value = int(
            expression.split(" ")[0])
        units = expression.split(" ")[
            1]
        multiplier = {
            "minutes": 1,
            "hours": 60,
            "days": 1440
        }
        minutes = value * multiplier[units]
        expression = f"@every {minutes}m"

        # Return
        return expression

    def update_autoscaler_apply(config, desired_capacity):
        # Client
        autoscaling_client = create_cloud_service_client(
            Ess20220222Client, ess_endpoint)

        # Request
        modify_scaling_group_request = ess_20220222_models.ModifyScalingGroupRequest(
            scaling_group_id=config["body"]["ScalingGroups"][0]["ScalingGroupId"],
            desired_capacity=desired_capacity
        )

        # Update
        autoscaling_client.modify_scaling_group_with_options(
            modify_scaling_group_request, runtime)

    def update_scheduler_apply(function, scheduler, expression):
        # Client
        scheduler_client = create_cloud_service_client(
            FC20230330Client, fc_endpoint)

        # Compute
        update_trigger_input = fc20230330_models.UpdateTriggerInput(
            trigger_config=f'{{"payload": "", "cronExpression": "{expression}","enable": true}}'
        )

        # Request
        update_trigger_request = fc20230330_models.UpdateTriggerRequest(
            body=update_trigger_input
        )

        # Update
        scheduler_client.update_trigger_with_options(
            function, scheduler, update_trigger_request, {}, runtime)

    def update_autoscaler(agent_commands):

        desired_capacity_cc = parse_desired_capacity(agent_commands)

        # Update autoscaler
        if isinstance(desired_capacity_cc, int):
            if desired_capacity_cc >= 0:
                desired_capacity_current, autoscaler_config = get_desired_capacity(
                    agent_name)

                if desired_capacity_current != desired_capacity_cc:
                    log.info("Scaling agent instances: %s --> %s",
                             desired_capacity_current, desired_capacity_cc)

                    # Update
                    update_autoscaler_apply(
                        autoscaler_config, desired_capacity_cc)
                else:
                    log.info("Skip agent instances update: %s --> %s",
                             desired_capacity_current, desired_capacity_cc)
            else:
                log.info("Skip agent instances scaling: '%s'",
                         desired_capacity_cc)
        else:
            log.info("Skip agent instances scaling: '%s'",
                     desired_capacity_cc)

        log_searator()

    def update_scheduler(scheduler_commands):
        scheduler_expression_cc = scheduler_commands.get(
            "expression", "undefined")

        # Update scheduler
        if scheduler_expression_cc not in ("", "-", "undefined"):

            scheduler_expression_cc = compute_scheduler_expression(
                scheduler_expression_cc)
            scheduler_expression_current = get_scheduler_expression(
                name, scheduler_name)

            if scheduler_expression_current == scheduler_expression_cc:
                log.info("Skip scheduler expression update: %s --> %s",
                         scheduler_expression_current, scheduler_expression_cc)
            else:
                log.info("Update scheduler expression: %s --> %s",
                         scheduler_expression_current, scheduler_expression_cc)

                # Update
                update_scheduler_apply(
                    name, scheduler_name, scheduler_expression_cc)
        else:
            log.info(
                "Skip scheduler expression update: '%s'", scheduler_expression_cc)

        log_searator()

    # Run
    show_variables()

    agent_commands, scheduler_commands = contact_cc(cc_hosts)

    agent_commands = rename_headers(agent_commands, agent_prefix)

    scheduler_commands = rename_headers(scheduler_commands, scheduler_prefix)

    update_autoscaler(agent_commands)

    update_scheduler(scheduler_commands)

    request_id = context.request_id
    now = time.strftime("%Y-%m-%d-%H:%M:%S", time.localtime())
    duration = f"{(time.time() - start_time) * 1000:.3f} msec"
    log.info("Run duration: %s", duration)

    log_searator()

    return {
        "statusCode": 200,
        "body": f"{name} in {region} region - {request_id} - {now} - {duration}\n"
    }
