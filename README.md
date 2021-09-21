# Vault Configuration:

Configure Vault cluster using Terraform.

Various Vault Configurations of Auth, Secrets etc. using CLI, API & terraform Automation All In One place.

Refer to the below link to setup Vault Cluster in AWS using Terraform

- Use [https://github.com/sarubhai/aws_vault](https://github.com/sarubhai/aws_vault)

## Manage Secrets and Protect Sensitive Data

Secure, store and tightly control access to tokens, passwords, certificates, encryption keys for protecting secrets and other sensitive data using a UI, CLI, or HTTP API.

### Auth Methods

Auth methods are the components in Vault that perform authentication and are responsible for assigning identity and a set of policies to a user.

Types:

- Tokens
- UserPass
- AppRole
- LDAP
- Okta
- GitHub, [RADIUS, Cloud Foundry]
- TLS Certificates
- AWS, [Azure, GoogleCloud, AliCloud, OracleCloudInfrastructure]
- Kubernetes
- [Kerberos]
- [JWT/OIDC]

### Secrets Engine

Secrets engines are components which store, generate, or encrypt data.
Some secrets engines
. simply store and read data
. connect to other services and generate dynamic credentials on demand
. allows to encode and decode sensitive values residing in external systems
. provide encryption as a service
. generate/validate totp
. generate certificates

Types:

- Key/Value
- Transit
- Transform
- Dynamic
  - Databases
    - Elasticsearch
    - MongoDB
    - MySQL
    - Oracle
    - PostgreSQL
  - RabbitMQ
  - Open LDAP
  - AWS, [Azure, GoogleCloud, GoogleCloud KMS, AliCloud]
  - [Active Directory]
  - [Consul]
- TOTP
- PKI
- [SSH]
- [KMIP]
- Key Management
  - [AWS KMS]
  - [Azure Key Vault]

Note: \* [TO-DO]

### Policies

Policies provide a declarative way to grant or forbid access to certain paths and operations in Vault.

### Audit Devices

Audit devices are the components in Vault that keep a detailed log of all requests and response to Vault.

### Prerequisite

Terraform is already installed in local machine.

## Usage

- Clone this repository
- Add the below variable values in terraform.tfvars file under the root directory

### terraform.tfvars

```
admin_password = "Password123456"

okta_org = "dev-12345678"

github_org = "example"

github_user = "johndoe"

github_team = "devops"

ca_cert_path = "/etc/ssl/certs/ca.cert"

aws_account_id = "123456789012"

auth_aws_access_key = "ABCDEFGHIJKLMNOPQRST"

auth_aws_secret_key = "ABCDEFGHIJ1234567890KLMNOPQRST"

secrets_aws_access_key = "ABCDEFGHIJKLMNOPQRYZ"

secrets_aws_secret_key = "ABCDEFGHIJ1234567890KLMNOPQRYZ"

kubernetes_ca_cert = "/Users/John/.minikube/ca.crt"

kubernetes_token_reviewer_jwt = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjJnZ..."

```

- Change other variables in variables.tf file if needed

- From Command Line, set the Vault Login credentials

```
export VAULT_ADDR=https://dc1-vault1.local:8200
export VAULT_TOKEN=s.ZaXY7yVwKBKalAjmCJTMy3y3
vault status
```

- terraform init
- terraform plan
- terraform apply -auto-approve -refresh=false

- Finally login to Vault UI https://dc1-vault1.local:8200/ui to validate the configurations
- Login with root token or UserPass method with admin & admin_password
