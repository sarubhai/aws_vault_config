# Name: provider.tf
# Owner: Saurav Mitra
# Description: This terraform config will Configure Terraform Providers
# https://www.terraform.io/docs/language/providers/requirements.html

terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "2.21.0"
    }
  }
}

# Configure Vault Provider
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs
# $ export VAULT_ADDR="http://127.0.0.1:8200"
# $ export VAULT_TOKEN="s.yPwTXVk224LDfwbnZHTlSlvJ"

provider "vault" {
  # address = "http://127.0.0.1:8200"
  # token   = "s.yzr0jQlTPsWc3mB2dHeS3D3J"
}
