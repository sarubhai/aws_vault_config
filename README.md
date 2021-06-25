# Vault Configuration:
Configure Vault cluster using Terraform

## Manage Secrets and Protect Sensitive Data
Secure, store and tightly control access to tokens, passwords, certificates, encryption keys for protecting secrets and other sensitive data using a UI, CLI, or HTTP API.

### Auth Methods
Auth methods are the components in Vault that perform authentication and are responsible for assigning identity and a set of policies to a user.

Types:
- Tokens
- UserPass
- AppRole
- LDAP
- Okta, GitHub, RADIUS, Cloud Foundry
- AWS, Azure, GoogleCloud, AliCloud, OracleCloudInfrastructure
- Kubernetes
- TLS Certs
- Kerberos
- JWT/OIDC

### Secrets Engine
Secrets engines are components which store, generate, or encrypt data. 
Some secrets engines 
. simply store and read data
. connect to other services and generate dynamic credentials on demand 
. allows Vault to encode and decode sensitive values residing in external systems such as databases or file systems
. provide encryption as a service
. totp generation
. certificates

Types:
- Key/Value
- Transit
- Dynamic
    - Databases ()
    - AWS, Azure, GoogleCloud, GoogleCloud KMS, AliCloud,
    - Active Directory
    - Consul
    - Key Management
    - Open LDAP
    - RabbitMQ
- Transform

- SSH
- TOTP
- PKI

### Policies
Policies provide a declarative way to grant or forbid access to certain paths and operations in Vault.

### Audit Devices
Audit devices are the components in Vault that keep a detailed log of all requests and response to Vault.