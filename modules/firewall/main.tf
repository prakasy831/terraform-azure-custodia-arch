resource "azurerm_public_ip" "firewall_pip" {
  name                = "${var.firewall_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "this" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = var.firewall_policy_id

  ip_configuration {
    name                 = "firewall-ipconfig"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }

  threat_intel_mode = "Alert"
}

