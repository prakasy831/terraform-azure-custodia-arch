# ===============================
#  Jumpbox VM (Windows)
# ===============================
resource "azurerm_network_interface" "jumpbox_nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Optional: Public IP (disabled by default)
resource "azurerm_public_ip" "jumpbox_pip" {
  count               = var.enable_public_ip ? 1 : 0
  name                = "${var.vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# ? Removed unused backend association — not needed unless using Load Balancer

resource "azurerm_windows_virtual_machine" "jumpbox" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.jumpbox_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  automatic_updates_enabled = true  # ? updated to latest syntax
  patch_mode                = "AutomaticByOS"
  provision_vm_agent        = true

  boot_diagnostics {
    storage_account_uri = null
  }

  tags = {
    environment = "jumpbox"
  }
}
