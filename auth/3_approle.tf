# Name: approle.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault AppRole Auth Method
# The approle auth method allows machines or apps to authenticate with Vault-defined roles. 

resource "vault_auth_backend" "approle" {
  type     = "approle"
  path     = "approle"
  provider = vault.root
}

resource "vault_approle_auth_backend_role" "webapp" {
  backend        = vault_auth_backend.approle.path
  role_name      = "webapp"
  token_policies = ["admin"]
  provider       = vault.root
}



resource "vault_auth_backend" "dev_approle" {
  type       = "approle"
  path       = "approle"
  provider   = vault.dev
  depends_on = [var.dev_namespace]
}

resource "vault_approle_auth_backend_role" "dev_webapp" {
  backend        = vault_auth_backend.dev_approle.path
  role_name      = "dev-webapp"
  token_policies = ["kv-read"]
  provider       = vault.dev
  depends_on     = [var.dev_namespace]
}



/*
# Enable Auth
vault auth enable -namespace=dev -path=approle approle
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/auth/approle -d '{"type": "approle"}'

# List Auth
vault auth list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/auth

# Create AppRole
vault write -namespace=dev auth/approle/role/dev-webapp policies=kv-read
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/approle/role/dev-webapp -d '{"policies": "kv-read"}'

# Read AppRole
vault read -namespace=dev auth/approle/role/dev-webapp
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/approle/role/dev-webapp

# List AppRoles
vault list -namespace=dev auth/approle/role
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/auth/approle/role

# Read AppRole Role ID
vault read -namespace=dev auth/approle/role/dev-webapp/role-id
# 31a9a5a7-bebb-980e-af5a-c64d0d6862a8
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/approle/role/dev-webapp/role-id

# Get AppRole Secret ID
vault write -namespace=dev -f auth/approle/role/dev-webapp/secret-id
# b0ef6f8d-1faf-13e3-e7bd-6f5a39d93a14
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/approle/role/dev-webapp/secret-id

# AppRole Login
vault write -namespace=dev auth/approle/login role_id=31a9a5a7-bebb-980e-af5a-c64d0d6862a8 secret_id=b0ef6f8d-1faf-13e3-e7bd-6f5a39d93a14
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/approle/login -d '{"role_id": "31a9a5a7-bebb-980e-af5a-c64d0d6862a8", "secret_id": "b0ef6f8d-1faf-13e3-e7bd-6f5a39d93a14"}'

# Delete AppRole
vault delete -namespace=dev auth/approle/role/dev-webapp
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/auth/approle/role/dev-webapp

# Disable Auth
vault auth disable -namespace=dev approle
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/auth/approle
*/
