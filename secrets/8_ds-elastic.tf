# Name: ds-elastic.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Dynamic Secrets Engine For Elasticsearch database
# Generates database credentials dynamically based on configured roles for Elasticsearch database.

resource "vault_mount" "elastic" {
  path     = "elastic"
  type     = "database"
  provider = vault.root
}

resource "vault_database_secret_backend_connection" "elastic-con" {
  backend       = vault_mount.elastic.path
  name          = "db-elastic"
  allowed_roles = ["readonly"]

  elasticsearch {
    url      = "http://10.0.1.100:9200"
    username = "elastic"
    password = var.admin_password
  }

  provider   = vault.root
  depends_on = [vault_mount.elastic]
}

resource "vault_database_secret_backend_role" "role-elastic" {
  backend             = vault_mount.elastic.path
  name                = "readonly"
  db_name             = vault_database_secret_backend_connection.elastic-con.name
  creation_statements = ["{\"elasticsearch_roles\": [\"kibana_admin\"]}"]
  provider            = vault.root
  depends_on          = [vault_mount.elastic, vault_database_secret_backend_connection.elastic-con]
}


resource "vault_mount" "dev-elastic" {
  path       = "elastic"
  type       = "database"
  provider   = vault.dev
  depends_on = [var.dev_namespace]
}

resource "vault_database_secret_backend_connection" "dev-elastic-con" {
  backend       = vault_mount.dev-elastic.path
  name          = "db-elastic"
  allowed_roles = ["readonly"]

  elasticsearch {
    url      = "http://10.0.1.100:9200"
    username = "elastic"
    password = var.admin_password
  }

  provider   = vault.dev
  depends_on = [var.dev_namespace, vault_mount.dev-elastic]
}

resource "vault_database_secret_backend_role" "dev-role-elastic" {
  backend             = vault_mount.dev-elastic.path
  name                = "readonly"
  db_name             = vault_database_secret_backend_connection.elastic-con.name
  creation_statements = ["{\"elasticsearch_roles\": [\"kibana_admin\"]}"]
  provider            = vault.dev
  depends_on          = [var.dev_namespace, vault_mount.dev-elastic, vault_database_secret_backend_connection.dev-elastic-con]
}



/*
# Enable Database
vault secrets enable -namespace=dev -path=elastic database
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/elastic -d '{"type": "database"}'

# List Secrets Engines
vault secrets list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/mounts

# Configure Connection
vault write -namespace=dev elastic/config/db-elastic plugin_name=elasticsearch-database-plugin allowed_roles="readonly" url="http://10.0.1.100:9200" username="elastic" password=Password123456
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/elastic/config/db-elastic -d '{"plugin_name": "elasticsearch-database-plugin", "allowed_roles": "readonly", "url": "http://10.0.1.100:9200", "username": "elastic", "password": Password123456}'

# Read Connection
vault read -namespace=dev elastic/config/db-elastic
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/elastic/config/db-elastic

# List Connections
vault list -namespace=dev elastic/config
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/elastic/config

# Create Role
vault write -namespace=dev elastic/roles/readonly db_name=db-elastic creation_statements='{"elasticsearch_roles": ["kibana_admin"]}' default_ttl="1h" max_ttl="24h"
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/elastic/roles/readonly -d '{"db_name": "db-elastic", "creation_statements": ['{"elasticsearch_roles": ["kibana_admin"]}'], "default_ttl": "1h", "max_ttl": "24h"}'

# Read Role
vault read -namespace=dev elastic/roles/readonly
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/elastic/roles/readonly

# List Roles
vault list -namespace=dev elastic/roles
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/elastic/roles

# Generate Credentials
vault read -namespace=dev elastic/creds/readonly
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/elastic/creds/readonly

# Test
# Login to Kibana with generated username & password at http://10.0.1.100:5600

# Revoke Lease
vault lease revoke -namespace=dev -force -prefix elastic/creds

# Delete Role
vault delete -namespace=dev elastic/roles/readonly
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/elastic/roles/readonly

# Delete Connection
vault delete -namespace=dev elastic/config/db-elastic
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/elastic/config/db-elastic

# Disable Database
vault secrets disable -namespace=dev elastic
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/mounts/elastic
*/
