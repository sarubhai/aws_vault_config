# Name: userpass.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault KV Secrets Engine - Version 2


terraform {
  required_providers {
    vault = {
      source                = "hashicorp/vault"
      version               = "2.21.0"
      configuration_aliases = [vault.root, vault.dev]
    }
  }
}


resource "vault_mount" "kv-v2" {
  type     = "kv-v2"
  path     = "kv2"
  provider = vault.root
}


resource "vault_mount" "dev-kv-v2" {
  type       = "kv-v2"
  path       = "kv2"
  provider   = vault.dev
  depends_on = [var.dev_namespace]
}



# Enable KV
# vault secrets enable -namespace=dev -version=2 -path=kv2 kv
# vault secrets enable -namespace=dev -path=kv2 kv-v2
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/kv2 -d '{"type": "kv", "version": 2}'

# List Secrets Engines
# vault secrets list -namespace=dev
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/mounts

# Create Secret
# vault kv put -namespace=dev kv2/dev_db_creds name=admin pass=password
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/kv2/data/dev_db_creds -d '{"data": {"name": "admin", "pass": "password"}}'

# Read Secret
# vault kv get -namespace=dev -version=1 kv2/dev_db_creds
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/kv2/data/dev_db_creds?version=1

# List Secrets
# vault kv list -namespace=dev kv2
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/kv2/metadata

# Delete Secret Data Versions
# Latest
# vault kv delete -namespace=dev kv2/dev_db_creds
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/kv2/data/dev_db_creds
# By Version
# vault kv delete -namespace=dev -versions=1 kv2/dev_db_creds
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X PUT $VAULT_ADDR/v1/kv2/delete/dev_db_creds -d '{"versions": [1]}'

# Delete Secret Metadata
# vault kv metadata delete -namespace=dev kv2/dev_db_creds
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/kv2/metadata/dev_db_creds

# Disable KV
# vault secrets disable -namespace=dev kv2
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/mounts/kv2