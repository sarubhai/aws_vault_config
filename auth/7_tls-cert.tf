# Name: tls-cert.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault TLS Certificates Auth Method
# The cert auth method allows authentication using SSL/TLS client certificates which are either signed by a CA or self-signed.

resource "vault_auth_backend" "cert" {
  type     = "cert"
  path     = "cert"
  provider = vault.root
}

resource "vault_cert_auth_backend_role" "webapp" {
  backend        = vault_auth_backend.cert.path
  name           = "webapp"
  certificate    = file("${var.ca_cert_path}")
  allowed_names  = ["web.local", "api.local"]
  token_policies = ["admin"]
  provider       = vault.root
  depends_on     = [vault_auth_backend.cert]
}



resource "vault_auth_backend" "dev_cert" {
  type       = "cert"
  path       = "cert"
  provider   = vault.dev
  depends_on = [var.dev_namespace]
}

resource "vault_cert_auth_backend_role" "dev_webapp" {
  backend        = vault_auth_backend.dev_cert.path
  name           = "dev-webapp"
  certificate    = file("${var.ca_cert_path}")
  allowed_names  = ["web.local", "api.local"]
  token_policies = ["kv-read"]
  provider       = vault.dev
  depends_on     = [var.dev_namespace, vault_auth_backend.dev_cert]
}



/*
# Enable Auth
vault auth enable -namespace=dev -path=cert cert
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/auth/cert -d '{"type": "cert"}'

# List Auth
vault auth list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/auth

# Create Certificate Role
vault write -namespace=dev auth/cert/certs/dev-webapp display_name=dev-webapp policies=kv-read certificate=@ca.cert allowed_names="web.local,api.local"
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/cert/certs/dev-webapp -d '{"display_name": "dev-webapp", "policies": "kv-read"}' --cacert ca.cert

# Read Certificate Role
vault read -namespace=dev auth/cert/certs/dev-webapp
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/cert/certs/dev-webapp

# List Certificate Roles
vault list -namespace=dev auth/cert/certs
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/auth/cert/certs

# Certificate Role Login
vault login -namespace=dev -method=cert -client-cert=api.cert -client-key=api.key name=dev-webapp
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/cert/login -d '{"name": "dev-webapp"}' --cert api.cert --key api.key

# Delete Certificate Role
vault delete -namespace=dev auth/cert/certs/dev-webapp
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/auth/cert/certs/dev-webapp

# Disable Auth
vault auth disable -namespace=dev cert
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/auth/cert
*/
