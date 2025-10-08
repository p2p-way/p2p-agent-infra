# Providers
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine_scale_set {
      force_delete                  = true
      roll_instances_when_required  = true
      scale_to_zero_before_deletion = true
    }
  }
}

provider "azapi" {
}

provider "cloudinit" {
}

provider "random" {
}

provider "time" {
}

provider "tls" {
}
