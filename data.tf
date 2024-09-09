
data "azapi_resource_list" "list_dbservers_by_cloudexadata_infrastructure" {
  parent_id              = var.cloud_exadata_infrastructure_id
  type                   = "Oracle.Database/cloudExadataInfrastructures/dbServers@2023-09-01"
  response_export_values = ["*"]
}
