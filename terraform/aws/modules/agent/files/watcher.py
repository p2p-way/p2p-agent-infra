import os
import time
import logging
import urllib.request
import boto3
import json

logging.basicConfig(
    level=logging.INFO,
    format='%(message)s',
    force=True
)
log = logging.getLogger()

autoscaling = boto3.client("autoscaling")
events_scheduler = boto3.client("scheduler")

# Variables
timeout = 3
cloud = os.environ["cloud"]
region = os.environ["AWS_REGION"]
name = os.environ["AWS_LAMBDA_FUNCTION_NAME"]
cc_hosts = os.environ["cc_hosts"].split()
agent_name = os.environ["agent_name"]
agent_prefix = os.environ["agent_prefix"]
scheduler_name = os.environ["scheduler_name"]
scheduler_prefix = os.environ["scheduler_prefix"]
scheduler_group_name = os.environ["scheduler_group_name"]


def lambda_handler(event, context):

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

    def update_agent_autoscaler(agent_commands):
        # Check desired_capacity from CC
        desired_capacity = agent_commands.get("desired_capacity", "undefined")
        desired_capacity = desired_capacity.replace("'", "\"")
        try:
            desired_capacity = json.loads(desired_capacity)
            try:
                # int from json
                desired_capacity = int(desired_capacity)
            except TypeError:
                try:
                    # json
                    clouds = desired_capacity.get('all', -1)
                    cloud_all = desired_capacity.get(cloud, {}).get('all', -1)
                    cloud_region = desired_capacity.get(
                        cloud, {}).get(region, -1)
                    desired_capacity = cloud_region if (cloud_region >= 0) \
                        else cloud_all if cloud_all >= 0 \
                        else clouds
                except AttributeError:
                    log.info(
                        "Please check json format - can't get values from %s", desired_capacity)
                    desired_capacity = -1
        except TypeError:
            # int
            desired_capacity = int(desired_capacity)
        except json.decoder.JSONDecodeError:
            # undefined
            desired_capacity = agent_commands.get("desired_capacity")

        # Update autoscaler
        if desired_capacity not in ("", "-", "undefined") and desired_capacity >= 0:
            # Get autoscaler config
            autoscaler_config = autoscaling.describe_auto_scaling_groups(
                AutoScalingGroupNames=[
                    agent_name
                ]
            )

            # Update autoscaler
            if (
                autoscaler_config["AutoScalingGroups"][0]["DesiredCapacity"]
                != desired_capacity
            ):
                log.info("Scaling agent instances to %s", desired_capacity)
                autoscaling.update_auto_scaling_group(
                    AutoScalingGroupName=agent_name,
                    DesiredCapacity=desired_capacity
                )
            else:
                log.info("Skip agent instances update - value is same")
        else:
            log.info(
                "Skip agent instances scaling - value is '%s'", desired_capacity)

        log_searator()

    def update_scheduler(scheduler_commands):
        # Check scheduler expression from CC
        expression = scheduler_commands.get("expression", "undefined")

        if expression not in ("", "-", "undefined"):
            # Get scheduler config
            scheduler_config = events_scheduler.get_schedule(
                GroupName=scheduler_group_name,
                Name=scheduler_name
            )

            # Update scheduler
            if scheduler_config["ScheduleExpression"] == expression:
                log.info("Skip scheduler expression update - value is same")
            else:
                log.info("Update scheduler expression to %s", expression)
                events_scheduler.update_schedule(
                    GroupName=scheduler_name,
                    Name=scheduler_name,
                    ScheduleExpression=expression,
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
                "Skip scheduler expression update - value is '%s'", expression)

        log_searator()

    # Run
    show_variables()

    agent_commands, scheduler_commands = contact_cc(cc_hosts)

    agent_commands = rename_headers(agent_commands, agent_prefix)

    scheduler_commands = rename_headers(scheduler_commands, scheduler_prefix)

    update_agent_autoscaler(agent_commands)

    update_scheduler(scheduler_commands)

    duration = f"{(time.time() - start_time) * 1000:.3f} msec"
    log.info("Run duration: %s", duration)

    log_searator()

    now = time.strftime("%Y-%m-%d-%H:%M:%S", time.localtime())

    return {
        "statusCode": 200,
        "body": f"{name} in {region} region - {context.aws_request_id} - {now} - {duration}\n"
    }
