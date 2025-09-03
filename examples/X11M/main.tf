terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
  }
}

provider "azapi" {
}

locals {
  location          = "uksouth"
  zone              = 1
  rg_name           = "rg-avm-example"
  vnet_name         = "vn-odb-example"
  resource_group_id = azapi_resource.rg.id
  vnet_id           = azapi_resource.vnetOdb.id
  subnet_id         = "${azapi_resource.vnetOdb.id}/subnets/${azapi_resource.vnetOdb.body.properties.subnets[0].name}"
  exadbInfra_id     = module.exadbInfra.resource_id

  customerContacts = [
    { email = "your@email.here" }
  ]
  ssh_public_keys = [
    file("path_of_your_ssh_public_key")
  ]
  tags = {
    scenario  = "X11M with custom maintenance and file system configuration"
    project   = "Oracle Database @ Azure"
    createdby = "ODAA Infra - AVM Module"
    delete    = "yes"
  }
}

# Create Resource Group
resource "azapi_resource" "rg" {
  type                      = "Microsoft.Resources/resourceGroups@2025-04-01"
  location                  = local.location
  name                      = local.rg_name
  tags                      = local.tags
  ignore_null_property      = false
  schema_validation_enabled = true
}

resource "azapi_resource" "vnetOdb" {
  type      = "Microsoft.Network/virtualNetworks@2024-07-01"
  location  = local.location
  name      = local.vnet_name
  parent_id = azapi_resource.rg.id
  tags      = local.tags

  body = {
    properties = {
      addressSpace = {
        addressPrefixes = ["10.0.0.0/16"]
      }
      subnets = [{
        name = "odb"
        properties = {
          addressPrefixes = ["10.0.0.0/24"]
          delegations = [{
            name = "Oracle.Database/networkAttachments"
            properties = {
              serviceName = "Oracle.Database/networkAttachments"
            }
            type = "Microsoft.Network/virtualNetworks/subnets/delegations"
          }]
        }
        type = "Microsoft.Network/virtualNetworks/subnets"
      }]
    }
  }
  ignore_null_property      = false
  schema_validation_enabled = true
}

module "exadbInfra" {
  source  = "Azure/avm-res-oracledatabase-cloudexadatainfrastructure/azurerm"
  version = "0.1.1"

  # Basics
  location          = local.location
  zone              = local.zone
  name              = "ofake-exa-infra-avm-01"
  display_name      = "ofake-exa-infra-avm-01"
  resource_group_id = local.resource_group_id

  # Configuration
  compute_count = 2
  storage_count = 3
  shape         = "Exadata.X11M"

  # maintenance_window
  customerContacts = local.customerContacts

  maintenance_window_leadtime_in_weeks = 2
  maintenance_window_patching_mode     = "NonRolling"
  maintenance_window_preference        = "CustomPreference"
  maintenance_window_months = [{
    name = "February"
    }, {
    name = "May"
    }, {
    name = "August"
    }, {
    name = "January"
  }]
  maintenance_window_weeksOfMonth = [1]
  maintenance_window_daysOfWeek = [{
    name = "Monday"
  }]
  maintenance_window_hoursOfDay = [12]

  customActionTimeoutInMins    = 0
  isCustomActionTimeoutEnabled = false

  # Azure resource management
  tags = local.tags

  # AVM specific
  enable_telemetry = false
}

module "exadbVmc" {
  depends_on = [module.exadbInfra, azapi_resource.vnetOdb]
  # Terraform Registry
  source  = "Azure/avm-res-oracledatabase-cloudvmcluster/azurerm"
  version = "0.1.5"

  # Configure the Cloud Infrastructure resource for the cluster
  cloud_exadata_infrastructure_id = local.exadbInfra_id

  # Fundamentals
  cluster_name      = "ofake-vmc01"
  location          = local.location
  hostname          = "vmc"
  resource_group_id = local.resource_group_id
  ssh_public_keys   = local.ssh_public_keys

  # Virtual network settings
  vnet_id            = local.vnet_id
  subnet_id          = local.subnet_id
  backup_subnet_cidr = "192.168.252.0/22"

  # Compute configuration settings
  cpu_core_count     = 16
  memory_size_in_gbs = 60

  # Storage configuration
  data_storage_percentage    = 80
  data_storage_size_in_tbs   = 2
  dbnode_storage_size_in_gbs = 120

  # Local file systems configuration
  fileSystemConfigurationDetails = [{
    fileSystemSizeGb = 15
    mountPoint       = "/"
    }, {
    fileSystemSizeGb = 250
    mountPoint       = "/u01"
    }, {
    fileSystemSizeGb = 10
    mountPoint       = "/tmp"
    }, {
    fileSystemSizeGb = 10
    mountPoint       = "/var"
    }, {
    fileSystemSizeGb = 30
    mountPoint       = "/var/log"
    }, {
    fileSystemSizeGb = 4
    mountPoint       = "/home"
    }, {
    fileSystemSizeGb = 10
    mountPoint       = "/var/log/audit"
    }, {
    fileSystemSizeGb = 9
    mountPoint       = "reserved"
    }, {
    fileSystemSizeGb = 16
    mountPoint       = "swap"
  }]

  # Azure resource management
  tags             = local.tags
  enable_telemetry = false
}
