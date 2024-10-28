<!-- BEGIN_TF_DOCS -->

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

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9.2)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 1.14.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.116.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azapi_resource.odaa_vm_cluster](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azapi_resource_list.list_dbservers_by_cloudexadata_infrastructure](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource_list) (data source)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_backup_subnet_cidr"></a> [backup\_subnet\_cidr](#input\_backup\_subnet\_cidr)

Description: The backup subnet CIDR of the cluster.

Type: `string`

### <a name="input_cloud_exadata_infrastructure_id"></a> [cloud\_exadata\_infrastructure\_id](#input\_cloud\_exadata\_infrastructure\_id)

Description: The cloud Exadata infrastructure ID.

Type: `string`

### <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name)

Description: The name of the the VM Cluster.

Type: `string`

### <a name="input_cpu_core_count"></a> [cpu\_core\_count](#input\_cpu\_core\_count)

Description: The CPU core count of the cluster.

Type: `number`

### <a name="input_data_storage_size_in_tbs"></a> [data\_storage\_size\_in\_tbs](#input\_data\_storage\_size\_in\_tbs)

Description: The data storage size in TBs.

Type: `number`

### <a name="input_dbnode_storage_size_in_gbs"></a> [dbnode\_storage\_size\_in\_gbs](#input\_dbnode\_storage\_size\_in\_gbs)

Description: The DB node storage size in GBs.

Type: `number`

### <a name="input_hostname"></a> [hostname](#input\_hostname)

Description: The hostname of the cluster.

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_memory_size_in_gbs"></a> [memory\_size\_in\_gbs](#input\_memory\_size\_in\_gbs)

Description: The memory size in GBs.

Type: `number`

### <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id)

Description: The resource group ID where the resources will be deployed.

Type: `string`

### <a name="input_ssh_public_keys"></a> [ssh\_public\_keys](#input\_ssh\_public\_keys)

Description: The SSH public keys of the cluster.

Type: `list(string)`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: The subnet ID.

Type: `string`

### <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id)

Description: The VNet ID.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key)

Description: A map describing customer-managed keys to associate with the resource. This includes the following properties:
- `key_vault_resource_id` - The resource ID of the Key Vault where the key is stored.
- `key_name` - The name of the key.
- `key_version` - (Optional) The version of the key. If not specified, the latest version is used.
- `user_assigned_identity` - (Optional) An object representing a user-assigned identity with the following properties:
  - `resource_id` - The resource ID of the user-assigned identity.

Type:

```hcl
object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
```

Default: `null`

### <a name="input_data_storage_percentage"></a> [data\_storage\_percentage](#input\_data\_storage\_percentage)

Description: The data storage percentage of the cluster.

Type: `number`

Default: `100`

### <a name="input_db_servers"></a> [db\_servers](#input\_db\_servers)

Description: DB servers of the cluster, if not specified, the default DB servers from the Exadata Infrastructure will be used.

Type: `list(string)`

Default: `[]`

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description: A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.

Type:

```hcl
map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_domain"></a> [domain](#input\_domain)

Description: The domain of the cluster.

Type: `string`

Default: `null`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_gi_version"></a> [gi\_version](#input\_gi\_version)

Description: The GI version of the cluster.

Type: `string`

Default: `"19.0.0.0"`

### <a name="input_is_diagnostic_events_enabled"></a> [is\_diagnostic\_events\_enabled](#input\_is\_diagnostic\_events\_enabled)

Description: The diagnostic events enabled status of the cluster.

Type: `bool`

Default: `false`

### <a name="input_is_health_monitoring_enabled"></a> [is\_health\_monitoring\_enabled](#input\_is\_health\_monitoring\_enabled)

Description: The health monitoring enabled status of the cluster.

Type: `bool`

Default: `false`

### <a name="input_is_incident_logs_enabled"></a> [is\_incident\_logs\_enabled](#input\_is\_incident\_logs\_enabled)

Description: The incident logs enabled status of the cluster.

Type: `bool`

Default: `false`

### <a name="input_is_local_backup_enabled"></a> [is\_local\_backup\_enabled](#input\_is\_local\_backup\_enabled)

Description: The local backup enabled status of the cluster.

Type: `bool`

Default: `false`

### <a name="input_is_sparse_diskgroup_enabled"></a> [is\_sparse\_diskgroup\_enabled](#input\_is\_sparse\_diskgroup\_enabled)

Description: The sparse diskgroup enabled status of the cluster.

Type: `bool`

Default: `false`

### <a name="input_license_model"></a> [license\_model](#input\_license\_model)

Description: The license model of the cluster.

Type: `string`

Default: `"LicenseIncluded"`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description: Controls the Managed Identity configuration on this resource. The following properties can be specified:

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_nsg_cidrs"></a> [nsg\_cidrs](#input\_nsg\_cidrs)

Description: Add additional Network ingress rules for the network security group of the VM cluster:

 - `source` - The source IP address range.
 - `destination_port_range` - The destination port range. The following properties can be specified:
   - `min` - The minimum port number.
   - `max` - The maximum port number.  
 example:  
 nsg\_cidrs = [{  
     source = 0.0.0.0/0  
     destination\_port\_range = {  
         min = "1521"  
         max = "1522"
       }
   }]  

Type:

```hcl
set(object({
    source = string
    destination_port_range = object({
      min = string
      max = string
    })
  }))
```

Default: `null`

### <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints)

Description:   A map of private endpoints to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `name` - (Optional) The name of the private endpoint. One will be generated if not set.
  - `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
    - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
    - `principal_id` - The ID of the principal to assign the role to.
    - `description` - (Optional) The description of the role assignment.
    - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
    - `condition` - (Optional) The condition which will be used to scope the role assignment.
    - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
    - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
    - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.
  - `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
    - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
    - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  - `tags` - (Optional) A mapping of tags to assign to the private endpoint.
  - `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
  - `subresource_name` - The name of the sub resource for the private endpoint.
  - `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
  - `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
  - `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
  - `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
  - `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
  - `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of the Key Vault.
  - `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
    - `name` - The name of the IP configuration.
    - `private_ip_address` - The private IP address of the IP configuration.

Type:

```hcl
map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    subresource_name                        = string # NOTE: `subresource_name` can be excluded if the resource does not support multiple sub resource types (e.g. storage account supports blob, queue, etc)
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
```

Default: `{}`

### <a name="input_private_endpoints_manage_dns_zone_group"></a> [private\_endpoints\_manage\_dns\_zone\_group](#input\_private\_endpoints\_manage\_dns\_zone\_group)

Description: Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy.

Type: `bool`

Default: `true`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_scan_listener_port_tcp"></a> [scan\_listener\_port\_tcp](#input\_scan\_listener\_port\_tcp)

Description: The TCP Single Client Access Name (SCAN) port. The default port is 1521.

Type: `number`

Default: `1521`

### <a name="input_scan_listener_port_tcp_ssl"></a> [scan\_listener\_port\_tcp\_ssl](#input\_scan\_listener\_port\_tcp\_ssl)

Description: The TCP Single Client Access Name (SCAN) port for SSL. The default port is 2484.

Type: `number`

Default: `2484`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_time_zone"></a> [time\_zone](#input\_time\_zone)

Description: The time zone of the cluster.

Type: `string`

Default: `"UTC"`

## Outputs

The following outputs are exported:

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: Resource ID of the ODAA VM Cluster

### <a name="output_vm_cluster_ocid"></a> [vm\_cluster\_ocid](#output\_vm\_cluster\_ocid)

Description: Value of the OCID of the ODAA VM Cluster


## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->