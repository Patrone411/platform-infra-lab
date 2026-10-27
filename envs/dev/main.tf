terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstatepkdevops01"
    container_name       = "tfstate-dev"
    key                  = "platform.tfstate"

    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
}

locals {
  name = "${var.project}-${var.environment}"

  common_tags = {
    project     = var.project
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
  }
}

data "azurerm_resource_group" "environment" {
  name = "rg-lab-${var.environment}"
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${local.name}"
  location            = data.azurerm_resource_group.environment.location
  resource_group_name = data.azurerm_resource_group.environment.name

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = local.common_tags
}