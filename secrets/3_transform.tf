# Name: transform.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Transform Secrets Engine
# The Transform secrets engine handles secure data transformation and tokenization against provided input value.
# The secret engine currently supports fpe, masking, and tokenization as data transformation types.

resource "vault_mount" "transform" {
  type     = "transform"
  path     = "transform"
  provider = vault.root
}

resource "vault_transform_role" "payments" {
  path            = vault_mount.transform.path
  name            = "payments"
  transformations = ["ccn-fpe"]
  provider        = vault.root
  depends_on      = [vault_mount.transform]
}

resource "vault_transform_alphabet" "numerics" {
  path       = vault_mount.transform.path
  name       = "numerics"
  alphabet   = "0123456789"
  provider   = vault.root
  depends_on = [vault_mount.transform]
}

resource "vault_transform_template" "ccn-regex" {
  path       = vault_transform_alphabet.numerics.path
  name       = "ccn"
  type       = "regex"
  pattern    = "(\\d{4})-(\\d{4})-(\\d{4})-(\\d{4})"
  alphabet   = "numerics"
  provider   = vault.root
  depends_on = [vault_transform_alphabet.numerics]
}

resource "vault_transform_transformation" "ccn-fpe" {
  path          = vault_mount.transform.path
  name          = "ccn-fpe"
  type          = "fpe"
  template      = "ccn"
  tweak_source  = "internal"
  allowed_roles = ["payments"]
  provider      = vault.root
  depends_on    = [vault_mount.transform]
}



resource "vault_mount" "dev_transform" {
  type       = "transform"
  path       = "transform"
  provider   = vault.dev
  depends_on = [var.dev_namespace]
}

resource "vault_transform_role" "dev_payments" {
  path            = vault_mount.dev_transform.path
  name            = "payments"
  transformations = ["ccn-fpe"]
  provider        = vault.dev
  depends_on      = [var.dev_namespace, vault_mount.dev_transform]
}

resource "vault_transform_alphabet" "dev_numerics" {
  path       = vault_mount.dev_transform.path
  name       = "numerics"
  alphabet   = "0123456789"
  provider   = vault.dev
  depends_on = [var.dev_namespace, vault_mount.dev_transform]
}

resource "vault_transform_template" "dev-ccn-regex" {
  path       = vault_transform_alphabet.dev_numerics.path
  name       = "ccn"
  type       = "regex"
  pattern    = "(\\d{4})-(\\d{4})-(\\d{4})-(\\d{4})"
  alphabet   = "numerics"
  provider   = vault.dev
  depends_on = [var.dev_namespace, vault_transform_alphabet.dev_numerics]
}

resource "vault_transform_transformation" "dev-ccn-fpe" {
  path          = vault_mount.dev_transform.path
  name          = "ccn-fpe"
  type          = "fpe"
  template      = "ccn"
  tweak_source  = "internal"
  allowed_roles = ["payments"]
  provider      = vault.dev
  depends_on    = [var.dev_namespace, vault_mount.dev_transform]
}



/*
# Enable Transform
vault secrets enable -namespace=dev -path=transform transform
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/transform -d '{"type": "transform"}'

# List Secrets Engines
vault secrets list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/mounts


# Create Role
vault write -namespace=dev -f transform/role/payments transformations=ccn-fpe
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/transform/role/payments -d '{"transformations": ["ccn-fpe"]}'

# Read Role
vault read -namespace=dev transform/role/payments
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/transform/role/payments

# List Roles
vault list -namespace=dev transform/role
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/transform/role


# Create Transformation
vault write -namespace=dev -f transform/transformation/ccn-fpe type=fpe template=ccn tweak_source=internal allowed_roles=payments
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/transform/transformation/ccn-fpe -d '{"type": "fpe","template": "ccn","tweak_source": "internal","allowed_roles": ["payments"]}'
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/transform/transformations/fpe/ccn-fpe -d '{"template": "ccn","tweak_source": "internal","allowed_roles": ["payments"]}'

# Read Transformation
vault read -namespace=dev transform/transformation/ccn-fpe
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/transform/transformation/ccn-fpe

# List Transformations
vault list -namespace=dev transform/transformation
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/transform/transformation


# Create Template
vault write -namespace=dev -f transform/template/ccn type=regex pattern=(\\d{4})-(\\d{4})-(\\d{4})-(\\d{4}) alphabet=numerics
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/transform/template/ccn -d '{"type": "regex","pattern": "(\\d{4})-(\\d{4})-(\\d{4})-(\\d{4})","alphabet": "numerics"}'

# Read Template
vault read -namespace=dev transform/template/ccn
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/transform/template/ccn

# List Templates
vault list -namespace=dev transform/template
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/transform/template


# Create Alphabet
vault write -namespace=dev -f transform/alphabet/numerics alphabet=0123456789
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/transform/alphabet/numerics -d '{"alphabet": "0123456789"}'

# Read Alphabet
vault read -namespace=dev transform/alphabet/numerics
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/transform/alphabet/numerics

# List Alphabets
vault list -namespace=dev transform/alphabet
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/transform/alphabet


# Encode Data
vault write -namespace=dev transform/encode/payments value=1111-2222-3333-4444 transformation=ccn-fpe
# 5371-5037-5573-8166
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/transform/encode/payments -d '{"value": "1111-2222-3333-4444","transformation": "ccn-fpe"}'

# Decode Data
vault write -namespace=dev transform/decode/payments value=5371-5037-5573-8166 transformation=ccn-fpe
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/transform/decode/payments -d '{"value": "5371-5037-5573-8166","transformation": "ccn-fpe"}'


# Delete Alphabet
vault delete -namespace=dev /transform/alphabet/numerics
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/transform/alphabet/numerics

# Delete Template
vault delete -namespace=dev /transform/template/ccn
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/transform/template/ccn

# Delete Transformation
vault delete -namespace=dev /transform/transformation/ccn-fpe
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/transform/transformation/ccn-fpe

# Delete Role
vault delete -namespace=dev transform/role/ccn-fpe
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/transform/role/ccn-fpe

# Disable KV
vault secrets disable -namespace=dev transform
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/mounts/transit
*/
