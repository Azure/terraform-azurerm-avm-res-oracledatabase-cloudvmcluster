terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id                 = "ef2c2154-2d60-433c-a2d8-b947e184c3a7"
  resource_provider_registrations = "none"
}


locals {
  enable_telemetry = true #enable_telemetry is a variable that controls whether or not telemetry is enabled for the module.
  location         = "eastus"
  tags = {
    scenario  = "Default"
    project   = "Oracle Database @ Azure"
    createdby = "ODAA Infra - AVM Module"
    delete    = "yes"
  }
  zone = "3"
}


module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.3"
}


# Create a resource group
resource "azurerm_resource_group" "this" {
  location = local.location
  name     = module.naming.resource_group.name_unique
  tags     = local.tags
}


# Create a random string for the suffix
resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

##################### This is the SSH key generation
resource "tls_private_key" "generated_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azapi_resource" "ssh_public_key" {
  location  = local.location
  name      = "odaa_ssh_key"
  parent_id = azurerm_resource_group.this.id
  type      = "Microsoft.Compute/sshPublicKeys@2023-09-01"
  body = {
    properties = {
      publicKey = tls_private_key.generated_ssh_key.public_key_openssh
    }
  }
}

# This is the local file resource to store the private key
resource "local_file" "private_key" {
  filename = "${path.module}/id_rsa"
  content  = tls_private_key.generated_ssh_key.private_key_pem
}


##################### This is the VNET creation using the module
module "odaa_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.0"

  location      = local.location
  parent_id     = azurerm_resource_group.this.id
  address_space = ["10.0.0.0/16"]
  name          = "odaa-vnet"
  tags          = local.tags
}

module "odaa_subnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"
  version = "0.17.0"

  parent_id        = module.odaa_vnet.resource_id
  address_prefixes = ["10.0.0.0/24"]
  delegation = [{
    name = "ODAA"
    service_delegation = {
      name    = "Oracle.Database/networkAttachments"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }

  }]
  name = "odaa-snet"
}


##################### This is the ODAA Infrastructure creation using the module
module "avm_odaa_infra" {
  source  = "Azure/avm-res-oracledatabase-cloudexadatainfrastructure/azurerm"
  version = "0.3.0"

  compute_count                        = 2
  display_name                         = "odaa-infra-${random_string.suffix.result}"
  location                             = local.location
  name                                 = "odaa-infra-${random_string.suffix.result}"
  resource_group_id                    = azurerm_resource_group.this.id
  storage_count                        = 3
  zone                                 = local.zone
  enable_telemetry                     = local.enable_telemetry
  maintenance_window_leadtime_in_weeks = 0
  maintenance_window_patching_mode     = "Rolling"
  maintenance_window_preference        = "NoPreference"
  shape                                = "Exadata.X9M"
  tags                                 = local.tags
}

resource "time_sleep" "wait_5_min_after_deletion" {
  destroy_duration = "5m"

  depends_on = [module.avm_odaa_infra]
}


##################### This is the VMCluster creation using the local module
module "test_default" {
  source = "../../"

  cloud_exadata_infrastructure_id = module.avm_odaa_infra.resource_id
  cluster_name                    = "odaa-vmcl"
  cpu_core_count                  = 4
  data_storage_size_in_tbs        = 2
  dbnode_storage_size_in_gbs      = 120
  hostname                        = "hostname-${random_string.suffix.result}"
  location                        = local.location
  memory_size_in_gbs              = 60
  resource_group_id               = azurerm_resource_group.this.id
  ssh_public_keys                 = [tls_private_key.generated_ssh_key.public_key_openssh]
  subnet_id                       = module.odaa_subnet.resource_id
  vnet_id                         = module.odaa_vnet.resource_id
  backup_subnet_cidr              = "172.17.5.0/24"
  data_storage_percentage         = 80
  enable_telemetry                = local.enable_telemetry
  gi_version                      = "24.0.0.0"
  is_diagnostic_events_enabled    = true
  is_health_monitoring_enabled    = true
  is_incident_logs_enabled        = true
  is_local_backup_enabled         = false
  is_sparse_diskgroup_enabled     = false
  license_model                   = "LicenseIncluded"
  tags                            = local.tags
  time_zone                       = "UTC"

  depends_on = [
    module.avm_odaa_infra,
    module.odaa_vnet,
    azurerm_resource_group.this,
    time_sleep.wait_5_min_after_deletion
  ]
}
