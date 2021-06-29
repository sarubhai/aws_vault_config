# Name: rabbitmq.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Dynamic Secrets Engine For RabbitMQ

resource "vault_rabbitmq_secret_backend" "rabbitmq" {
  connection_uri = "http://10.0.1.100:15672"
  username       = "rabbitmq"
  password       = var.admin_password
  provider       = vault.root
}

resource "vault_rabbitmq_secret_backend_role" "role-rabbitmq" {
  backend = vault_rabbitmq_secret_backend.rabbitmq.path
  name    = "deploy"

  vhost {
    host      = "/"
    configure = ".*"
    write     = ".*"
    read      = ".*"
  }

  provider   = vault.root
  depends_on = [vault_rabbitmq_secret_backend.rabbitmq]
}


resource "vault_rabbitmq_secret_backend" "dev-rabbitmq" {
  connection_uri = "http://10.0.1.100:15672"
  username       = "rabbitmq"
  password       = var.admin_password
  provider       = vault.dev
  depends_on     = [var.dev_namespace]
}

resource "vault_rabbitmq_secret_backend_role" "dev-role-rabbitmq" {
  backend = vault_rabbitmq_secret_backend.dev-rabbitmq.path
  name    = "deploy"

  vhost {
    host      = "/"
    configure = ".*"
    write     = ".*"
    read      = ".*"
  }

  provider   = vault.dev
  depends_on = [var.dev_namespace, vault_rabbitmq_secret_backend.dev-rabbitmq]
}



# Enable RabbitMQ
# vault secrets enable -namespace=dev -path=rabbitmq rabbitmq
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/rabbitmq -d '{"type": "rabbitmq"}'

# List Secrets Engines
# vault secrets list -namespace=dev
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/mounts

# Configure Connection
# vault write -namespace=dev rabbitmq/config/connection connection_uri=http://10.0.1.100:15672 username="rabbitmq" password=Password123456
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/rabbitmq/config/connection -d '{"connection_uri": "http://10.0.1.100:15672","username": "rabbitmq","password": Password123456}'

# Create Role
# vault write -namespace=dev rabbitmq/roles/deploy vhosts='{"/":{"configure": ".*", "write": ".*", "read": ".*"}}'
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/rabbitmq/roles/deploy -d '{"vhosts": "{\"/\": {\"configure\":\".*\", \"write\":\".*\", \"read\": \".*\"}}"}'

# Read Role
# vault read -namespace=dev rabbitmq/roles/deploy
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/rabbitmq/roles/deploy

# List Roles
# vault list -namespace=dev rabbitmq/roles
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/rabbitmq/roles

# Generate Credentials
# vault read -namespace=dev rabbitmq/creds/deploy
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/rabbitmq/creds/deploy

# Login to Rabbitmq with user root-53a9bafc-d210-0518-6195-e3cb8aaa83ec http://10.0.1.100:15672
# vault lease revoke -namespace=dev -force -prefix rabbitmq/creds

# Delete Role
# vault delete -namespace=dev rabbitmq/roles/deploy
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/rabbitmq/roles/deploy

# Disable RabbitMQ
# vault secrets disable -namespace=dev rabbitmq
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/mounts/rabbitmq
