variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
  default     = "BNS-RG"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

