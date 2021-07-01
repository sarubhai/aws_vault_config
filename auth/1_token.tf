# Name: token.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Token Auth Method
# The token method is built-in and automatically available at /auth/token. It allows users to authenticate using a token.

resource "vault_token_auth_backend_role" "webapp" {
  role_name              = "webapp"
  allowed_policies       = ["admin"]
  orphan                 = true
  token_period           = "86400"
  renewable              = true
  token_explicit_max_ttl = "115200"
  provider               = vault.root
}

resource "vault_token" "example" {
  role_name       = "webapp"
  policies        = ["admin"]
  renewable       = true
  ttl             = "24h"
  renew_min_lease = 43200
  renew_increment = 86400
  provider        = vault.root
  depends_on      = [vault_token_auth_backend_role.webapp]
}

resource "vault_token_auth_backend_role" "dev_webapp" {
  role_name              = "dev-webapp"
  allowed_policies       = ["kv-read"]
  orphan                 = true
  token_period           = "86400"
  renewable              = true
  token_explicit_max_ttl = "115200"
  provider               = vault.dev
  depends_on             = [var.dev_namespace]
}

resource "vault_token" "dev_example" {
  role_name       = "dev-webapp"
  policies        = ["kv-read"]
  renewable       = true
  ttl             = "24h"
  renew_min_lease = 43200
  renew_increment = 86400
  provider        = vault.dev
  depends_on      = [var.dev_namespace, vault_token_auth_backend_role.dev_webapp]
}



/*
# List Auth
vault auth list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/auth

# Create Token Role
vault write -namespace=dev auth/token/roles/dev-webapp allowed_policies=kv-read orphan=true renewable=true
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/token/roles/dev-webapp -d '{"allowed_policies": ["kv-read"],"orphan": true,"renewable": true}'

# Read Token Role
vault read -namespace=dev auth/token/roles/dev-webapp
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/token/roles/dev-webapp

# List Token Roles
vault list -namespace=dev auth/token/roles
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/auth/token/roles

# Create/Generate Token
vault write -namespace=dev auth/token/create/dev-webapp role_name=dev-webapp
# token                s.5cpN6EusPdw6BhZlmbnTK7PX.7CCMC
# token_accessor       vVaMPDG8t4UyHdlPVtIxTbcN.7CCMC
# token_duration       768h
# token_renewable      true
# token_policies       ["kv-read"]
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/token/create/dev-webapp -d '{"role_name": "dev-webapp"}'

# Lookup a Token
vault write -namespace=dev auth/token/lookup token=s.5cpN6EusPdw6BhZlmbnTK7PX.7CCMC
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/token/lookup -d '{"token": "s.5cpN6EusPdw6BhZlmbnTK7PX.7CCMC"}'

# Token Login
vault login -namespace=dev token=s.5cpN6EusPdw6BhZlmbnTK7PX.7CCMC
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/token/login -d '{"token": "s.5cpN6EusPdw6BhZlmbnTK7PX.7CCMC"}'

# Revoke Token
vault write -namespace=dev auth/token/revoke token=s.5cpN6EusPdw6BhZlmbnTK7PX.7CCMC
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/token/revoke -d '{"token": "s.5cpN6EusPdw6BhZlmbnTK7PX.7CCMC"}'

# Delete Token Role
vault delete -namespace=dev auth/token/roles/dev-webapp
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/auth/token/roles/dev-webapp
*/
