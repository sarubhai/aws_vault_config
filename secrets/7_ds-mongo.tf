# Name: ds-mongo.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Dynamic Secrets Engine For MongoDB database
# Generates database credentials dynamically based on configured roles for MongoDB database.

resource "vault_mount" "mongo" {
  path     = "mongo"
  type     = "database"
  provider = vault.root
}

resource "vault_database_secret_backend_connection" "mongo-con" {
  backend       = vault_mount.mongo.path
  name          = "db-mongo"
  allowed_roles = ["readonly"]

  mongodb {
    connection_url = "mongodb://root:${var.admin_password}@10.0.1.100:27017/admin?tls=false"
  }

  provider   = vault.root
  depends_on = [vault_mount.mongo]
}

resource "vault_database_secret_backend_role" "role-mongo" {
  backend             = vault_mount.mongo.path
  name                = "readonly"
  db_name             = vault_database_secret_backend_connection.mongo-con.name
  creation_statements = ["{ \"db\": \"admin\", \"roles\": [{ \"role\": \"readWrite\" }, {\"role\": \"read\", \"db\": \"foo\"}] }"]
  provider            = vault.root
  depends_on          = [vault_mount.mongo, vault_database_secret_backend_connection.mongo-con]
}


resource "vault_mount" "dev-mongo" {
  path       = "mongo"
  type       = "database"
  provider   = vault.dev
  depends_on = [var.dev_namespace]
}

resource "vault_database_secret_backend_connection" "dev-mongo-con" {
  backend       = vault_mount.dev-mongo.path
  name          = "db-mongo"
  allowed_roles = ["readonly"]

  mongodb {
    connection_url = "mongodb://root:${var.admin_password}@10.0.1.100:27017/admin?tls=false"
  }

  provider   = vault.dev
  depends_on = [var.dev_namespace, vault_mount.dev-mongo]
}

resource "vault_database_secret_backend_role" "dev-role-mongo" {
  backend             = vault_mount.dev-mongo.path
  name                = "readonly"
  db_name             = vault_database_secret_backend_connection.mongo-con.name
  creation_statements = ["{ \"db\": \"admin\", \"roles\": [{ \"role\": \"readWrite\" }, {\"role\": \"read\", \"db\": \"foo\"}] }"]
  provider            = vault.dev
  depends_on          = [var.dev_namespace, vault_mount.dev-mongo, vault_database_secret_backend_connection.dev-mongo-con]
}



/*
# Enable Database
vault secrets enable -namespace=dev -path=mongo database
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/mongo -d '{"type": "database"}'

# List Secrets Engines
vault secrets list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/mounts

# Configure Connection
vault write -namespace=dev mongo/config/db-mongo plugin_name=mongodb-database-plugin allowed_roles="readonly" connection_url="mongodb://{{username}}:{{password}}@10.0.1.100:27017/admin?tls=false" username="root" password=Password123456
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/mongo/config/db-mongo -d '{"plugin_name": "mongodb-database-plugin", "allowed_roles": "readonly", "connection_url": "mongodb://{{username}}:{{password}}@10.0.1.100:27017/admin?tls=false", "username": "root", "password": Password123456}'

# Read Connection
vault read -namespace=dev mongo/config/db-mongo
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/mongo/config/db-mongo

# List Connections
vault list -namespace=dev mongo/config
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/mongo/config

# Create Role
vault write -namespace=dev mongo/roles/readonly db_name=db-mongo creation_statements='{ "db": "admin", "roles": [{ "role": "readWrite" }, {"role": "read", "db": "foo"}] }' default_ttl="1h" max_ttl="24h"
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/mongo/roles/readonly -d '{"db_name": "db-mongo", "creation_statements": ['{ "db": "admin", "roles": [{ "role": "readWrite" }, {"role": "read", "db": "foo"}] }'], "default_ttl": "1h", "max_ttl": "24h"}'

# Read Role
vault read -namespace=dev mongo/roles/readonly
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/mongo/roles/readonly

# List Roles
vault list -namespace=dev mongo/roles
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/mongo/roles

# Generate Credentials
vault read -namespace=dev mongo/creds/readonly
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/mongo/creds/readonly

# Test
mongo -u v-root-readonly-gRcz8UlwQ6Uzne0d -h 127.0.0.1 -p

# Revoke Lease
vault lease revoke -namespace=dev -force -prefix mongo/creds

# Delete Role
vault delete -namespace=dev mongo/roles/readonly
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/mongo/roles/readonly

# Delete Connection
vault delete -namespace=dev mongo/config/db-mongo
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/mongo/config/db-mongo

# Disable Database
vault secrets disable -namespace=dev mongo
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/mounts/mongo
*/
