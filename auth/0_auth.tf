# Name: auth.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Auth Methods

terraform {
  required_providers {
    vault = {
      source                = "hashicorp/vault"
      version               = "2.21.0"
      configuration_aliases = [vault.root, vault.dev]
    }
  }
}
