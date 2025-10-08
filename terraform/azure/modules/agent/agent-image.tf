# Locals
locals {
  os_name_map = {
    ubuntu-22-04 = {
      offer        = "0001-com-ubuntu-server-jammy"
      sku_prefix   = "22_04-lts"
      amd64_suffix = "-gen2"
      arm64_suffix = "-arm64"
    },
    ubuntu-24-04 = {
      offer        = "ubuntu-24_04-lts"
      sku_prefix   = "server"
      amd64_suffix = ""
      arm64_suffix = "-arm64"
    },
    ubuntu = {
      offer        = "ubuntu-24_04-lts"
      sku_prefix   = "server"
      amd64_suffix = ""
      arm64_suffix = "-arm64"
    }
  }

  os_publisher_map = {
    ubuntu = "Canonical"
  }

  arm_series = ["Bps", "Bpts", "Bpls", "Dps", "Dpds", "Dpls", "Dplds", "Eps", "Epds"]

  # https://learn.microsoft.com/en-us/azure/virtual-machines/sizes
  # Bpsv2-series
  # Dpsv6-series, Dpsv5-series
  # Dpdsv5-series, Dpdsv6-series
  # Dplsv5-series, Dplsv6-series
  # Dpldsv5-series, Dpldsv6-series
  # Epsv5-series, Epdsv5-series

  os_name        = replace(var.os_name, ".", "-")
  os_arch_suffix = contains(local.arm_series, try(replace(var.sku, "/[[:alnum:]]+_([A-Za-z]+)[0-9]+([A-Za-z]+)_v([0-9]+)$/", "$1$2"), "")) ? "arm64_suffix" : "amd64_suffix"
  os_publisher   = lookup(local.os_publisher_map, element(split("-", var.os_name), 0))
  os_offer       = lookup(local.os_name_map, local.os_name)["offer"]
  os_sku         = "${lookup(local.os_name_map, local.os_name)["sku_prefix"]}${lookup(local.os_name_map, local.os_name)[local.os_arch_suffix]}"
  os_version     = "latest"
}
