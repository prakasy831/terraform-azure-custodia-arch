resource "azurerm_firewall_policy" "this" {
  name                = var.policy_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_firewall_policy_rule_collection_group" "rules" {
  name               = "${var.policy_name}-rules"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 100

  application_rule_collection {
    name     = "Allow-HTTP-HTTPS"
    priority = 100
    action   = "Allow"

    rule {
      name             = "AllowWebTraffic"
      source_addresses = ["*"]                   # ? FIXED (no CIDR ranges)
      destination_fqdns = ["*"]

      protocols {
        type = "Http"
        port = 80
      }

      protocols {
        type = "Https"
        port = 443
      }
    }
  }

  network_rule_collection {
    name     = "Allow-DNS"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "AllowDNS"
      source_addresses      = ["*"]              # ? FIXED (was 10.200.0.0/8)
      destination_addresses = ["8.8.8.8", "8.8.4.4"]
      destination_ports     = ["53"]
      protocols             = ["UDP"]
    }
  }
}
