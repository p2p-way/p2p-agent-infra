# Locals
locals {
  architecture_map = {
    "x86_64" = "amd64"
    "arm64"  = "arm64"
  }

  os_name_map = {
    "ubuntu-22.04" = "ubuntu/images/hvm-ssd*/ubuntu-*-22.04-${local.architecture}-server-*"
    "ubuntu-24.04" = "ubuntu/images/hvm-ssd*/ubuntu-*-24.04-${local.architecture}-server-*"
    ubuntu         = "ubuntu/images/hvm-ssd*/ubuntu-*-24.04-${local.architecture}-server-*"
  }

  os_owner_map = {
    ubuntu = "099720109477"
  }

  architecture = try(lookup(local.architecture_map, element(data.aws_ec2_instance_type.agent[0].supported_architectures, 0)), "")
  os_owner     = lookup(local.os_owner_map, element(split("-", var.os_name), 0))
  os_name      = lookup(local.os_name_map, var.os_name)
}

# Instance
data "aws_ec2_instance_type" "agent" {
  count = local.create ? 1 : 0

  instance_type = var.instance_type

  region = local.region
}

# AMI
data "aws_ami" "agent" {
  count = local.create ? 1 : 0

  most_recent = true
  owners      = [local.os_owner]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = [local.os_name]
  }

  region = local.region
}
