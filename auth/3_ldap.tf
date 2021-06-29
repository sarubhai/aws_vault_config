# Name: ldap.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault LDAP Auth Method

resource "vault_ldap_auth_backend" "ldap" {
  path        = "ldap"
  url         = "ldap://10.0.1.100:389"
  userdn      = "dc=example,dc=com"
  userattr    = "cn"
  groupdn     = "ou=Groups,dc=example,dc=com"
  groupattr   = "cn"
  groupfilter = "(|(givenName={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}}))"
  discoverdn  = false
  binddn      = "cn=admin,dc=example,dc=com"
  bindpass    = var.admin_password
  provider    = vault.root
}

resource "vault_ldap_auth_backend_user" "admin_user" {
  username   = "admin"
  policies   = ["admin"]
  backend    = vault_ldap_auth_backend.ldap.path
  provider   = vault.root
  depends_on = [vault_ldap_auth_backend.ldap]
}

resource "vault_ldap_auth_backend_group" "devteam_group" {
  groupname  = "DevTeam"
  policies   = ["kv-read"]
  backend    = vault_ldap_auth_backend.ldap.path
  provider   = vault.root
  depends_on = [vault_ldap_auth_backend.ldap]
}


resource "vault_ldap_auth_backend" "dev_ldap" {
  path        = "ldap"
  url         = "ldap://10.0.1.100:389"
  userdn      = "dc=example,dc=com"
  userattr    = "cn"
  groupdn     = "ou=Groups,dc=example,dc=com"
  groupattr   = "cn"
  groupfilter = "(|(givenName={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}}))"
  discoverdn  = false
  binddn      = "cn=admin,dc=example,dc=com"
  bindpass    = var.admin_password
  provider    = vault.dev
}

resource "vault_ldap_auth_backend_user" "dev_admin_user" {
  username   = "admin"
  policies   = ["admin"]
  backend    = vault_ldap_auth_backend.dev_ldap.path
  provider   = vault.dev
  depends_on = [var.dev_namespace, vault_ldap_auth_backend.dev_ldap]
}

resource "vault_ldap_auth_backend_group" "dev_devteam_group" {
  groupname  = "DevTeam"
  policies   = ["kv-read"]
  backend    = vault_ldap_auth_backend.dev_ldap.path
  provider   = vault.dev
  depends_on = [var.dev_namespace, vault_ldap_auth_backend.dev_ldap]
}



# Enable Auth
# vault auth enable -namespace=dev ldap
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/auth/ldap -d '{"type": "ldap"}'

# List Auth
# vault auth list -namespace=dev
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/auth

# Configure LDAP
# vault write -namespace=dev auth/ldap/config url="ldap://10.0.1.100:389" userdn="dc=example,dc=com" userattr="cn" groupdn="ou=Groups,dc=example,dc=com" groupattr="cn" groupfilter="(|(givenName={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}}))" discoverdn=false binddn="cn=admin,dc=example,dc=com" bindpass=Password123456
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/ldap/config -d '{"userdn":"dc=example,dc=com","userattr":"cn","groupdn":"ou=Groups,dc=example,dc=com","groupattr":"cn","groupfilter":"(|(givenName={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}}))","discoverdn":false,"binddn":"cn=admin,dc=example,dc=com","bindpass":"Password123456"}'

# Read LDAP Config
# vault read -namespace=dev auth/ldap/config
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/ldap/config

# Create User
# vault write -namespace=dev auth/ldap/users/admin policies=admin
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/ldap/users/admin -d '{"policies": "admin,default"}'

# Read User
# vault read -namespace=dev auth/ldap/users/admin
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/ldap/users/admin

# List Users
# vault list -namespace=dev auth/ldap/users
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/auth/ldap/users

# Create Group
# vault write -namespace=dev auth/ldap/groups/DevTeam policies=kv-read
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/ldap/groups/DevTeam -d '{"policies": "kv-read,default"}'

# Read Group
# vault read -namespace=dev auth/ldap/groups/DevTeam
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/ldap/groups/DevTeam

# List Groups
# vault list -namespace=dev auth/ldap/groups
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/auth/ldap/groups

# User Login
# vault login -method=ldap username=admin password=Password123456
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/ldap/login/admin -d '{"password": "Password123456"}'

# Delete User
# vault delete -namespace=dev auth/ldap/users/admin
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/auth/ldap/users/admin

# Delete Group
# vault delete -namespace=dev auth/ldap/groups/devteam
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/auth/ldap/groups/DevTeam

# Disable Auth
# vault auth disable -namespace=dev ldap
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/auth/ldap
