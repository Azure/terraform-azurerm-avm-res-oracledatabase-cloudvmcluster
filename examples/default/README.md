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
      version = "~> 3.116.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
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
  version = "~> 0.3"
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
  type = "Microsoft.Compute/sshPublicKeys@2023-09-01"
  body = {
    properties = {
      publicKey = tls_private_key.generated_ssh_key.public_key_openssh
    }
  }
  location  = local.location
  name      = "odaa_ssh_key"
  parent_id = azurerm_resource_group.this.id
}

# This is the local file resource to store the private key
resource "local_file" "private_key" {
  filename = "${path.module}/id_rsa"
  content  = tls_private_key.generated_ssh_key.private_key_pem
}


##################### This is the VNET creation using the module
module "odaa_vnet" {
  source        = "Azure/avm-res-network-virtualnetwork/azurerm"
  version       = "0.4.0"
  name          = "odaa-vnet"
  location      = local.location
  address_space = ["10.0.0.0/16"]

  subnets = {
    snet-odaa = {
      name             = "odaa-snet"
      address_prefixes = ["10.0.0.0/24"]
      delegation = [{
        name = "ODAA"
        service_delegation = {
          name    = "Oracle.Database/networkAttachments"
          actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
        }

      }]
    }
  }
  tags                = local.tags
  resource_group_name = azurerm_resource_group.this.name
}

##################### This is the ODAA Infrastructure creation using the module
module "avm_odaa_infra" {
  source  = "Azure/avm-res-oracledatabase-cloudexadatainfrastructure/azurerm"
  version = "0.1.0"

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


##################### This is the VMCluster creation using the local module
module "test_default" {
  source   = "../../"
  location = local.location

  resource_group_id               = azurerm_resource_group.this.id
  cloud_exadata_infrastructure_id = module.avm_odaa_infra.resource_id
  vnet_id                         = module.odaa_vnet.resource_id
  subnet_id                       = module.odaa_vnet.subnets.snet-odaa.resource_id
  ssh_public_keys                 = [tls_private_key.generated_ssh_key.public_key_openssh]

  backup_subnet_cidr           = "172.17.5.0/24"
  cluster_name                 = "odaa-vmcl"
  display_name                 = "odaa vm cluster"
  data_storage_size_in_tbs     = 2
  dbnode_storage_size_in_gbs   = 120
  time_zone                    = "UTC"
  memory_size_in_gbs           = 60
  hostname                     = "hostname-${random_string.suffix.result}"
  cpu_core_count               = 4
  data_storage_percentage      = 80
  is_local_backup_enabled      = false
  is_sparse_diskgroup_enabled  = false
  license_model                = "LicenseIncluded"
  gi_version                   = "19.0.0.0"
  is_diagnostic_events_enabled = true
  is_health_monitoring_enabled = true
  is_incident_logs_enabled     = true

  tags             = local.tags
  enable_telemetry = local.enable_telemetry

  depends_on = [module.avm_odaa_infra, module.odaa_vnet, azurerm_resource_group.this]
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9.2)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 1.14.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.116.0)

- <a name="requirement_local"></a> [local](#requirement\_local) (2.5.1)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

- <a name="requirement_tls"></a> [tls](#requirement\_tls) (4.0.5)

## Resources

The following resources are used by this module:

- [azapi_resource.ssh_public_key](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/2.5.1/docs/resources/file) (resource)
- [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) (resource)
- [tls_private_key.generated_ssh_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.5/docs/resources/private_key) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

No optional inputs.

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_avm_odaa_infra"></a> [avm\_odaa\_infra](#module\_avm\_odaa\_infra)

Source: Azure/avm-res-oracledatabase-cloudexadatainfrastructure/azurerm

Version: 0.1.0

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