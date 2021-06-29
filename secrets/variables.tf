# variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create Vault Secrets Engines

variable "dev_namespace" {
  description = "The dev namespace."
}

variable "admin_password" {
  description = "Admin password for UserPass Auth."
}
