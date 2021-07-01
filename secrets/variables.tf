# variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create Vault Secrets Engines

variable "dev_namespace" {
  description = "The dev namespace."
}

variable "admin_password" {
  description = "Admin password for UserPass Auth."
}

variable "secrets_aws_access_key" {
  description = "AWS Access Key to setup Vault Secrets engine."
  default     = "ABCDEFGHIJKLMNOPQRST"
}

variable "secrets_aws_secret_key" {
  description = "AWS Secret Key to setup Vault Secrets engine."
  default     = "ABCDEFGHIJ1234567890KLMNOPQRST"
}
