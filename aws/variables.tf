variable "databricks_account_username" {
     type = string
     sensitive = true
}

variable "databricks_account_password" {
     type = string
     sensitive = true
}

variable "databricks_account_id" {
     type = string
     sensitive = true
}

variable "iam_role_arn" {
     type = string
     sensitive = true
}

variable "resource_owner" {
  type = string
  sensitive = true
}

variable "cidr_block" {
  type = string
}

variable "region" {
  type = string
}

variable "tags" {
  default = {
    "Owner" = var.resource_owner
  }
}

variable "resource_prefix" {
  type = string
}

variable "workspace_vpce_service" {
    type = string
}

variable "relay_vpce_service" {
    type = string
}

variable "private_dns_enabled" { default = true }