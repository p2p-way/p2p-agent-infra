# Virtual machine scale set
resource "azurerm_linux_virtual_machine_scale_set" "agent" {
  count = local.create ? 1 : 0

  # Project details
  resource_group_name = azurerm_resource_group.agent[count.index].name
  location            = local.region

  # Scale set details
  name                 = local.resource_name
  computer_name_prefix = "${local.resource_name}-"
  zones                = var.zone

  # Instance details
  sku = var.sku

  source_image_reference {
    publisher = local.os_publisher
    offer     = local.os_offer
    sku       = local.os_sku
    version   = local.os_version
  }

  # Administrator account
  admin_username = local.admin_username

  dynamic "admin_ssh_key" {
    for_each = var.public_keys
    content {
      username   = local.admin_username
      public_key = admin_ssh_key.value
    }
  }

  # OS disk
  os_disk {
    disk_size_gb         = var.os_disk_size_gb == null ? null : var.os_disk_size_gb
    storage_account_type = var.os_storage_account_type
    caching              = var.os_caching
  }

  # Network interface
  network_interface {
    name                      = local.resource_name
    primary                   = true
    network_security_group_id = azurerm_network_security_group.agent[count.index].id

    ip_configuration {
      name      = local.resource_name
      primary   = true
      subnet_id = azurerm_virtual_network.agent[count.index].subnet.*.id[0]
      public_ip_address {
        name = local.resource_name
      }
    }
  }

  # Scaling
  instances = var.initial_deploy ? 0 : var.desired_capacity

  # Monitoring
  boot_diagnostics {
    storage_account_uri = null
  }

  # Health
  extension {
    name                       = "ssh-tcp-check"
    publisher                  = "Microsoft.ManagedServices"
    type                       = "ApplicationHealthLinux"
    type_handler_version       = "2.0"
    automatic_upgrade_enabled  = false
    auto_upgrade_minor_version = true
    settings = jsonencode({
      "protocol"          = "tcp",
      "port"              = 22,
      "intervalInSeconds" = 10,
      "numberOfProbes"    = 3,
      "gracePeriod"       = 60
    })
  }

  # Identity
  dynamic "identity" {
    for_each = local.agent_iam_create ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  automatic_instance_repair {
    enabled      = true
    grace_period = "PT10M"
    action       = "Replace"
  }

  # Allocation policy
  zone_balance = length(var.zone) > 1 ? true : false

  # User data
  user_data = data.cloudinit_config.agent[count.index].rendered

  # Tags
  tags = merge(
    var.default_tags,
    {
      agent-watcher = "${local.agent_watcher}"
    }
  )
}
