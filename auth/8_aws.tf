# Name: aws.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault AWS Auth Method
# The aws auth method provides an automated mechanism to retrieve a Vault token for IAM principals and AWS EC2 instances.

resource "vault_auth_backend" "aws" {
  type     = "aws"
  path     = "aws"
  provider = vault.root
}

resource "vault_aws_auth_backend_client" "aws_cli" {
  backend    = vault_auth_backend.aws.path
  access_key = var.auth_aws_access_key
  secret_key = var.auth_aws_secret_key
  iam_server_id_header_value = "dc1-vault1.local"
  provider   = vault.root
  depends_on = [vault_auth_backend.aws]
}

resource "vault_aws_auth_backend_role" "webapp" {
  backend                  = vault_auth_backend.aws.path
  role                     = "webapp"
  auth_type                = "iam"
  bound_iam_principal_arns = ["arn:aws:iam::${var.aws_account_id}:*"]
  token_policies           = ["admin"]
  token_ttl                = 60
  token_max_ttl            = 120
  provider                 = vault.root
  depends_on               = [vault_auth_backend.aws]
}



resource "vault_auth_backend" "dev_aws" {
  type       = "aws"
  path       = "aws"
  provider   = vault.dev
  depends_on = [var.dev_namespace]
}

resource "vault_aws_auth_backend_client" "dev_aws_cli" {
  backend    = vault_auth_backend.dev_aws.path
  access_key = var.auth_aws_access_key
  secret_key = var.auth_aws_secret_key
  iam_server_id_header_value = "dc1-vault1.local"
  provider   = vault.dev
  depends_on = [var.dev_namespace, vault_auth_backend.dev_aws]
}

resource "vault_aws_auth_backend_role" "dev_webapp" {
  backend                  = vault_auth_backend.dev_aws.path
  role                     = "dev-webapp"
  auth_type                = "iam"
  bound_iam_principal_arns = ["arn:aws:iam::${var.aws_account_id}:*"]
  token_policies           = ["kv-read"]
  token_ttl                = 60
  token_max_ttl            = 120
  provider                 = vault.dev
  depends_on               = [var.dev_namespace, vault_auth_backend.dev_aws]
}



/*
# Enable Auth
vault auth enable -namespace=dev -path=aws aws
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/auth/aws -d '{"type": "aws"}'

# List Auth
vault auth list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/auth

# Configure AWS Client
# https://www.vaultproject.io/docs/auth/aws#recommended-vault-iam-policy
# export AWS_ACCESS_KEY_ID=ABCDEFGHIJKLMNOPQRST
# export AWS_SECRET_ACCESS_KEY=ABCDEFGHIJ1234567890KLMNOPQRST
vault write -namespace=dev auth/aws/config/client access_key=ABCDEFGHIJKLMNOPQRST secret_key=ABCDEFGHIJ1234567890KLMNOPQRST iam_server_id_header_value=dc1-vault1.local
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/aws/config/client -d '{"access_key":"ABCDEFGHIJKLMNOPQRST", "secret_key": "ABCDEFGHIJ1234567890KLMNOPQRST", "iam_server_id_header_value": "dc1-vault1.local"}'

# Read AWS Client Config
vault read -namespace=dev auth/aws/config/client
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/aws/config/client

# Create AWS Role
vault write -namespace=dev auth/aws/role/dev-webapp auth_type=iam bound_iam_principal_arn=arn:aws:iam::123456789012:* policies=kv-read
vault write -namespace=dev auth/aws/role/dev-webapp auth_type=ec2 policies=kv-read
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/aws/role/dev-webapp -d '{"auth_type": "iam", "bound_iam_principal_arn": "arn:aws:iam::123456789012:*", "policies": "kv-read"}'
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/aws/role/dev-webapp -d '{"auth_type": "ec2", "policies": "kv-read"}'

# Read AWS Role
vault read -namespace=dev auth/aws/role/dev-webapp
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/aws/role/dev-webapp

# List AWS Roles
# vault list -namespace=dev auth/aws/role
# curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/auth/aws/role

# AWS Role Login
vault login -namespace=dev -method=aws header_value=dc1-vault1.local role=dev-webapp
curl -H "X-Vault-Namespace: $VAULT_NAMESPACE" -H "X-Vault-AWS-IAM-Server-ID: dc1-vault1.local" -X POST $VAULT_ADDR/v1/auth/aws/login -d '{"header_value": "dc1-vault1.local", "role": "dev-webapp", "iam_request_body": "QWN0aW9uPUdldENhbGxlcklkZW50aXR5JlZlcnNpb249MjAxMS0wNi0xNQ=="}'

# Delete AWS Role
vault delete -namespace=dev auth/aws/role/dev-webapp
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/auth/aws/role/dev-webapp

# Delete AWS Client Config
vault delete -namespace=dev auth/aws/config/client
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/auth/aws/config/client

# Disable Auth
vault auth disable -namespace=dev aws
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/auth/aws
*/
