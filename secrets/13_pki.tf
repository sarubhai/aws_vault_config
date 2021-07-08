# Name: pki.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault PKI Secrets Engine
# The PKI secrets engine generates dynamic X.509 certificates.
# Acquire certificates without going through the usual manual process of generating a private key and Certificate Signing Request (CSR), 
# submitting to a Certificate Authority (CA), and then waiting for the verification and signing process to complete.
# Use Vault to create X.509 certificates for usage in Mutual Transport Layer Security (MTLS) or other arbitrary PKI encryption. 
# This solution can be used to create web server certificates.

resource "vault_mount" "pki" {
  type                      = "pki"
  path                      = "pki"
  default_lease_ttl_seconds = 157680000
  max_lease_ttl_seconds     = 157680000
  provider                  = vault.root
}

resource "vault_pki_secret_backend_root_cert" "root_ca" {
  backend              = vault_mount.pki.path
  type                 = "internal"
  common_name          = "example.com"
  organization         = "SaruBhai"
  ou                   = "Development"
  country              = "SG"
  locality             = "Singapore"
  province             = "Singapore"
  ttl                  = "315360000"
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 2048
  exclude_cn_from_sans = true
  provider             = vault.root
  depends_on           = [vault_mount.pki]
}

resource "vault_mount" "pki_int" {
  type                      = "pki"
  path                      = "pki_int"
  default_lease_ttl_seconds = 157680000
  max_lease_ttl_seconds     = 157680000
  provider                  = vault.root
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate_csr" {
  backend              = vault_mount.pki_int.path
  type                 = "internal"
  common_name          = "example.com Intermediate Authority"
  organization         = "SaruBhai"
  ou                   = "Development"
  country              = "SG"
  locality             = "Singapore"
  province             = "Singapore"
  format               = "pem"
  exclude_cn_from_sans = true
  provider             = vault.root
  depends_on           = [vault_mount.pki_int]
}

resource "vault_pki_secret_backend_root_sign_intermediate" "root_sign_intermediate_csr" {
  backend              = vault_mount.pki.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.intermediate_csr.csr
  common_name          = "example.com Intermediate Authority"
  organization         = "SaruBhai"
  ou                   = "Development"
  country              = "SG"
  locality             = "Singapore"
  province             = "Singapore"
  ttl                  = "315360000"
  format               = "pem"
  exclude_cn_from_sans = true
  provider             = vault.root
  depends_on           = [vault_mount.pki, vault_pki_secret_backend_intermediate_cert_request.intermediate_csr]
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate_ca" {
  backend     = vault_mount.pki_int.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.root_sign_intermediate_csr.certificate
  provider    = vault.root
  depends_on  = [vault_mount.pki_int, vault_pki_secret_backend_root_sign_intermediate.root_sign_intermediate_csr]
}

resource "vault_pki_secret_backend_role" "role_example_dot_com" {
  backend          = vault_mount.pki_int.path
  name             = "example-dot-com"
  allowed_domains  = ["example.com"]
  allow_subdomains = true
  ttl              = 6192000
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 2048
  key_usage        = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
  provider         = vault.root
  depends_on       = [vault_mount.pki_int]
}



/*
# Generate Root CA
# ----------------
# Enable PKI
vault secrets enable -namespace=dev -path=pki pki
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/pki -d '{"type": "pki"}'

# Tune Secrets Engine
vault secrets tune -namespace=dev -max-lease-ttl=87600h pki
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/pki/tune -d '{"max_lease_ttl": "87600h"}'

# List Secrets Engines
vault secrets list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/mounts

# Generate Root certificate
vault write -namespace=dev -field=certificate pki/root/generate/internal common_name="example.com" organization=SaruBhai ou=Development country=SG locality=Singapore province=Singapore ttl=87600h > CA.cert
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/pki/root/generate/internal -d '{"common_name": "example.com", "organization": "SaruBhai", "ou": "Development", "country": "SG", "locality": "Singapore", "province": "Singapore", "ttl": "87600h"}' | jq -r ".data.certificate" > CA.cert


# Generate Intermediate CA
# ------------------------
# Enable PKI
vault secrets enable -namespace=dev -path=pki_int pki
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/pki_int -d '{"type": "pki"}'

# Tune Secrets Engine
vault secrets tune -namespace=dev -max-lease-ttl=43800h pki_int
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/pki_int/tune -d '{"max_lease_ttl": "43800h"}'

# Generate Intermediate CSR
vault write -namespace=dev -field=csr pki_int/intermediate/generate/internal common_name="example.com Intermediate Authority" organization=SaruBhai ou=Development country=SG locality=Singapore province=Singapore > CA_intermediate.csr
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/pki_int/intermediate/generate/internal -d '{"common_name": "example.com Intermediate Authority", "organization": "SaruBhai", "ou": "Development", "country": "SG", "locality": "Singapore", "province": "Singapore"}' | jq -r ".data.csr" > CA_intermediate.csr

# Generate CA Signed Intermediate Certificate
vault write -namespace=dev -field=certificate pki/root/sign-intermediate csr=@CA_intermediate.csr common_name="example.com Intermediate Authority" organization=SaruBhai ou=Development country=SG locality=Singapore province=Singapore format=pem_bundle ttl="43800h" > CA_intermediate.cert
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/pki/root/sign-intermediate -d '{"common_name": "example.com Intermediate Authority", "organization": "SaruBhai", "ou": "Development", "country": "SG", "locality": "Singapore", "province": "Singapore", "format": "pem_bundle", "ttl": "43800h"}' --csr CA_intermediate.csr | jq -r ".data.certificate" > CA_intermediate.cert

# Import Intermediate Certificate to Vault
vault write -namespace=dev pki_int/intermediate/set-signed certificate=@CA_intermediate.cert
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/pki_int/intermediate/set-signed -d '{}' --certificate CA_intermediate.cert

# Create a Role
vault write -namespace=dev pki_int/roles/example-dot-com allowed_domains="example.com" allow_subdomains=true max_ttl="720h"
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/pki_int/roles/example-dot-com '{"allowed_domains": "example.com", "allow_subdomains": true, "max_ttl": "720h"}'

# Request Certificate
vault write -namespace=dev pki_int/issue/example-dot-com common_name="webapp.example.com" ttl="48h"
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/pki_int/issue/example-dot-com '{"common_name": "webapp.example.com", "ttl": "48h"}'
# ca_chain            [-----BEGIN CERTIFICATE-----
# certificate         -----BEGIN CERTIFICATE-----
# expiration          1625394533
# issuing_ca          -----BEGIN CERTIFICATE-----
# private_key         -----BEGIN RSA PRIVATE KEY-----
# private_key_type    rsa
# serial_number       1f:74:1d:04:c0:58:22:b0:0e:54:58:6d:1a:fd:c8:9d:6f:a7:77:3b

# Revoke Certificates
vault write -namespace=dev pki_int/revoke serial_number=1f:74:1d:04:c0:58:22:b0:0e:54:58:6d:1a:fd:c8:9d:6f:a7:77:3b
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/pki_int/revoke -d '{"serial_number": "1f:74:1d:04:c0:58:22:b0:0e:54:58:6d:1a:fd:c8:9d:6f:a7:77:3b"}'

# Remove Expired Certificates
vault write -namespace=dev pki_int/tidy tidy_cert_store=true tidy_revoked_certs=true
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/pki_int/tidy -d '{"tidy_cert_store": true, "tidy_revoked_certs": true}'

# Delete a Role
vault delete -namespace=dev pki_int/roles/example-dot-com
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/pki_int/roles/example-dot-com

# Delete Root
vault delete -namespace=dev pki_int/root
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/pki_int/root

# Disable PKI
vault secrets disable -namespace=dev pki_int
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/mounts/pki_int
vault secrets disable -namespace=dev pki
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/mounts/pki
*/
