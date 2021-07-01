# variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create Vault Auth Methods

variable "dev_namespace" {
  description = "The dev namespace."
}

variable "admin_password" {
  description = "Admin password for UserPass Auth."
}

variable "okta_org" {
  description = "Okta Organization."
}

variable "github_org" {
  description = "Github Organization Name."
}

variable "github_user" {
  description = "Github User Name."
}

variable "github_team" {
  description = "Github Team Name."
}

variable "ca_cert_path" {
  description = "CA Certificate file path for TLS Auth."
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
