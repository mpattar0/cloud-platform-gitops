terraform {
  required_version = "~> 1.15.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.60"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.6"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-cpgitops-tfstate"
    storage_account_name = "stcpgitopstfstate"
    container_name       = "tfstate"
    key                  = "root.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
  }
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy               = true
      purge_soft_deleted_secrets_on_destroy      = true
      purge_soft_deleted_certificates_on_destroy = true
      purge_soft_deleted_keys_on_destroy         = true
    }
  }
}

provider "azuread" {
}
