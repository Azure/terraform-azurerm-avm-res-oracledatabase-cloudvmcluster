<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module in its simplest form. The example contains Terraform code to provision Oracle Database Cloud VM Clusters on Azure using Azure Verified Modules (AVM). It creates and configures a Virtual Network (VNet), generates SSH keys, provisions Oracle Cloud Exadata Infrastructure, and deploys a (VM) Cluster.

## Requirements

- **Terraform**: `>= 1.9.2`
- **Providers**:
  - `azapi` `~> 1.14.0`
  - `azurerm` `~> 3.116.0`
  - `local` `2.5.1`
  - `random` `~> 3.5`
  - `tls` `4.0.5`

## Features

- Automatically creates an Oracle Database Cloud VM Cluster in a defined Azure Resource Group.
- Generates secure SSH keys for cluster management.
- Sets up a VNet and subnet with Oracle Database-specific delegations.
- Includes telemetry support for monitoring.

## Usage

### Basic Example

```hcl
module "oracle_db_cluster" {
  source = "path_to_module"

  resource_group_id               = azurerm_resource_group.this.id
  location                        = "eastus"
  cloud_exadata_infrastructure_id = module.exadata_infra.resource_id
  vnet_id                         = module.odaa_vnet.resource_id
  subnet_id                       = module.odaa_vnet.subnets.snet-odaa.resource_id
  ssh_public_keys                 = [tls_private_key.generated_ssh_key.public_key_openssh]

  cluster_name               = "odaa-vmcl"
  data_storage_size_in_tbs   = 2
  dbnode_storage_size_in_gbs = 120
  memory_size_in_gbs         = 60
  cpu_core_count             = 4
  gi_version                 = "19.0.0.0"

  tags             = local.tags
  enable_telemetry = true
}
```

### SSH Key Generation

The module generates a 4096-bit RSA key pair for use in managing the Oracle VM Cluster:

```hcl
resource "tls_private_key" "generated_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
```

### Virtual Network Creation

A VNet is set up with a subnet specific to Oracle VM Cluster services:

```hcl
module "odaa_vnet" {
  source        = "Azure/avm-res-network-virtualnetwork/azurerm"
  version       = "0.4.0"
  name          = "odaa-vnet"
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

  resource_group_name = azurerm_resource_group.this.name
}
```

### Exadata Infrastructure and VM Cluster Setup

The module also provisions the Exadata infrastructure and the Oracle VM Cluster:

```hcl
module "avm_odaa_infra" {
  source  = "Azure/avm-res-oracledatabase-cloudexadatainfrastructure/azurerm"
  version = "0.1.0"

  name              = "odaa-infra-${random_string.suffix.result}"
  compute_count     = 2
  storage_count     = 3
  shape             = "Exadata.X9M"
  resource_group_id = azurerm_resource_group.this.id
  location          = local.location
}
```

## Input Variables

| Variable                            | Type         | Default               | Description                                                      |
|-------------------------------------|--------------|-----------------------|------------------------------------------------------------------|
| `location`                          | string       | `"eastus"`            | Azure region to deploy resources.                                |
| `resource_group_id`                 | string       | N/A                   | Resource group for the Oracle VM Cluster.                        |
| `cloud_exadata_infrastructure_id`    | string       | N/A                   | The Exadata infrastructure ID.                                   |
| `vnet_id`                           | string       | N/A                   | ID of the Virtual Network (VNet).                                |
| `subnet_id`                         | string       | N/A                   | ID of the subnet in the VNet.                                    |
| `cluster_name`                      | string       | `"odaa-vmcl"`         | Name of the Oracle VM Cluster.                                   |
| `cpu_core_count`                    | number       | 4                     | Number of CPU cores.                                             |
| `data_storage_size_in_tbs`          | number       | 2                     | Data storage size in terabytes.                                  |
| `memory_size_in_gbs`                | number       | 60                    | Memory size in gigabytes.                                        |
| `ssh_public_keys`                   | list(string) | N/A                   | SSH public key for accessing the cluster.                        |
| `backup_subnet_cidr`                | string       | `"172.17.5.0/24"`     | CIDR block for backup subnet.                                    |
| `license_model`                     | string       | `"LicenseIncluded"`   | License model for the VM Cluster. Options: `"LicenseIncluded"`, `"BringYourOwnLicense"`. |

## Output Variables

| Output         | Description                              |
|----------------|------------------------------------------|
| `cluster_id`   | The Oracle VM Cluster ID.                |
| `public_ip`    | The public IP address of the VM cluster. |

## Contributing

Contributions to this module are welcome. Please follow Terraform best practices and ensure the code is aligned with Azure Verified Module standards.

## License

This module is licensed under the [MIT License](LICENSE).

---

This `README.md` provides a detailed overview of the Terraform module, its usage, inputs, outputs, and how to generate SSH keys and set up Oracle Cloud VM Clusters. Let me know if you need further adjustments!

```hcl
terraform {
  required_version = ">= 1.9, < 2.0"
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
  version = "0.4.0"

  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  name                = "odaa-vnet"
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
  tags = local.tags
}

##################### This is the ODAA Infrastructure creation using the module
module "avm_odaa_infra" {
  source  = "Azure/avm-res-oracledatabase-cloudexadatainfrastructure/azurerm"
  version = "0.1.0"

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

  backup_subnet_cidr              = "172.17.5.0/24"
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
  subnet_id                       = module.odaa_vnet.subnets.snet-odaa.resource_id
  vnet_id                         = module.odaa_vnet.resource_id
  data_storage_percentage         = 80
  enable_telemetry                = local.enable_telemetry
  gi_version                      = "19.0.0.0"
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
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 1.14.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.116.0)

- <a name="requirement_local"></a> [local](#requirement\_local) (2.5.1)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

- <a name="requirement_time"></a> [time](#requirement\_time) (0.12.1)

- <a name="requirement_tls"></a> [tls](#requirement\_tls) (4.0.5)

## Resources

The following resources are used by this module:

- [azapi_resource.ssh_public_key](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/2.5.1/docs/resources/file) (resource)
- [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) (resource)
- [time_sleep.wait_5_min_after_deletion](https://registry.terraform.io/providers/hashicorp/time/0.12.1/docs/resources/sleep) (resource)
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