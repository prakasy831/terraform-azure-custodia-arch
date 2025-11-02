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
    { name = "backend", address_prefix = "10.200.129.0/24" },
    { name = "mongo", address_prefix = "10.200.131.0/24" },
    { name = "kafka", address_prefix = "10.200.130.0/24" },
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
    { name = "api", address_prefix = "10.200.66.0/24" },
    { name = "web", address_prefix = "10.200.68.0/24" },
    { name = "db", address_prefix = "10.200.70.0/24" },
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
    { name = "worker", address_prefix = "10.200.98.0/24" },
    { name = "data", address_prefix = "10.200.99.0/24" },
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
    { name = "app", address_prefix = "10.200.162.0/24" },
    { name = "gateway", address_prefix = "10.200.163.0/24" },
    { name = "db", address_prefix = "10.200.164.0/24" },
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
    { name = "AzureBastionSubnet", address_prefix = "10.200.194.0/24" },
    { name = "jumpbox", address_prefix = "10.200.195.0/24" },
    { name = "monitor", address_prefix = "10.200.196.0/24" },
  ]
}

# =======================
# NSGs
# =======================
module "c2c_web_nsg" {
  source              = "./modules/nsg"
  nsg_name            = "C2C-Web-NSG"
  location            = module.bns_rg.location
  resource_group_name = module.bns_rg.name
  subnet_id           = module.c2c_vnet.subnet_ids["web"]
}

#module "mgmt_bastion_nsg" {
# source              = "./modules/nsg"
#nsg_name            = "Mgmt-Bastion-NSG"
#location            = module.bns_rg.location
#resource_group_name = module.bns_rg.name
#subnet_id           = module.mgmt_vnet.subnet_ids["AzureBastionSubnet"]
#}

# =======================
# VNET PEERINGS
# =======================
module "peering_c2c_to_cc1" {
  source              = "./modules/peering"
  resource_group_name = module.bns_rg.name
  source_vnet_name    = module.c2c_vnet.vnet_name
  remote_vnet_name    = module.cc1_vnet.vnet_name
  remote_vnet_id      = module.cc1_vnet.vnet_id
}

module "peering_cc1_to_c2c" {
  source              = "./modules/peering"
  resource_group_name = module.bns_rg.name
  source_vnet_name    = module.cc1_vnet.vnet_name
  remote_vnet_name    = module.c2c_vnet.vnet_name
  remote_vnet_id      = module.c2c_vnet.vnet_id
}

module "peering_cc1_to_insights" {
  source              = "./modules/peering"
  resource_group_name = module.bns_rg.name
  source_vnet_name    = module.cc1_vnet.vnet_name
  remote_vnet_name    = module.insights_vnet.vnet_name
  remote_vnet_id      = module.insights_vnet.vnet_id
}

module "peering_insights_to_cc1" {
  source              = "./modules/peering"
  resource_group_name = module.bns_rg.name
  source_vnet_name    = module.insights_vnet.vnet_name
  remote_vnet_name    = module.cc1_vnet.vnet_name
  remote_vnet_id      = module.cc1_vnet.vnet_id
}

# =======================
# FIREWALL SUBNET
# =======================
resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = module.bns_rg.name
  virtual_network_name = module.mgmt_vnet.vnet_name
  address_prefixes     = ["10.200.197.0/26"]
}

# =======================
# FIREWALL POLICY
# =======================
module "firewall_policy" {
  source              = "./modules/firewall_policy"
  policy_name         = "Custodia-FW-Policy"
  location            = module.bns_rg.location
  resource_group_name = module.bns_rg.name
}

# =======================
# FIREWALL
# =======================
module "azure_firewall" {
  source              = "./modules/firewall"
  firewall_name       = "Custodia-Firewall"
  location            = module.bns_rg.location
  resource_group_name = module.bns_rg.name
  subnet_id           = azurerm_subnet.firewall_subnet.id
  firewall_policy_id  = module.firewall_policy.firewall_policy_id
}

# =======================
# FIREWALL ROUTE TABLE
# =======================
resource "azurerm_route_table" "firewall_routetable" {
  name                = "Custodia-FW-RT"
  location            = module.bns_rg.location
  resource_group_name = module.bns_rg.name
}

resource "azurerm_route" "default_route" {
  name                   = "default-to-firewall"
  resource_group_name    = module.bns_rg.name
  route_table_name       = azurerm_route_table.firewall_routetable.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.azure_firewall.firewall_private_ip
}

resource "azurerm_subnet_route_table_association" "web_rt_assoc" {
  subnet_id      = module.c2c_vnet.subnet_ids["web"]
  route_table_id = azurerm_route_table.firewall_routetable.id
}

# =======================
# HUB-SPOKE PEERING
# =======================
module "peering_mgmt_to_c2c" {
  source                = "./modules/peering"
  resource_group_name   = module.bns_rg.name
  source_vnet_name      = module.mgmt_vnet.vnet_name
  remote_vnet_name      = module.c2c_vnet.vnet_name
  remote_vnet_id        = module.c2c_vnet.vnet_id
  allow_gateway_transit = true
  use_remote_gateways   = false
}

module "peering_c2c_to_mgmt" {
  source                = "./modules/peering"
  resource_group_name   = module.bns_rg.name
  source_vnet_name      = module.c2c_vnet.vnet_name
  remote_vnet_name      = module.mgmt_vnet.vnet_name
  remote_vnet_id        = module.mgmt_vnet.vnet_id
  allow_gateway_transit = false
  use_remote_gateways   = false
}

module "peering_cc1_to_mgmt" {
  source                = "./modules/peering"
  resource_group_name   = module.bns_rg.name
  source_vnet_name      = module.cc1_vnet.vnet_name
  remote_vnet_name      = module.mgmt_vnet.vnet_name
  remote_vnet_id        = module.mgmt_vnet.vnet_id
  allow_gateway_transit = false
  use_remote_gateways   = false
}

# =======================
# LOG ANALYTICS + DIAGNOSTICS
# =======================
resource "azurerm_log_analytics_workspace" "firewall_logs" {
  name                = "Custodia-FW-Logs"
  location            = module.bns_rg.location
  resource_group_name = module.bns_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics" {
  name                       = "Custodia-Firewall-Diagnostics"
  target_resource_id         = module.azure_firewall.firewall_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.firewall_logs.id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
# =======================
#  AZURE BASTION
# =======================
module "bastion" {
  source              = "./modules/bastion"
  resource_group_name = module.bns_rg.name
  location            = module.bns_rg.location
  subnet_id           = module.mgmt_vnet.subnet_ids["AzureBastionSubnet"]
}

# =======================
#  JUMPBOX VM
# =======================
module "jumpbox" {
  source              = "./modules/jumpbox"
  resource_group_name = module.bns_rg.name
  location            = module.bns_rg.location
  subnet_id           = module.mgmt_vnet.subnet_ids["jumpbox"]
  vm_name             = "Custodia-Jump"
  admin_username      = "azureadmin"
  admin_password      = "P@ssw0rd1234!" # replace with Key Vault later
  enable_public_ip    = false
}

