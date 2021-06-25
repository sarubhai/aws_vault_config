# Name: policies.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Policies


terraform {
  required_providers {
    vault = {
      source                = "hashicorp/vault"
      version               = "2.21.0"
      configuration_aliases = [vault.root, vault.dev]
    }
  }
}

resource "vault_policy" "admin_policy" {
  name     = "admin"
  policy   = file("${path.module}/admin-policy.hcl")
  provider = vault.root
}

resource "vault_policy" "dev_admin_policy" {
  name       = "admin"
  policy     = file("${path.module}/admin-policy.hcl")
  provider   = vault.dev
  depends_on = [var.dev_namespace]
}


resource "vault_policy" "kv_read_policy" {
  name     = "kv-read"
  policy   = file("${path.module}/kv-read-policy.hcl")
  provider = vault.root
}

resource "vault_policy" "dev_kv_read_policy" {
  name       = "kv-read"
  policy     = file("${path.module}/kv-read-policy.hcl")
  provider   = vault.dev
  depends_on = [var.dev_namespace]
}



# Format Policy
# vault policy fmt admin-policy.hcl

# Write Policy
# vault policy write -namespace=dev admin ./admin-policy.hcl
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X PUT $VAULT_ADDR/v1/sys/policies/acl/admin -d @admin-policy.json

# Read Policy
# vault policy read -namespace=dev admin
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/policies/acl/admin

# List Policy
# vault policy list -namespace=dev
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/sys/policies/acl

# Delete Policy
# vault policy delete -namespace=dev admin
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/policies/acl/admin
