# variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create Vault Auth Methods

variable "dev_namespace" {
  description = "The dev namespace."
}

variable "admin_password" {
  description = "Admin password for UserPass Auth."
}
