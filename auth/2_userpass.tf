# Name: userpass.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault UserPass Auth Method
# The userpass auth method allows users to authenticate with Vault using a username and password combination.

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
  depends_on = [vault_auth_backend.dev_userpass, var.dev_namespace]
}



/*
# Enable Auth
vault auth enable -namespace=dev userpass
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/auth/userpass -d '{"type": "userpass"}'

# List Auth
vault auth list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/auth

# Create User
vault write -namespace=dev auth/userpass/users/admin password=Password123456 policies=admin
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/userpass/users/admin -d '{"password": "Password123456", "policies": "admin,default"}'

# Read User
vault read -namespace=dev auth/userpass/users/admin
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/userpass/users/admin

# List Users
vault list -namespace=dev auth/userpass/users
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/auth/userpass/users

# User Login
vault login -method=userpass username=admin password=Password123456
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/userpass/login/admin -d '{"password": "Password123456"}'

# Update User Password
vault write -namespace=dev auth/userpass/users/admin/password password=Password12345678
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/userpass/users/admin/password -d '{"password": "Password12345678"}'

# Update User Policies
vault write -namespace=dev auth/userpass/users/admin/policies policies="admin,default"
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/userpass/users/admin/policies -d '{"policies": ["admin", "default"]}'

# Delete User
vault delete -namespace=dev auth/userpass/users/admin
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/auth/userpass/users/admin

# Disable Auth
vault auth disable -namespace=dev userpass
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/auth/userpass
*/
