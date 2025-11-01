# =======================
#  RESOURCE GROUP
# =======================
module "bns_rg" {
  source   = "./modules/resource_group"
  name     = "Test-Custodia-Tfm-new"
  location = "East US"
}

# =======================
#  INSIGHTS VNET
# =======================
module "insights_vnet" {
  source              = "./modules/vnet"
  vnet_name           = "Insights-VNet"
  address_space       = ["10.200.128.0/19"]
  location            = "East US"
  resource_group_name = module.bns_rg.name

  subnets = [
    { name = "frontend", address_prefix = "10.200.132.0/24" },
    { name = "backend",  address_prefix = "10.200.129.0/24" },
    { name = "mongo",    address_prefix = "10.200.131.0/24" },
    { name = "kafka",    address_prefix = "10.200.130.0/24" },
  ]
}

# =======================
#  C2C VNET
# =======================
module "c2c_vnet" {
  source              = "./modules/vnet"
  vnet_name           = "C2C-VNet"
  address_space       = ["10.200.64.0/19"]
  location            = "East US"
  resource_group_name = module.bns_rg.name

  subnets = [
    { name = "api",  address_prefix = "10.200.66.0/24" },
    { name = "web",  address_prefix = "10.200.68.0/24" },
    { name = "db",   address_prefix = "10.200.70.0/24" },
  ]
}

# =======================
#  CC1 VNET
# =======================
module "cc1_vnet" {
  source              = "./modules/vnet"
  vnet_name           = "CC1-VNet"
  address_space       = ["10.200.96.0/19"]
  location            = "East US"
  resource_group_name = module.bns_rg.name

  subnets = [
    { name = "backend", address_prefix = "10.200.97.0/24" },
    { name = "worker",  address_prefix = "10.200.98.0/24" },
    { name = "data",    address_prefix = "10.200.99.0/24" },
  ]
}

# =======================
#  EXPORT API VNET
# =======================
module "export_vnet" {
  source              = "./modules/vnet"
  vnet_name           = "ExportAPI-VNet"
  address_space       = ["10.200.160.0/19"]
  location            = "East US"
  resource_group_name = module.bns_rg.name

  subnets = [
    { name = "app",     address_prefix = "10.200.162.0/24" },
    { name = "gateway", address_prefix = "10.200.163.0/24" },
    { name = "db",      address_prefix = "10.200.164.0/24" },
  ]
}

# =======================
#  MGMT VNET
# =======================
module "mgmt_vnet" {
  source              = "./modules/vnet"
  vnet_name           = "Mgmt-VNet"
  address_space       = ["10.200.192.0/19"]
  location            = "East US"
  resource_group_name = module.bns_rg.name

  subnets = [
    { name = "bastion",   address_prefix = "10.200.194.0/24" },
    { name = "jumpbox",   address_prefix = "10.200.195.0/24" },
    { name = "monitor",   address_prefix = "10.200.196.0/24" },
  ]
}

