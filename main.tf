#-------------VMCluster resources ------------
# OperationId: CloudVmClusters_CreateOrUpdate, CloudVmClusters_Get, CloudVmClusters_Delete
# PUT GET DELETE /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Oracle.Database/cloudVmClusters/{cloudvmclustername}
resource "azapi_resource" "odaa_vm_cluster" {
  name      = var.cluster_name
  parent_id = var.resource_group_id
  type      = "Oracle.Database/cloudVmClusters@2023-09-01"
  body = {
    "location" : var.location,
    "properties" : {
      "dataStorageSizeInTbs" : var.data_storage_size_in_tbs,
      "dbNodeStorageSizeInGbs" : var.dbnode_storage_size_in_gbs,
      "memorySizeInGbs" : var.memory_size_in_gbs,
      "timeZone" : var.time_zone,
      "hostname" : var.hostname,
      "domain" : var.domain,
      "cpuCoreCount" : var.cpu_core_count,
      "dataStoragePercentage" : var.data_storage_percentage,
      "isLocalBackupEnabled" : var.is_local_backup_enabled,
      "cloudExadataInfrastructureId" : var.cloud_exadata_infrastructure_id,
      "isSparseDiskgroupEnabled" : var.is_sparse_diskgroup_enabled,
      "sshPublicKeys" : var.ssh_public_keys,
      "licenseModel" : var.license_model,
      "vnetId" : var.vnet_id,
      "giVersion" : var.gi_version,
      "systemVersion" : var.system_version,

      "subnetId" : var.subnet_id,
      "backupSubnetCidr" : var.backup_subnet_cidr,
      "nsgCidrs" : var.nsg_cidrs,

      "scanListenerPortTcpSsl" : var.scan_listener_port_tcp_ssl,
      "scanListenerPortTcp" : var.scan_listener_port_tcp,
      "dataCollectionOptions" : {
        "isDiagnosticsEventsEnabled" : var.is_diagnostic_events_enabled,
        "isHealthMonitoringEnabled" : var.is_health_monitoring_enabled,
        "isIncidentLogsEnabled" : var.is_incident_logs_enabled
      },
      "displayName" : var.cluster_name,
      "dbServers" : local.db_servers_ocids
    }

  }
  response_export_values    = ["properties.ocid"]
  schema_validation_enabled = false

  timeouts {
    create = "24h"
    delete = "8h"
  }

  lifecycle {
    ignore_changes = [
      body.properties.giVersion,
      body.properties.hostname,
      body.properties.sshPublicKeys
    ]
  }
}
