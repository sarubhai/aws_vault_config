# Name: secrets.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Secrets Engines

terraform {
  required_providers {
    vault = {
      source                = "hashicorp/vault"
      version               = "2.21.0"
      configuration_aliases = [vault.root, vault.dev]
    }
  }
}
