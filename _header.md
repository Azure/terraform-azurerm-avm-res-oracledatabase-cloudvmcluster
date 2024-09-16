
# avm-res-oracledatabase-cloudvmcluster

This repository contains a Terraform module for deploying Oracle Database Cloud VM Clusters using Azure Verified Modules (AVM). The module provisions scalable Oracle Cloud VM clusters in an enterprise-ready configuration on Microsoft Azure.

## Features

- **Automated Oracle VM Cluster Deployment**: Deploys Oracle Cloud VM Clusters.
- **Customizable Configuration**: Supports multiple configurations, including VM size, number of nodes, database version, and networking.
- **AVM Compliance**: Ensures compliance with Azure Verified Module standards.

## Prerequisites

- **Terraform** version 1.0 or higher
- **Azure CLI**
- Oracle Cloud subscription

## Usage

An example of using the module in a Terraform configuration:

```hcl
module "oracle_vm_cluster" {
  source = "github.com/sihbher/avm-res-oracledatabase-cloudvmcluster"

  resource_group_name = "example-resource-group"
  location            = "eastus"
  vm_cluster_name     = "example-vm-cluster"

  db_version = "19c"
  vm_size    = "Standard_D8s_v3"
  node_count = 2

  subnet_id = "/subscriptions/{subscription_id}/resourceGroups/{resource_group_name}/providers/Microsoft.Network/virtualNetworks/{vnet_name}/subnets/{subnet_name}"
}
```

## Inputs

| Name                                  | Type          | Default              | Description                                                                                      |
|---------------------------------------|---------------|----------------------|--------------------------------------------------------------------------------------------------|
| `backup_subnet_cidr`                  | string        | N/A                  | The backup subnet CIDR of the cluster.                                                           |
| `cloud_exadata_infrastructure_id`     | string        | N/A                  | The cloud Exadata infrastructure ID.                                                             |
| `cluster_name`                        | string        | N/A                  | The name of the VM Cluster. Must be 3-11 characters long, lowercase letters, numbers, and hyphens.|
| `cpu_core_count`                      | number        | N/A                  | The CPU core count of the cluster. Must be ≥ 4.                                                  |
| `data_storage_size_in_tbs`            | number        | N/A                  | The data storage size in TBs.                                                                    |
| `dbnode_storage_size_in_gbs`          | number        | N/A                  | The DB node storage size in GBs.                                                                 |
| `display_name`                        | string        | N/A                  | The display name of the cluster.                                                                 |
| `hostname`                            | string        | N/A                  | The hostname of the cluster.                                                                     |
| `location`                            | string        | N/A                  | Azure region where the resource should be deployed.                                               |
| `memory_size_in_gbs`                  | number        | N/A                  | The memory size in GBs.                                                                          |
| `resource_group_id`                   | string        | N/A                  | The resource group ID where the resources will be deployed.                                      |
| `ssh_public_keys`                     | list(string)  | N/A                  | The SSH public keys of the cluster.                                                              |
| `subnet_id`                           | string        | N/A                  | The subnet ID.                                                                                    |
| `vnet_id`                             | string        | N/A                  | The VNet ID.                                                                                     |
| `customer_managed_key`                | object        | null                 | Customer-managed key object with Key Vault and identity details.                                 |
| `data_storage_percentage`             | number        | 100                  | The data storage percentage of the cluster (0-100).                                               |
| `db_servers`                          | list(string)  | []                   | DB servers of the cluster. Defaults to Exadata Infrastructure DB servers if not specified.        |
| `diagnostic_settings`                 | map(object)   | {}                   | Diagnostic settings configuration for logs and metrics.                                          |
| `domain`                              | string        | null                 | The domain of the cluster.                                                                       |
| `enable_telemetry`                    | bool          | true                 | Controls telemetry collection.                                                                   |
| `gi_version`                          | string        | "19.0.0.0"           | The GI version of the cluster, must be in format `XX.XX.XX.XX`.                                  |
| `is_diagnostic_events_enabled`        | bool          | false                | Whether diagnostic events are enabled.                                                           |
| `is_health_monitoring_enabled`        | bool          | false                | Whether health monitoring is enabled.                                                            |
| `is_incident_logs_enabled`            | bool          | false                | Whether incident logs are enabled.                                                               |
| `is_local_backup_enabled`             | bool          | false                | Whether local backup is enabled.                                                                 |
| `is_sparse_diskgroup_enabled`         | bool          | false                | Whether the sparse diskgroup is enabled.                                                         |
| `license_model`                       | string        | "LicenseIncluded"    | The license model, must be either `LicenseIncluded` or `BringYourOwnLicense`.                    |
| `lock`                                | object        | null                 | Resource lock configuration for the cluster.                                                     |
| `managed_identities`                  | object        | {}                   | Managed identity configuration (system and user-assigned identities).                            |
| `nsg_cidrs`                           | set(object)   | null                 | Additional network security group ingress rules for the cluster.                                 |
| `private_endpoints`                   | map(object)   | {}                   | Private endpoints configuration for the cluster.                                                 |
| `private_endpoints_manage_dns_zone_group`| bool        | true                 | Controls whether DNS zone groups are managed by this module.                                     |
| `role_assignments`                    | map(object)   | {}                   | Role assignments configuration for the cluster.                                                  |
| `tags`                                | map(string)   | null                 | Optional tags for the resource.                                                                  |
| `time_zone`                           | string        | "UTC"                | Time zone of the cluster.                                                                        |

This table includes all relevant variables.

## Outputs

| Name            | Description                                |
|-----------------|--------------------------------------------|
| `vm_cluster_id` | The ID of the deployed Oracle VM cluster   |
| `public_ip`     | The public IP address of the VM cluster    |

## License

This project is licensed under the [MIT License](LICENSE).

## Contributing

We welcome contributions to improve this module. Ensure your contributions comply with AVM best practices and run pre-commit checks before submitting a pull request.
