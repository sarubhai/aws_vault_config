# Name: transit.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Transit Secrets Engine
# The transit secrets engine handles cryptographic functions on data in-transit.
# It can also be viewed as "cryptography as a service" or "encryption as a service".
# The transit secrets engine can also sign and verify data; generate hashes and HMACs of data; and act as a source of random bytes.

resource "vault_mount" "transit" {
  type     = "transit"
  path     = "transit"
  provider = vault.root
}

resource "vault_transit_secret_backend_key" "webapp_key" {
  backend          = vault_mount.transit.path
  name             = "webapp_key"
  deletion_allowed = true
  provider         = vault.root
  depends_on       = [vault_mount.transit]
}



resource "vault_mount" "dev_transit" {
  type       = "transit"
  path       = "transit"
  provider   = vault.dev
  depends_on = [var.dev_namespace]
}

resource "vault_transit_secret_backend_key" "dev_webapp_key" {
  backend          = vault_mount.dev_transit.path
  name             = "dev_webapp_key"
  deletion_allowed = true
  provider         = vault.dev
  depends_on       = [var.dev_namespace, vault_mount.dev_transit]
}



/*
# Enable Transit
vault secrets enable -namespace=dev -path=transit transit
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/transit -d '{"type": "transit"}'

# List Secrets Engines
vault secrets list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/mounts

# Create Key
vault write -namespace=dev -f transit/keys/dev_webapp_key
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/transit/keys/dev_webapp_key -d '{}'

# Get Key
vault read -namespace=dev transit/keys/dev_webapp_key
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/transit/keys/dev_webapp_key

# List Keys
vault list -namespace=dev transit/keys
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/transit/keys

# Encrypt Data
vault write -namespace=dev transit/encrypt/dev_webapp_key plaintext=$(base64 <<< "my secret data")
# bXkgc2VjcmV0IGRhdGEK
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/transit/encrypt/dev_webapp_key -d '{"plaintext": "bXkgc2VjcmV0IGRhdGEK"}'

# Decrypt Data
vault write -namespace=dev transit/decrypt/dev_webapp_key ciphertext="vault:v1:NvFoevvO6WYybe81dZZ/afHk7aCdXrHprYMQDWJuaMgOZ7PXcEeS3bht9w=="
vault write -namespace=dev -field=plaintext transit/decrypt/dev_webapp_key ciphertext="vault:v1:NvFoevvO6WYybe81dZZ/afHk7aCdXrHprYMQDWJuaMgOZ7PXcEeS3bht9w==" | base64 -d
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/transit/decrypt/dev_webapp_key -d '{"ciphertext": "vault:v1:NvFoevvO6WYybe81dZZ/afHk7aCdXrHprYMQDWJuaMgOZ7PXcEeS3bht9w=="}'

# Rotate Encryption Key
vault write -namespace=dev -f transit/keys/dev_webapp_key/rotate
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/transit/keys/dev_webapp_key/rotate -d '{}'

# Rewrap existing encrypted data with new key
vault write -namespace=dev transit/rewrap/dev_webapp_key ciphertext="vault:v1:NvFoevvO6WYybe81dZZ/afHk7aCdXrHprYMQDWJuaMgOZ7PXcEeS3bht9w=="
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/transit/rewrap/dev_webapp_key/rotate -d '{"ciphertext": "vault:v1:NvFoevvO6WYybe81dZZ/afHk7aCdXrHprYMQDWJuaMgOZ7PXcEeS3bht9w=="}'

# Update Key Configuration
vault write -namespace=dev -f transit/keys/dev_webapp_key/config deletion_allowed=false
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/transit/keys/dev_webapp_key/config -d '{"deletion_allowed": true}'

# Delete Key
vault delete -namespace=dev transit/keys/dev_webapp_key
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/transit/keys/dev_webapp_key

# Disable KV
vault secrets disable -namespace=dev transit
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/mounts/transit
*/
