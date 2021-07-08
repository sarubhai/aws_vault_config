# Name: ds-postgres.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Dynamic Secrets Engine For PostgreSQL database
# Generates database credentials dynamically based on configured roles for PostgreSQL database.

resource "vault_mount" "postgres" {
  path     = "postgres"
  type     = "database"
  provider = vault.root
}

resource "vault_database_secret_backend_connection" "postgres-con" {
  backend       = vault_mount.postgres.path
  name          = "db-postgres"
  allowed_roles = ["readonly"]

  postgresql {
    connection_url = "postgres://postgres:${var.admin_password}@10.0.1.100:5432/postgres?sslmode=disable"
  }

  provider   = vault.root
  depends_on = [vault_mount.postgres]
}

resource "vault_database_secret_backend_role" "role-postgres" {
  backend               = vault_mount.postgres.path
  name                  = "readonly"
  db_name               = vault_database_secret_backend_connection.postgres-con.name
  creation_statements   = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"]
  revocation_statements = ["SET ROLE postgres; DROP ROLE IF EXISTS \"{{name}}\";"]
  default_ttl           = 3600
  max_ttl               = 86400
  provider              = vault.root
  depends_on            = [vault_mount.postgres, vault_database_secret_backend_connection.postgres-con]
}


resource "vault_mount" "dev-postgres" {
  path       = "postgres"
  type       = "database"
  provider   = vault.dev
  depends_on = [var.dev_namespace]
}

resource "vault_database_secret_backend_connection" "dev-postgres-con" {
  backend       = vault_mount.dev-postgres.path
  name          = "db-postgres"
  allowed_roles = ["readonly"]

  postgresql {
    connection_url = "postgres://postgres:${var.admin_password}@10.0.1.100:5432/postgres?sslmode=disable"
  }

  provider   = vault.dev
  depends_on = [var.dev_namespace, vault_mount.dev-postgres]
}

resource "vault_database_secret_backend_role" "dev-role-postgres" {
  backend               = vault_mount.dev-postgres.path
  name                  = "readonly"
  db_name               = vault_database_secret_backend_connection.postgres-con.name
  creation_statements   = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"]
  revocation_statements = ["SET ROLE postgres; DROP ROLE IF EXISTS \"{{name}}\";"]
  default_ttl           = 3600
  max_ttl               = 7200
  provider              = vault.dev
  depends_on            = [var.dev_namespace, vault_mount.dev-postgres, vault_database_secret_backend_connection.dev-postgres-con]
}



/*
# Enable Database
vault secrets enable -namespace=dev -path=postgres database
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/postgres -d '{"type": "database"}'

# List Secrets Engines
vault secrets list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/mounts

# Configure Connection
vault write -namespace=dev postgres/config/db-postgres plugin_name=postgresql-database-plugin allowed_roles="readonly" connection_url="postgresql://{{username}}:{{password}}@10.0.1.100:5432/postgres?sslmode=disable" username="postgres" password=Password123456
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/postgres/config/db-postgres -d '{"plugin_name": "postgresql-database-plugin", "allowed_roles": "readonly", "connection_url": "postgresql://{{username}}:{{password}}@10.0.1.100:5432/postgres?sslmode=disable", "username": "postgres", "password": Password123456}'

# Read Connection
vault read -namespace=dev postgres/config/db-postgres
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/postgres/config/db-postgres

# List Connections
vault list -namespace=dev postgres/config
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/postgres/config

# Create Role
vault write -namespace=dev postgres/roles/readonly db_name=db-postgres creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" default_ttl="1h" max_ttl="24h"
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/postgres/roles/readonly -d '{"db_name": "db-postgres", "creation_statements": ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"], "default_ttl": "1h", "max_ttl": "24h"}'

# Read Role
vault read -namespace=dev postgres/roles/readonly
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/postgres/roles/readonly

# List Roles
vault list -namespace=dev postgres/roles
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/postgres/roles

# Generate Credentials
vault read -namespace=dev postgres/creds/readonly
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/postgres/creds/readonly

# Test
psql -U v-root-readonly-zrP4BPxxGIvMI0a55QCf-1624939463 -h 127.0.0.1 -W -d postgres

# Revoke Lease
vault lease revoke -namespace=dev -force -prefix postgres/creds

# Delete Role
vault delete -namespace=dev postgres/roles/readonly
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/postgres/roles/readonly

# Delete Connection
vault delete -namespace=dev postgres/config/db-postgres
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/postgres/config/db-postgres

# Disable Database
vault secrets disable -namespace=dev postgres
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/mounts/postgres
*/
