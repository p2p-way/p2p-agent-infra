import os
import time
import logging
import urllib.request
import boto3
import json

logging.basicConfig(
    level=logging.INFO,
    format="%(message)s",
    force=True
)
log = logging.getLogger()

autoscaling = boto3.client("autoscaling")
events_scheduler = boto3.client("scheduler")

# Variables
timeout = 3
cloud = os.environ["cloud"]
region = os.environ["region"]
name = os.environ["AWS_LAMBDA_FUNCTION_NAME"]
cc_hosts = os.environ["cc_hosts"].split()
agent_name = os.environ["agent_name"]
agent_prefix = os.environ["agent_prefix"]
scheduler_name = os.environ["scheduler_name"]
scheduler_prefix = os.environ["scheduler_prefix"]
scheduler_group_name = os.environ["scheduler_group_name"]


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
                    region cc_hosts agent_name agent_prefix scheduler_name scheduler_prefix scheduler_group_name
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

    def update_agent_autoscaler(agent_commands):

        desired_capacity_cc = parse_desired_capacity(agent_commands)

        # Update autoscaler
        if desired_capacity_cc not in ("", "-", "undefined") and isinstance(desired_capacity_cc, int):
            if desired_capacity_cc >= 0:
                # Get autoscaler config
                autoscaler_config = autoscaling.describe_auto_scaling_groups(
                    AutoScalingGroupNames=[
                        agent_name
                    ]
                )

                # Update autoscaler
                desired_capacity_current = autoscaler_config["AutoScalingGroups"][0]["DesiredCapacity"]
                if desired_capacity_current != desired_capacity_cc:
                    log.info("Scaling agent instances: %s --> %s",
                             desired_capacity_current, desired_capacity_cc)
                    autoscaling.update_auto_scaling_group(
                        AutoScalingGroupName=agent_name,
                        DesiredCapacity=desired_capacity_cc
                    )
                else:
                    log.info("Skip agent instances update: %s --> %s",
                             desired_capacity_current, desired_capacity_cc)
        else:
            log.info(
                "Skip agent instances scaling: '%s'", desired_capacity_cc)

        log_searator()

    def update_scheduler(scheduler_commands):
        # Check scheduler expression from CC
        scheduler_expression_cc = scheduler_commands.get(
            "expression", "undefined")

        if scheduler_expression_cc not in ("", "-", "undefined"):
            # Get scheduler config
            scheduler_config = events_scheduler.get_schedule(
                GroupName=scheduler_group_name,
                Name=scheduler_name
            )

            scheduler_expression_cc = f"rate({scheduler_expression_cc})"
            scheduler_expression_current = scheduler_config["ScheduleExpression"]

            # Update scheduler
            if scheduler_expression_current == scheduler_expression_cc:
                log.info("Skip scheduler expression update: %s --> %s",
                         scheduler_expression_current, scheduler_expression_cc)
            else:
                log.info("Update scheduler expression: %s --> %s",
                         scheduler_expression_current, scheduler_expression_cc)

                events_scheduler.update_schedule(
                    GroupName=scheduler_name,
                    Name=scheduler_name,
                    ScheduleExpression=scheduler_expression_cc,
                    Description=scheduler_config["Description"],
                    ActionAfterCompletion=scheduler_config["ActionAfterCompletion"],
                    ScheduleExpressionTimezone=scheduler_config[
                        "ScheduleExpressionTimezone"
                    ],
                    State=scheduler_config["State"],
                    FlexibleTimeWindow=scheduler_config["FlexibleTimeWindow"],
                    Target=scheduler_config["Target"],
                )
        else:
            log.info(
                "Skip scheduler expression update: '%s'", scheduler_expression_cc)

        log_searator()

    # Run
    show_variables()

    agent_commands, scheduler_commands = contact_cc(cc_hosts)

    agent_commands = rename_headers(agent_commands, agent_prefix)

    scheduler_commands = rename_headers(scheduler_commands, scheduler_prefix)

    update_agent_autoscaler(agent_commands)

    update_scheduler(scheduler_commands)

    request_id = context.aws_request_id
    now = time.strftime("%Y-%m-%d-%H:%M:%S", time.localtime())
    duration = f"{(time.time() - start_time) * 1000:.3f} msec"
    log.info("Run duration: %s", duration)

    log_searator()

    return {
        "statusCode": 200,
        "body": f"{name} in {region} region - {request_id} - {now} - {duration}\n"
    }
