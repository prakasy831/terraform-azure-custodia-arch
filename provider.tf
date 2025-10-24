terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "38c10c1b-bc79-4be3-b39b-87e65a7dc545"
  tenant_id       = "0d1ddb6a-0fe8-49d1-9be9-7d917d9b18b7"
}

