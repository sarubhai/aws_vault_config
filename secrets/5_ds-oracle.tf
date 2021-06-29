# Name: ds-oracle.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Dynamic Secrets Engine For Oracle database

# resource "vault_mount" "oracle" {
#   path     = "oracle"
#   type     = "database"
#   provider = vault.root
# }

# resource "vault_database_secret_backend_connection" "oracle-con" {
#   backend       = vault_mount.oracle.path
#   name          = "db-oracle"
#   allowed_roles = ["readonly"]

#   oracle {
#     connection_url = "postgres://postgres:${var.admin_password}@10.0.1.100:5432/postgres?sslmode=disable"
#   }

#   provider   = vault.root
#   depends_on = [vault_mount.oracle]
# }

# resource "vault_database_secret_backend_role" "role-oracle" {
#   backend             = vault_mount.oracle.path
#   name                = "readonly"
#   db_name             = vault_database_secret_backend_connection.oracle-con.name
#   creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"]
#   provider   = vault.root
#   depends_on = [vault_mount.oracle, vault_database_secret_backend_connection.oracle-con]
# }


# resource "vault_mount" "dev-oracle" {
#   path     = "oracle"
#   type     = "database"
#   provider = vault.dev
#   depends_on = [var.dev_namespace]
# }

# resource "vault_database_secret_backend_connection" "dev-oracle-con" {
#   backend       = vault_mount.dev-oracle.path
#   name          = "db-oracle"
#   allowed_roles = ["readonly"]

#   oracle {
#     connection_url = "postgres://postgres:${var.admin_password}@10.0.1.100:5432/postgres?sslmode=disable"
#   }

#   provider   = vault.dev
#   depends_on = [var.dev_namespace, vault_mount.dev-oracle]
# }

# resource "vault_database_secret_backend_role" "dev-role-oracle" {
#   backend             = vault_mount.dev-oracle.path
#   name                = "readonly"
#   db_name             = vault_database_secret_backend_connection.oracle-con.name
#   creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"]
#   provider   = vault.dev
#   depends_on = [var.dev_namespace, vault_mount.dev-oracle, vault_database_secret_backend_connection.dev-oracle-con]
# }



# Enable Database
# vault secrets enable -namespace=dev -path=oracle database
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/oracle -d '{"type": "database"}'

# List Secrets Engines
# vault secrets list -namespace=dev
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/mounts

# Configure Connection
# vault write -namespace=dev oracle/config/db-oracle plugin_name=oracle-database-plugin allowed_roles="readonly" connection_url="{{username}}/{{password}}@10.0.1.100:1521/XE" username="orcl_user" password=$admin_password
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/oracle/config/db-postgres -d '{"plugin_name": "postgresql-database-plugin","allowed_roles": "readonly","connection_url": "postgresql://{{username}}:{{password}}@10.0.1.100:5432/postgres?sslmode=disable","username": "postgres","password": $admin_password}'

# Read Connection
# vault read -namespace=dev oracle/config/db-oracle
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/oracle/config/db-oracle

# List Connections
# vault list -namespace=dev oracle/config
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/oracle/config

# Create Role
# vault write -namespace=dev oracle/roles/readonly db_name=db-oracle creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" default_ttl="1h" max_ttl="24h"
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/oracle/roles/readonly -d '{"db_name": "db-postgres","creation_statements": ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"],"default_ttl": "1h","max_ttl": "24h"}'

# Read Role
# vault read -namespace=dev oracle/roles/readonly
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/oracle/roles/readonly

# List Roles
# vault list -namespace=dev oracle/roles
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/oracle/roles

# Generate Credentials
# vault read -namespace=dev oracle/creds/readonly
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/oracle/creds/readonly

# psql -U v-root-readonly-zrP4BPxxGIvMI0a55QCf-1624939463 -h 127.0.0.1 -W -d postgres
# vault lease revoke -namespace=dev -force -prefix oracle/creds

# Delete Role
# vault delete -namespace=dev oracle/roles/readonly
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/oracle/roles/readonly

# Delete Connection
# vault delete -namespace=dev oracle/config/db-oracle
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/oracle/config/db-oracle

# Disable Database
# vault secrets disable -namespace=dev oracle
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/mounts/oracle
