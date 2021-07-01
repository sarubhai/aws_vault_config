# Name: github.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Github Auth Method
# The github auth method can be used to authenticate with Vault using a GitHub personal access token.
# This method of authentication is most useful for humans: operators or developers using Vault directly via the CLI.

resource "vault_github_auth_backend" "github" {
  path         = "github"
  organization = var.github_org
  provider     = vault.root
}

resource "vault_github_user" "admin_user" {
  user       = var.github_user
  policies   = ["admin"]
  backend    = vault_github_auth_backend.github.id
  provider   = vault.root
  depends_on = [vault_github_auth_backend.github]
}

resource "vault_github_team" "management_group" {
  team       = var.github_team
  policies   = ["kv-read"]
  backend    = vault_github_auth_backend.github.id
  provider   = vault.root
  depends_on = [vault_github_auth_backend.github]
}


resource "vault_github_auth_backend" "dev_github" {
  path         = "github"
  organization = var.github_org
  provider     = vault.dev
}

resource "vault_github_user" "dev_admin_user" {
  user       = var.github_user
  policies   = ["admin"]
  backend    = vault_github_auth_backend.dev_github.id
  provider   = vault.dev
  depends_on = [var.dev_namespace, vault_github_auth_backend.dev_github]
}

resource "vault_github_team" "dev_management_group" {
  team       = var.github_team
  policies   = ["kv-read"]
  backend    = vault_github_auth_backend.dev_github.id
  provider   = vault.dev
  depends_on = [var.dev_namespace, vault_github_auth_backend.dev_github]
}



/*
# Enable Auth
vault auth enable -namespace=dev github
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/auth/github -d '{"type": "github"}'

# List Auth
vault auth list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/auth

# Configure Github
vault write -namespace=dev auth/github/config organization="example"
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/github/config -d '{"organization":"example"}'

# Read Github Config
vault read -namespace=dev auth/github/config
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/github/config

# Create User
vault write -namespace=dev auth/github/map/users/johndoe policies=admin
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/github/map/users/johndoe -d '{"policies": "admin,default"}'

# Read User
vault read -namespace=dev auth/github/map/users/johndoe
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/github/map/users/johndoe

# List Users
vault list -namespace=dev auth/github/map/users
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/auth/github/map/users

# Create Team
vault write -namespace=dev auth/github/map/teams/devops policies=kv-read
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/github/map/teams/devops -d '{"policies": "kv-read,default"}'

# Read Team
vault read -namespace=dev auth/github/map/teams/devops
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/github/map/teams/devops

# List Teams
vault list -namespace=dev auth/github/map/teams
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/auth/github/map/teams

# Personal access tokens
# https://github.com/settings/tokens/new
# read:org

# User Login
vault login -namespace=dev -method=github token=github_personal_access_token
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/github/login/johndoe -d '{"password": "Password123456"}'

# Delete User
vault delete -namespace=dev auth/github/map/users/johndoe
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/auth/github/map/users/johndoe

# Delete Group
vault delete -namespace=dev auth/github/map/teams/devops
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/auth/github/map/teams/devops

# Disable Auth
vault auth disable -namespace=dev github
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/auth/github
*/
