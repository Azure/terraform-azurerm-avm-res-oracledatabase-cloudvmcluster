terraform {
  required_version = ">= 1.9.2"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.14.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}


# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# This is required for resource modules

resource "azurerm_resource_group" "this" {
  location = local.location
  name     = module.naming.resource_group.name_unique
  tags     = local.tags
}

locals {
  diagnostic_settings = {
    sentToLogAnalytics = {
      name                           = "sendToLogAnalytics"
      workspace_resource_id          = azurerm_log_analytics_workspace.this.id
      log_analytics_destination_type = "Dedicated"
      metric_categories              = ["AllMetrics"]
      log_groups                     = ["AllLogs"]

    }
  }
  enable_telemetry = true
  location         = "eastus"
  tags = {
    scenario         = "Default"
    project          = "Oracle Database @ Azure"
    createdby        = "ODAA Infra - AVM Module"
    delete           = "yes"
    deploy_timestamp = timestamp()
  }
  zone = "3"
}

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

#Log Analytics Workspace for Diagnostic Settings
resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.this.name
}


module "avm_odaa_infra" {
  source = "../../../avm-odaa-infra/"

  location                             = local.location
  name                                 = "odaa-infra-${random_string.suffix.result}"
  display_name                         = "odaa-infra-${random_string.suffix.result}"
  resource_group_id                    = azurerm_resource_group.this.id
  zone                                 = local.zone
  compute_count                        = 2
  storage_count                        = 3
  shape                                = "Exadata.X9M"
  maintenance_window_leadtime_in_weeks = 0
  maintenance_window_preference        = "NoPreference"
  maintenance_window_patching_mode     = "Rolling"

  tags             = local.tags
  enable_telemetry = local.enable_telemetry
}



data "azapi_resource_list" "listDbServersByPrimaryCloudExadataInfrastructure" {
  parent_id              = module.avm_odaa_infra.resource_id
  type                   = "Oracle.Database/cloudExadataInfrastructures/dbServers@2023-09-01"
  response_export_values = ["*"]
}
# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test_default" {
  source   = "../../"
  location = local.location

  resource_group_id               = azurerm_resource_group.this.id
  cloud_exadata_infrastructure_id = module.avm_odaa_infra.resource_id
  vnet_id                         = module.odaa_vnet.resource_id
  subnet_id                       = module.odaa_vnet.subnets.snet-odaa.resource_id
  ssh_public_keys                 = ["${tls_private_key.generated_ssh_key.public_key_openssh}"]
  db_servers = [
    jsondecode(data.azapi_resource_list.listDbServersByPrimaryCloudExadataInfrastructure
    .output).value[0].properties.ocid,
    jsondecode(data.azapi_resource_list.listDbServersByPrimaryCloudExadataInfrastructure
    .output).value[1].properties.ocid
  ]


  backup_subnet_cidr           = "172.17.5.0/24"
  cluster_name                 = "odaa-vmcl"
  display_name                 = "odaa vm cluster"
  data_storage_size_in_tbs     = 2
  dbnode_storage_size_in_gbs   = 120
  time_zone                    = "UTC"
  memory_size_in_gbs           = 1000
  hostname                     = "hostname-${random_string.suffix.result}"
  cpu_core_count               = 4
  data_storage_percentage      = 80
  is_local_backup_enabled      = false
  is_sparse_diskgroup_enabled  = false
  license_model                = "LicenseIncluded"
  gi_version                   = "19.0.0.0"
  is_diagnostic_events_enabled = false
  is_health_monitoring_enabled = false
  is_incident_logs_enabled     = false

  tags             = local.tags
  enable_telemetry = var.enable_telemetry
}
