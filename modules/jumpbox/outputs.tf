output "private_ip" {
  value = azurerm_network_interface.jumpbox_nic.private_ip_address
}
output "vm_id" {
  value = azurerm_windows_virtual_machine.jumpbox.id
}

