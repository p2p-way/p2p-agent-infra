# Locals - Cloudinit
locals {
  # P2P agent
  agent_file_cloudinit = [{
    encoding = "b64"
    content = base64encode(templatefile("${path.root}/../common/files/${var.agent_file}", {
      base_folder        = var.agent_base_folder,
      log_file           = var.agent_log_file,
      commands           = var.agent_commands,
      commands_defaults  = var.agent_commands_defaults,
      cc_hosts           = var.agent_cc_hosts,
      cc_commands        = var.agent_cc_commands,
      cc_commands_prefix = var.agent_cc_commands_prefix
    }))
    path        = "${dirname(var.agent_base_folder)}/${var.agent_file}"
    owner       = "root:root"
    permissions = "0755"
  }]

  # P2P radar
  radar_url_file_cloudinit = length(var.radar_url) > 0 ? [{
    encoding = "b64"
    content = base64encode(templatefile("${path.root}/../common/files/${var.radar_url_file}", {
      base_folder = dirname(var.agent_base_folder),
      radar_url   = var.radar_url
    }))
    path        = "${dirname(var.agent_base_folder)}/${var.radar_url_file}"
    owner       = "root:root"
    permissions = "0600"
  }] : []

  # Agent logs
  agent_logs_cloudinit = local.agent_logs ? [{
    encoding = "b64"
    content = base64encode(templatefile("${path.module}/files/cloudwatch-logs.json", {
      log_files = local.agent_log_files,
      log_group = try(aws_cloudwatch_log_group.agent[0].name, "")
    }))
    path        = "${dirname(var.agent_base_folder)}/cloudwatch-logs.json"
    owner       = "root:root"
    permissions = "0644"
  }] : []

  # Agent metrics
  agent_metrics_cloudinit = local.agent_metrics ? [{
    encoding = "b64"
    content = base64encode(templatefile("${path.module}/files/cloudwatch-metrics.json", {
      base_folder = var.agent_base_folder,
      log_file    = var.agent_log_file
    }))
    path        = "${dirname(var.agent_base_folder)}/cloudwatch-metrics.json"
    owner       = "root:root"
    permissions = "0644"
  }] : []
}
