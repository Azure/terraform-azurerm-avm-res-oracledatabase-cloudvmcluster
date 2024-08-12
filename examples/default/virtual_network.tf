
module "odaa_vnet" {
  source        = "Azure/avm-res-network-virtualnetwork/azurerm"
  version       = "0.4.0"
  name          = "vnet-odaa"
  location      = local.location
  address_space = ["10.0.0.0/16"]

  subnets = {
    snet-odaa = {
      name             = "snet-odaa"
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


  #interfaces
  tags                = local.tags
  resource_group_name = azurerm_resource_group.this.name
}
