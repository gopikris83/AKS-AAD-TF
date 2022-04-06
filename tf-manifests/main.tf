##########################################################
# Terraform providers
# Terraform backend for storing state in Azure Storage
##########################################################

terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tf-storage-rg"
    storage_account_name = "akscluster110322"
    container_name       = "tfstate"
    key                  = "dev.terraform.state"
  }
}

provider "azurerm" {
  features {}
}

