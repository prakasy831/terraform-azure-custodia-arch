module "c2c_vnet" {
  source              = "./modules/vnet"
  vnet_name           = "C2C-VNET"
  address_space       = "10.200.64.0/19"
  location            = azurerm_resource_group.bns_rg.location
  resource_group_name = azurerm_resource_group.bns_rg.name

  subnets = {
    "c2c-app-subnet"  = "10.200.64.0/24"
    "c2c-db-subnet"   = "10.200.65.0/24"
  }
}

module "cc1_vnet" {
  source              = "./modules/vnet"
  vnet_name           = "CC1-VNET"
  address_space       = "10.200.96.0/19"
  location            = azurerm_resource_group.bns_rg.location
  resource_group_name = azurerm_resource_group.bns_rg.name

  subnets = {
    "cc1-app-subnet"  = "10.200.96.0/24"
    "cc1-db-subnet"   = "10.200.97.0/24"
  }
}

