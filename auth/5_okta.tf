# Name: okta.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Okta Auth Method
# The okta auth method can be used to authenticate with Vault using Okta user/password credentials.

resource "vault_okta_auth_backend" "okta" {
  path         = "okta"
  organization = var.okta_org
  provider     = vault.root
}

resource "vault_okta_auth_backend_user" "admin_user" {
  username   = "admin@example.com"
  policies   = ["admin"]
  path       = vault_okta_auth_backend.okta.path
  provider   = vault.root
  depends_on = [vault_okta_auth_backend.okta]
}

resource "vault_okta_auth_backend_group" "management_group" {
  group_name = "management"
  policies   = ["kv-read"]
  path       = vault_okta_auth_backend.okta.path
  provider   = vault.root
  depends_on = [vault_okta_auth_backend.okta]
}


resource "vault_okta_auth_backend" "dev_okta" {
  path         = "okta"
  organization = var.okta_org
  provider     = vault.dev
}

resource "vault_okta_auth_backend_user" "dev_admin_user" {
  username   = "admin@example.com"
  policies   = ["admin"]
  path       = vault_okta_auth_backend.dev_okta.path
  provider   = vault.dev
  depends_on = [var.dev_namespace, vault_okta_auth_backend.dev_okta]
}

resource "vault_okta_auth_backend_group" "dev_management_group" {
  group_name = "management"
  policies   = ["kv-read"]
  path       = vault_okta_auth_backend.dev_okta.path
  provider   = vault.dev
  depends_on = [var.dev_namespace, vault_okta_auth_backend.dev_okta]
}



/*
# Enable Auth
vault auth enable -namespace=dev okta
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/auth/okta -d '{"type": "okta"}'

# List Auth
vault auth list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/auth

# Configure Okta
vault write -namespace=dev auth/okta/config org_name="dev-123456"
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/okta/config -d '{"org_name": "dev-123456"}'

# Read Okta Config
vault read -namespace=dev auth/okta/config
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/okta/config

# Create User
vault write -namespace=dev auth/okta/users/admin@example.com policies=admin
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/okta/users/admin@example.com -d '{"policies": "admin,default"}'

# Read User
vault read -namespace=dev auth/okta/users/admin@example.com
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/okta/users/admin@example.com

# List Users
vault list -namespace=dev auth/okta/users
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/auth/okta/users

# Create Group
vault write -namespace=dev auth/okta/groups/management policies=kv-read
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/okta/groups/management -d '{"policies": "kv-read,default"}'

# Read Group
vault read -namespace=dev auth/okta/groups/management
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/okta/groups/management

# List Groups
vault list -namespace=dev auth/okta/groups
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/auth/okta/groups

# User Login
vault login -namespace=dev -method=okta username=admin@example.com password=Password123456
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/okta/login/admin@example.com -d '{"password": "Password123456"}'

# Delete User
vault delete -namespace=dev auth/okta/users/admin@example.com
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/auth/okta/users/admin@example.com

# Delete Group
vault delete -namespace=dev auth/okta/groups/management
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/auth/okta/groups/management

# Disable Auth
vault auth disable -namespace=dev okta
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/auth/okta
*/
