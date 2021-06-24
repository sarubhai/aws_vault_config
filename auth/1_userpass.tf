# Name: userpass.tf
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


resource "vault_auth_backend" "userpass" {
  type     = "userpass"
  path     = "userpass"
  provider = vault.root
}

resource "vault_generic_endpoint" "user_admin" {
  path                 = "auth/userpass/users/admin"
  ignore_absent_fields = true

  data_json  = <<EOT
{
  "policies": ["admin"],
  "password": "${var.admin_password}"
}
EOT
  provider   = vault.root
  depends_on = [vault_auth_backend.userpass]
}



resource "vault_auth_backend" "dev_userpass" {
  type       = "userpass"
  path       = "userpass"
  provider   = vault.dev
  depends_on = [var.dev_namespace]
}

resource "vault_generic_endpoint" "dev_user_admin" {
  path                 = "auth/userpass/users/admin"
  ignore_absent_fields = true

  data_json  = <<EOT
{
  "policies": ["admin"],
  "password": "${var.admin_password}"
}
EOT
  provider   = vault.dev
  depends_on = [vault_auth_backend.userpass, var.dev_namespace]
}



# Enable Auth
# vault auth enable -namespace=dev userpass
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/auth/userpass -d '{"type": "userpass"}'

# Create User
# vault write -namespace=dev auth/userpass/users/admin password=$admin_password policies=admin
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/userpass/users/admin -d "{\"password\": \"$admin_password\", \"policies\": \"admin,default\"}"

# Read User
# vault read -namespace=dev auth/userpass/users/admin
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/userpass/users/admin

# List Users
# vault list -namespace=dev auth/userpass/users
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/auth/userpass/users

# User Login
# vault login -method=userpass username=admin password=$admin_password
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/userpass/login/admin -d "{\"password\": \"$admin_password\"}"

# Update User Password
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/userpass/users/admin/password -d "{\"password\": \"new_$admin_password\"}"

# Update User Policies
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/userpass/users/admin/policies -d "{\"policies\": [\"admin\", \"default\"]}"

# Delete User
# vault delete -namespace=dev auth/userpass/users/admin
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/auth/userpass/users/admin

# Disable Auth
# vault auth disable -namespace=dev userpass
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/auth/userpass
