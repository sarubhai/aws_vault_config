# Name: ssh.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Dynamic Secrets Engine For SSH
# The Vault SSH secrets engine provides secure authentication and authorization for access to machines via the SSH protocol.
# The Vault SSH secrets engine helps manage access to machine infrastructure, providing several ways to issue SSH credentials -
# Signed SSH Certificates & One-time SSH Passwords

resource "vault_mount" "ssh" {
  type     = "ssh"
  path     = "ssh"
  provider = vault.root
}

resource "vault_ssh_secret_backend_role" "otp_key_role" {
  backend      = vault_mount.ssh.path
  name         = "otp_key_role"
  key_type     = "otp"
  default_user = "ubuntu"
  cidr_list    = "0.0.0.0/0"
  provider     = vault.root
  depends_on   = [vault_mount.ssh]
}



resource "vault_mount" "dev_ssh" {
  type       = "ssh"
  path       = "ssh"
  provider   = vault.dev
  depends_on = [var.dev_namespace]
}

resource "vault_ssh_secret_backend_role" "dev_otp_key_role" {
  backend      = vault_mount.dev_ssh.path
  name         = "otp_key_role"
  key_type     = "otp"
  default_user = "ubuntu"
  cidr_list    = "0.0.0.0/0"
  provider     = vault.dev
  depends_on   = [var.dev_namespace, vault_mount.dev_ssh]
}



/*
# Enable SSH
vault secrets enable -namespace=dev -path=ssh ssh
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/ssh -d '{"type": "ssh"}'

# List Secrets Engines
vault secrets list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/mounts

# Create Role
vault write -namespace=dev ssh/roles/otp_key_role key_type=otp default_user=ubuntu port=22 cidr_list=0.0.0.0/0
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/ssh/roles/otp_key_role -d '{"key_type": "otp", "default_user": "ubuntu", "port": 22, "cidr_list": "0.0.0.0/0"}'

# Read Role
vault read -namespace=dev ssh/roles/otp_key_role
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/ssh/role/dynamic-role

# List Roles
vault list -namespace=dev ssh/roles
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/ssh/roles

# Generate OTP
vault write -namespace=dev ssh/creds/otp_key_role ip=10.0.1.101
# key                89356c02-fcec-a913-88de-68d43bc5b0b2
# key_type           otp
# username           ubuntu
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/ssh/creds/otp_key_role -d '{"ip": "10.0.1.101"}'
# vault ssh -role otp_key_role -mode otp -strict-host-key-checking=no ubuntu@10.0.1.101

# Test
# ssh ubuntu@10.0.1.101
# Password: 89356c02-fcec-a913-88de-68d43bc5b0b2

# Revoke Lease
vault lease revoke -namespace=dev -force -prefix ssh/creds

# Delete Role
vault delete -namespace=dev ssh/roles/otp_key_role
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/ssh/roles/otp_key_role

# Disable OpenLDAP
vault secrets disable -namespace=dev ssh
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/mounts/ssh
*/
