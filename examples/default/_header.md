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
