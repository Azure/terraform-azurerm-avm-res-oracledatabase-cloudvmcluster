<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module in its simplest form.

```hcl
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
  ssh_public_keys                 = tls_private_key.generated_ssh_key.public_key_openssh
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
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9.2)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 1.14.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.74)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azapi_resource.ssh_public_key](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) (resource)
- [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) (resource)
- [tls_private_key.generated_ssh_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) (resource)
- [azapi_resource_list.listDbServersByPrimaryCloudExadataInfrastructure](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource_list) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_avm_odaa_infra"></a> [avm\_odaa\_infra](#module\_avm\_odaa\_infra)

Source: ../../../avm-odaa-infra/

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: ~> 0.3

### <a name="module_odaa_vnet"></a> [odaa\_vnet](#module\_odaa\_vnet)

Source: Azure/avm-res-network-virtualnetwork/azurerm

Version: 0.4.0

### <a name="module_test_default"></a> [test\_default](#module\_test\_default)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->