variable "resource_group_name" {}
variable "source_vnet_name" {}
variable "remote_vnet_name" {}
variable "remote_vnet_id" {}
variable "allow_gateway_transit" {
  type    = bool
  default = false
}
variable "use_remote_gateways" {
  type    = bool
  default = false
}

