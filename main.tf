# main.tf
# Owner: Saurav Mitra
# Description: This terraform config will create the infrastructure resources for Vault Configuration


# Create Vault Enterprise Namespace
resource "vault_namespace" "dev" {
  path = "dev"
}



/*
# Create Namespace
vault namespace create dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -X POST $VAULT_ADDR/v1/sys/namespaces/dev

# List Namespaces
vault list sys/namespaces
curl -H "X-Vault-Token: $VAULT_TOKEN" -X LIST $VAULT_ADDR/v1/sys/namespaces

# Delete Namespaces
vault delete sys/namespaces/dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -X DELETE $VAULT_ADDR/v1/sys/namespaces/dev
*/


# $ export VAULT_NAMESPACE="dev"
provider "vault" {
  namespace = trimsuffix(vault_namespace.dev.id, "/")
  alias     = "dev"
}


# Policies
module "policies" {
  source = "./policies"

  providers = {
    vault.root = vault
    vault.dev  = vault.dev
  }

  dev_namespace = vault_namespace.dev
}


# Auth Methods
module "auth" {
  source = "./auth"

  providers = {
    vault.root = vault
    vault.dev  = vault.dev
  }

  dev_namespace                 = vault_namespace.dev
  admin_password                = var.admin_password
  okta_org                      = var.okta_org
  github_org                    = var.github_org
  github_user                   = var.github_user
  github_team                   = var.github_team
  ca_cert_path                  = var.ca_cert_path
  aws_account_id                = var.aws_account_id
  auth_aws_access_key           = var.auth_aws_access_key
  auth_aws_secret_key           = var.auth_aws_secret_key
  kubernetes_ca_cert            = var.kubernetes_ca_cert
  kubernetes_token_reviewer_jwt = var.kubernetes_token_reviewer_jwt
}


# Secrets Engines
module "secrets" {
  source = "./secrets"

  providers = {
    vault.root = vault
    vault.dev  = vault.dev
  }

  dev_namespace          = vault_namespace.dev
  admin_password         = var.admin_password
  secrets_aws_access_key = var.secrets_aws_access_key
  secrets_aws_secret_key = var.secrets_aws_secret_key
}


# Audit
resource "vault_audit" "audit_file" {
  type = "file"
  path = "audit_file"

  options = {
    file_path = "/var/log/vault/audit.log"
  }
}



/*
# Enable Audit Device
vault audit enable -path=audit_file file file_path=/var/log/vault/audit.log
curl -H "X-Vault-Token: $VAULT_TOKEN" -X POST $VAULT_ADDR/v1/sys/audit/audit_file -d '{"type": "file", "options": {"file_path": "/var/log/vault/audit.log"}}'

# List Audit Devices
vault audit list
curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET $VAULT_ADDR/v1/sys/audit

# Disable Audit Device
vault audit disable audit_file
curl -H "X-Vault-Token: $VAULT_TOKEN" -X DELETE $VAULT_ADDR/v1/sys/audit/audit_file
*/
