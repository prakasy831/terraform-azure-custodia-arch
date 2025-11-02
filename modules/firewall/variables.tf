variable "firewall_name" {}
variable "resource_group_name" {}
variable "location" {}
variable "subnet_id" {
  description = "Subnet ID of the AzureFirewallSubnet"
}
variable "firewall_policy_id" {
  description = "Firewall policy ID to associate"
  default     = null
}

