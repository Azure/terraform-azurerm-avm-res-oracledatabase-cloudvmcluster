
# avm-res-oracledatabase-cloudvmcluster

This repository contains a Terraform module for deploying Oracle Database Cloud VM Clusters using Azure Verified Modules (AVM). The module provisions scalable Oracle Cloud VM clusters in an enterprise-ready configuration on Microsoft Azure.

## Known issues
- Destroying VMCluster: When running the destroy command, VMCluster takes longer than the API reports. As a result, Terraform attempts to destroy the Cloud Exadata Infrastructure, which fails because the VMCluster hasn’t been fully deleted yet.

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
  # Terraform Registry
  source  = "Azure/avm-res-oracledatabase-cloudvmcluster/azurerm"
  version = "0.1.3"

  # Github  
  # source  = "github.com/Azure/terraform-azurerm-avm-res-oracledatabase-cloudvmcluster" 

  # Configure the Cloud Infrastructure resource for the cluster
  cloud_exadata_infrastructure_id = "/subscriptions/{subscriptions_id}/resourceGroups/{resource_groups_name}/providers/Oracle.Database/cloudExadataInfrastructures/{cloudExadataInfrastructures_name}"

  # Fundamentals
  cluster_name      = "example-vm-cluster-name"
  location          = "eastus"
  hostname          = "example-vm-cluster-hostnameprefix"
  resource_group_id = "example-resource-group"
  ssh_public_keys   = "example_ssh_public_keys"

  # Virtual network settings
  vnet_id            = "/subscriptions/{subscription_id}/resourceGroups/{resource_group_name}/providers/Microsoft.Network/virtualNetworks/{vnet_name}"
  subnet_id          = "/subscriptions/{subscription_id}/resourceGroups/{resource_group_name}/providers/Microsoft.Network/virtualNetworks/{vnet_name}/subnets/{subnet_name}"
  backup_subnet_cidr = "172.17.5.0/24"

  # Compute configuration settings
  cpu_core_count     = 4
  memory_size_in_gbs = 60

  # Storage configuration
  data_storage_percentage    = 80
  data_storage_size_in_tbs   = 2
  dbnode_storage_size_in_gbs = 120
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
| `scan_listener_port_tcp`                           | number        | 1521                | The TCP Single Client Access Name (SCAN) port. The default port is 1521.                                                                        |
| `scan_listener_port_tcp_ssl`                           | number        | 2484                | The TCP Single Client Access Name (SCAN) port for SSL. The default port is 2484.                                                                        |
This table includes all relevant variables.

This table includes all relevant variables.

## Outputs

| Name            | Description                                |
|-----------------|--------------------------------------------|
| `resource` | This is the full output for the resource.   |
| `resource_id`     | Resource ID of the ODAA VM Cluster    |
| `vm_cluster_ocid` | Value of the OCID of the ODAA VM Cluster |

## License

This project is licensed under the [MIT License](LICENSE).

## Contributing

We welcome contributions to improve this module. Ensure your contributions comply with AVM best practices and run pre-commit checks before submitting a pull request.
