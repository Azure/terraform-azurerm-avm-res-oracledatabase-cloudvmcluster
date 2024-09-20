# TODO: insert locals here.
locals {
  db_servers_ocids = length(var.db_servers) == 0 ? local.exa_infra_db_servers_ocids : var.db_servers
  #Reads the default DBservers from the Exadata Infrastructure to be used in the VMCluster creation
  exa_infra_db_servers       = jsondecode(data.azapi_resource_list.list_dbservers_by_cloudexadata_infrastructure.output).value[*]
  exa_infra_db_servers_ocids = toset([for dbs in local.exa_infra_db_servers : dbs.properties.ocid])
}
