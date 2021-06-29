# Name: ds-mysql.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Dynamic Secrets Engine For MySQL database

resource "vault_mount" "mysql" {
  path     = "mysql"
  type     = "database"
  provider = vault.root
}

resource "vault_database_secret_backend_connection" "mysql-con" {
  backend       = vault_mount.mysql.path
  name          = "db-mysql"
  allowed_roles = ["readonly"]

  mysql {
    connection_url = "root:${var.admin_password}@tcp(10.0.1.100:3306)/"
  }

  provider   = vault.root
  depends_on = [vault_mount.mysql]
}

resource "vault_database_secret_backend_role" "role-mysql" {
  backend             = vault_mount.mysql.path
  name                = "readonly"
  db_name             = vault_database_secret_backend_connection.mysql-con.name
  creation_statements = ["CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT SELECT ON *.* TO '{{name}}'@'%';"]
  provider            = vault.root
  depends_on          = [vault_mount.mysql, vault_database_secret_backend_connection.mysql-con]
}


resource "vault_mount" "dev-mysql" {
  path       = "mysql"
  type       = "database"
  provider   = vault.dev
  depends_on = [var.dev_namespace]
}

resource "vault_database_secret_backend_connection" "dev-mysql-con" {
  backend       = vault_mount.dev-mysql.path
  name          = "db-mysql"
  allowed_roles = ["readonly"]

  mysql {
    connection_url = "root:${var.admin_password}@tcp(10.0.1.100:3306)/"
  }

  provider   = vault.dev
  depends_on = [var.dev_namespace, vault_mount.dev-mysql]
}

resource "vault_database_secret_backend_role" "dev-role-mysql" {
  backend             = vault_mount.dev-mysql.path
  name                = "readonly"
  db_name             = vault_database_secret_backend_connection.mysql-con.name
  creation_statements = ["CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT SELECT ON *.* TO '{{name}}'@'%';"]
  provider            = vault.dev
  depends_on          = [var.dev_namespace, vault_mount.dev-mysql, vault_database_secret_backend_connection.dev-mysql-con]
}



# Enable Database
# vault secrets enable -namespace=dev -path=mysql database
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/mysql -d '{"type": "database"}'

# List Secrets Engines
# vault secrets list -namespace=dev
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/mounts

# Configure Connection
# vault write -namespace=dev mysql/config/db-mysql plugin_name=mysql-database-plugin allowed_roles="readonly" connection_url="{{username}}:{{password}}@tcp(10.0.1.100:3306)/" username="root" password=Password123456
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/mysql/config/db-mysql -d '{"plugin_name": "mysql-database-plugin","allowed_roles": "readonly","connection_url": "{{username}}:{{password}}@tcp(10.0.1.100:3306)/","username": "root","password": Password123456}'

# Read Connection
# vault read -namespace=dev mysql/config/db-mysql
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/mysql/config/db-mysql

# List Connections
# vault list -namespace=dev mysql/config
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/mysql/config

# Create Role
# vault write -namespace=dev mysql/roles/readonly db_name=db-mysql creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT SELECT ON *.* TO '{{name}}'@'%';" default_ttl="1h" max_ttl="24h"
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/mysql/roles/readonly -d '{"db_name": "db-mysql","creation_statements": ["CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT SELECT ON *.* TO '{{name}}'@'%';"],"default_ttl": "1h","max_ttl": "24h"}'

# Read Role
# vault read -namespace=dev mysql/roles/readonly
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/mysql/roles/readonly

# List Roles
# vault list -namespace=dev mysql/roles
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/mysql/roles

# Generate Credentials
# vault read -namespace=dev mysql/creds/readonly
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/mysql/creds/readonly

# mysql -u v-root-readonly-gRcz8UlwQ6Uzne0d -h 127.0.0.1 -p
# vault lease revoke -namespace=dev -force -prefix mysql/creds

# Delete Role
# vault delete -namespace=dev mysql/roles/readonly
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/mysql/roles/readonly

# Delete Connection
# vault delete -namespace=dev mysql/config/db-mysql
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/mysql/config/db-mysql

# Disable Database
# vault secrets disable -namespace=dev mysql
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/mounts/mysql
