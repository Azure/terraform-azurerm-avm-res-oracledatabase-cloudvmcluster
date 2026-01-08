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
  customerContacts = [
    { email = "your@email.here" }
  ]
  exadbInfra_id     = module.exadbInfra.resource_id
  location          = "uksouth"
  resource_group_id = azapi_resource.rg.id
  rg_name           = "rg-avm-example"
  ssh_public_keys = [
    file("path_of_your_ssh_public_key")
  ]
  subnet_id = "${azapi_resource.vnetOdb.id}/subnets/${azapi_resource.vnetOdb.body.properties.subnets[0].name}"
  tags = {
    scenario  = "X11M with custom maintenance and file system configuration"
    project   = "Oracle Database @ Azure"
    createdby = "ODAA Infra - AVM Module"
    delete    = "yes"
  }
  vnet_id   = azapi_resource.vnetOdb.id
  vnet_name = "vn-odb-example"
  zone      = 1
}

# Create Resource Group
resource "azapi_resource" "rg" {
  location                  = local.location
  name                      = local.rg_name
  type                      = "Microsoft.Resources/resourceGroups@2025-04-01"
  ignore_null_property      = false
  schema_validation_enabled = true
  tags                      = local.tags
}

resource "azapi_resource" "vnetOdb" {
  location  = local.location
  name      = local.vnet_name
  parent_id = azapi_resource.rg.id
  type      = "Microsoft.Network/virtualNetworks@2024-07-01"
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
  tags                      = local.tags
}

module "exadbInfra" {
  source  = "Azure/avm-res-oracledatabase-cloudexadatainfrastructure/azurerm"
  version = "0.3.0"

  # Configuration
  compute_count = 2
  display_name  = "ofake-exa-infra-avm-01"
  # Basics
  location          = local.location
  name              = "ofake-exa-infra-avm-01"
  resource_group_id = local.resource_group_id
  storage_count     = 3
  zone              = local.zone
  # maintenance_window
  customer_contacts = local.customerContacts
  # AVM specific
  enable_telemetry = false
  # maintenance_window_leadtime_in_weeks = 2
  maintenance_window_patching_mode = "NonRolling"
  maintenance_window_preference    = "NoPreference"
  shape                            = "Exadata.X11M"
  # Azure resource management
  tags = local.tags
}

module "exadbVmc" {
  # Terraform Registry
  source  = "Azure/avm-res-oracledatabase-cloudvmcluster/azurerm"
  version = "0.3.0"

  # Configure the Cloud Infrastructure resource for the cluster
  cloud_exadata_infrastructure_id = local.exadbInfra_id
  # Fundamentals
  cluster_name = "ofake-vmc01"
  # Compute configuration settings
  cpu_core_count             = 16
  data_storage_size_in_tbs   = 2
  dbnode_storage_size_in_gbs = 120
  hostname                   = "vmc"
  location                   = local.location
  memory_size_in_gbs         = 60
  resource_group_id          = local.resource_group_id
  ssh_public_keys            = local.ssh_public_keys
  subnet_id                  = local.subnet_id
  # Virtual network settings
  vnet_id = local.vnet_id
  # Storage configuration
  data_storage_percentage = 80
  enable_telemetry        = false
  # Azure resource management
  tags = local.tags

  depends_on = [module.exadbInfra, azapi_resource.vnetOdb]
}
