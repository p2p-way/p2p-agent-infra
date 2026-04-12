import os
import time
import logging
import urllib.request
import json
import uuid
from google.cloud import compute_v1
from google.cloud import scheduler_v1
from google.protobuf import field_mask_pb2

logging.basicConfig(
    level=logging.INFO,
    format="%(message)s",
    force=True
)
log = logging.getLogger()

# Clients
instance_group_client = compute_v1.RegionInstanceGroupManagersClient()
autoscaler_client = compute_v1.RegionAutoscalersClient()
scheduler_client = scheduler_v1.CloudSchedulerClient()

# Variables
timeout = 3
cloud = os.environ["cloud"]
region = os.environ["region"]
project = os.environ["project"]
name = os.environ["name"]
cc_hosts = os.environ["cc_hosts"].split()
agent_name = os.environ["agent_name"]
agent_prefix = os.environ["agent_prefix"]
scheduler_name = os.environ["scheduler_name"]
scheduler_prefix = os.environ["scheduler_prefix"]


# def main_handler(request):
def main_handler(request):

    # Timing
    start_time = time.time()

    # Functions
    def log_searator():
        log.info("----------------")

    def show_variables():
        log_searator()
        log.info("# request \n %s", request)
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

    def get_autoscaler_name():
        # Request
        request = compute_v1.GetRegionInstanceGroupManagerRequest(
            instance_group_manager=agent_name,
            project=project,
            region=region
        )

        # Get
        autoscaler_config = instance_group_client.get(request=request)

        # Compute
        autoscaler_name = autoscaler_config.status.autoscaler.split("/")[-1]

        # Return
        return autoscaler_name

    def get_desired_capacity(autoscaler_name):
        # Request
        request = compute_v1.GetRegionAutoscalerRequest(
            autoscaler=autoscaler_name,
            project=project,
            region=region
        )

        # Get
        autoscaler_config = autoscaler_client.get(request=request)

        # Compute
        min_num_replicas = autoscaler_config.autoscaling_policy.min_num_replicas
        max_num_replicas = autoscaler_config.autoscaling_policy.max_num_replicas
        desired_capacity_current = min(min_num_replicas, max_num_replicas)

        # Return
        return desired_capacity_current

    def get_scheduler_expression(job_name):
        # Request
        request = scheduler_v1.GetJobRequest(name=job_name)

        # Get
        scheduler_config = scheduler_client.get_job(request=request)

        # Compute
        scheduler_expression_current = scheduler_config.schedule

        # Return
        return scheduler_expression_current

    def compute_scheduler_expression(expression):
        # Compute
        value = int(expression.split(" ", maxsplit=1)[0])
        units = expression.split(" ")[1]

        position = {
            "minutes": 0,
            "hours": 1,
            "days": 2
        }

        position = position[units]
        expression = []
        for e in range(5):
            if e < position:
                expression.insert(e, "0")
            elif e == position:
                expression.insert(e, f"*/{value}")
            else:
                expression.insert(e, "*")

        expression = ' '.join(expression)

        # Return
        return expression

    def update_autoscaler_apply(autoscaler_name, desired_capacity):
        # Request
        request = compute_v1.PatchRegionAutoscalerRequest(
            project=project,
            region=region,
            autoscaler=autoscaler_name,
            autoscaler_resource={
                "name": autoscaler_name,
                "autoscaling_policy": {
                    "min_num_replicas": desired_capacity,
                    "max_num_replicas": desired_capacity
                }
            }
        )

        # Update
        autoscaler_client.patch(request=request)

    def update_scheduler_apply(job_name, scheduler_expression):
        # Request
        update_request = scheduler_v1.UpdateJobRequest(
            job={
                "name": job_name,
                "schedule": scheduler_expression
            },
            update_mask=field_mask_pb2.FieldMask(paths=["schedule"])
        )

        # Update
        scheduler_client.update_job(request=update_request)

    def update_autoscaler(agent_commands):

        desired_capacity_cc = parse_desired_capacity(agent_commands)

        # Update autoscaler
        if isinstance(desired_capacity_cc, int):
            if desired_capacity_cc >= 0:

                autoscaler_name = get_autoscaler_name()

                desired_capacity_current = get_desired_capacity(
                    autoscaler_name)

                if desired_capacity_current != desired_capacity_cc:
                    log.info("Scaling agent instances: %s --> %s",
                             desired_capacity_current, desired_capacity_cc)

                    # Update
                    update_autoscaler_apply(
                        autoscaler_name, desired_capacity_cc)
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
            job_name = f"projects/{project}/locations/{region}/jobs/{scheduler_name}"

            scheduler_expression_cc = compute_scheduler_expression(
                scheduler_expression_cc)
            scheduler_expression_current = get_scheduler_expression(job_name)

            if scheduler_expression_current == scheduler_expression_cc:
                log.info("Skip scheduler expression update: %s --> %s",
                         scheduler_expression_current, scheduler_expression_cc)
            else:
                log.info("Update scheduler expression: %s --> %s",
                         scheduler_expression_current, scheduler_expression_cc)

                # Update
                update_scheduler_apply(job_name, scheduler_expression_cc)
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

    request_id = uuid.uuid4()
    now = time.strftime("%Y-%m-%d-%H:%M:%S", time.localtime())
    duration = f"{(time.time() - start_time) * 1000:.3f} msec"
    log.info("Run duration: %s", duration)

    log_searator()

    return {
        "statusCode": 200,
        "body": f"{name} in {region} region - {request_id} - {now} - {duration}\n"
    }
