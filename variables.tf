# variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create the infrastructure resources for Vault Configuration
# https://www.terraform.io/docs/configuration/variables.html

# Vault Provider
/*
variable "address" {
  description = "Origin URL of the Vault server."
  default     = "http://127.0.0.1:8200"
}

variable "token" {
  description = "Vault token that will be used by Terraform to authenticate."
  default     = "s.yzr0jQlTPsWc3mB2dHeS3D3J"
}

variable "namespace" {
  description = "Set the namespace to use."
  default     = "dev"
}
*/

variable "admin_password" {
  description = "Admin password for UserPass Auth."
  default     = "Password123456"
}

variable "okta_org" {
  description = "Okta Organization."
  default     = "dev-123456"
}

variable "github_org" {
  description = "Github Organization Name."
  default     = "example"
}

variable "github_user" {
  description = "Github User Name."
  default     = "johndoe"
}

variable "github_team" {
  description = "Github Team Name."
  default     = "devops"
}

variable "ca_cert_path" {
  description = "CA Certificate file path for TLS Auth."
  default     = "/etc/pki/tls/cert.pem"
}

variable "aws_account_id" {
  description = "AWS Account Id."
  default     = "123456789012"
}

variable "auth_aws_access_key" {
  description = "AWS Access Key to setup Vault Auth method."
  default     = "ABCDEFGHIJKLMNOPQRST"
}

variable "auth_aws_secret_key" {
  description = "AWS Secret Key to setup Vault Auth method."
  default     = "ABCDEFGHIJ1234567890KLMNOPQRST"
}

variable "secrets_aws_access_key" {
  description = "AWS Access Key to setup Vault Secrets engine."
  default     = "ABCDEFGHIJKLMNOPQRST"
}

variable "secrets_aws_secret_key" {
  description = "AWS Secret Key to setup Vault Secrets engine."
  default     = "ABCDEFGHIJ1234567890KLMNOPQRST"
}
