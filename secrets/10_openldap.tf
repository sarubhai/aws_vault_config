# Name: openldap.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Dynamic Secrets Engine For OpenLDAP
# The OpenLDAP secret engine allows management of LDAP entry passwords as well as dynamic creation of credentials.



/*
# Enable OpenLDAP
vault secrets enable -namespace=dev -path=openldap openldap
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/openldap -d '{"type": "openldap"}'

# List Secrets Engines
vault secrets list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/mounts

# Configure OpenLDAP
vault write -namespace=dev openldap/config url=ldap://10.0.1.100:389 binddn="cn=admin,dc=example,dc=com" bindpass=Password123456 insecure_tls=true userdn="dc=example,dc=com" groupdn="ou=Groups,dc=example,dc=com" groupfilter="(|(givenName={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}}))"
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/openldap/config -d '{"url": "ldap://10.0.1.100:389", "binddn": "cn=admin,dc=example,dc=com", "bindpass": "Password123456", "insecure_tls": true, "userdn": "dc=example,dc=com", "groupdn": "ou=Groups,dc=example,dc=com", "groupfilter": "(|(givenName={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}}))"}'

# Read Configuration
vault read -namespace=dev openldap/config
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/openldap/config

# Create Role
vault write -namespace=dev openldap/role/dynamic-role creation_ldif=@secrets/creation.ldif deletion_ldif=@secrets/deletion.ldif rollback_ldif=@secrets/rollback.ldif default_ttl=1h max_ttl=24h
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/openldap/role/dynamic-role -d '{"default_ttl": "1h", "max_ttl": "24h"}'

# Read Role
vault read -namespace=dev openldap/role/dynamic-role
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/openldap/role/dynamic-role

# List Roles
vault list -namespace=dev openldap/role
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/openldap/role

# Generate Credentials
vault read -namespace=dev openldap/creds/dynamic-role
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/openldap/creds/dynamic-role

# Test
# Login to LDAP admin with generated admin & password at http://10.0.1.100/ and verify the user

# Revoke Lease
vault lease revoke -namespace=dev -force -prefix openldap/creds

# Delete Role
vault delete -namespace=dev openldap/role/dynamic-role
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/openldap/role/dynamic-role

# Delete Configuration
vault delete -namespace=dev openldap/config
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/openldap/config

# Disable OpenLDAP
vault secrets disable -namespace=dev openldap
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/mounts/openldap
*/
