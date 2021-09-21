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
}

variable "auth_aws_access_key" {
  description = "AWS Access Key to setup Vault Auth method."
}

variable "auth_aws_secret_key" {
  description = "AWS Secret Key to setup Vault Auth method."
}

variable "kubernetes_ca_cert" {
  description = "Kubernetes CA Certificate Path to setup Vault Auth method."
}

variable "kubernetes_token_reviewer_jwt" {
  description = "Kubernetes Service Account JWT Token to setup Vault Auth method."
}
