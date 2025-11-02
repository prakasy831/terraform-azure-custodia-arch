variable "resource_group_name" {}
variable "location" {}
variable "subnet_id" {}
variable "vm_name" {}
variable "vm_size" {
  default = "Standard_B2ms"
}
variable "admin_username" {}
variable "admin_password" {}
variable "enable_public_ip" {
  type    = bool
  default = false
}

