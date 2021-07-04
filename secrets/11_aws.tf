# Name: aws.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Dynamic Secrets Engine For AWS
# The AWS secrets engine generates AWS access credentials dynamically based on IAM policies.
# The AWS IAM credentials are time-based and are automatically revoked when the Vault lease expires.

resource "vault_aws_secret_backend" "aws" {
  path                      = "aws"
  access_key                = var.secrets_aws_access_key
  secret_key                = var.secrets_aws_secret_key
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
  provider                  = vault.root
}

resource "vault_aws_secret_backend_role" "role-aws" {
  backend         = vault_aws_secret_backend.aws.path
  name            = "deploy"
  credential_type = "iam_user"
  policy_document = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    }
  ]
}
EOT
  provider        = vault.root
  depends_on      = [vault_aws_secret_backend.aws]
}


resource "vault_aws_secret_backend" "dev-aws" {
  path                      = "aws"
  access_key                = var.secrets_aws_access_key
  secret_key                = var.secrets_aws_secret_key
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
  provider                  = vault.dev
  depends_on                = [var.dev_namespace]
}

resource "vault_aws_secret_backend_role" "dev-role-aws" {
  backend         = vault_aws_secret_backend.dev-aws.path
  name            = "deploy"
  credential_type = "iam_user"
  policy_document = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    }
  ]
}
EOT
  provider        = vault.dev
  depends_on      = [var.dev_namespace, vault_aws_secret_backend.dev-aws]
}



/*
# Enable AWS
vault secrets enable -namespace=dev -path=aws aws
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/mounts/aws -d '{"type": "aws"}'

# List Secrets Engines
vault secrets list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/mounts

# Configure AWS
# export AWS_ACCESS_KEY_ID=ABCDEFGHIJKLMNOPQRST
# export AWS_SECRET_ACCESS_KEY=ABCDEFGHIJ1234567890KLMNOPQRST
vault write -namespace=dev aws/config/root access_key="ABCDEFGHIJKLMNOPQRST" secret_key="ABCDEFGHIJ1234567890KLMNOPQRST"
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/aws/config/root -d '{"access_key": "ABCDEFGHIJKLMNOPQRST", "secret_key": "ABCDEFGHIJ1234567890KLMNOPQRST"}'

# Read AWS
vault read -namespace=dev aws/config/root
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/aws/config/root

# Configure Lease
vault write -namespace=dev aws/config/lease lease="1h" lease_max="24h"
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/aws/config/lease -d '{"lease": "1h", "lease_max": "24h"}'

# Read Lease
vault read -namespace=dev aws/config/lease
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/aws/config/lease

# Create Role
vault write -namespace=dev aws/roles/deploy credential_type=iam_user policy_document="{\"Version\": \"2012-10-17\",\"Statement\": [{\"Effect\": \"Allow\",\"Action\": \"ec2:*\",\"Resource\": \"*\"}]}"
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/aws/roles/deploy -d '{"credential_type": "iam_user", "policy_document": "{\"Version\": \"2012-10-17\",\"Statement\": [{\"Effect\": \"Allow\",\"Action\": \"ec2:*\",\"Resource\": \"*\"}]}"}'

# Read Role
vault read -namespace=dev aws/roles/deploy
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/aws/roles/deploy

# List Roles
vault list -namespace=dev aws/roles
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/aws/roles

# Generate Credentials
vault read -namespace=dev aws/creds/deploy
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/aws/creds/deploy

# Test
# Login to AWS Console at https://console.aws.amazon.com/iam/home?#/users and verify the newly generated user

# Revoke Lease
vault lease revoke -namespace=dev -force -prefix aws/creds

# Delete Role
vault delete -namespace=dev aws/roles/deploy
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/aws/roles/deploy

# Delete AWS
vault delete -namespace=dev aws/config/root
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/aws/config/root

# Disable Database
vault secrets disable -namespace=dev aws
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/mounts/aws
*/
