variable "env" {
  description = "(Required) Environment for the MSSQL server"
  type = string
}

variable "group" {
  description = "(Required) Group for the project"
  type = string
}

variable "project" {
  description = "(Required) Project name"
  type = string
}

variable "userDefinedString" {
  description = "(Required) UserDefinedString for the mssql server"
  type = string
}

variable "location" {
  description = "(Required) specifies the Azure location where the resource exists"
  type = string
  default = "canadacentral"
}

variable "resource_groups" {
    description = "(Required) Resource group object for the MSSQL server"
    type = any  
}

variable "mssql" {
  description = <<EOT
MSSQL object containing all parameters. Supported properties include (but are not limited to):
  - version
  - administrator_login
  - administrator_login_password
  - connection_policy
  - minimum_tls_version
  - public_network_access_enabled
  - outbound_network_restriction_enabled
  - azuread_administrator
  - identity
  - tags
  - express_vulnerability_assessment_enabled (bool, optional): Enables express vulnerability assessment on the server. Default: false
EOT
  type = any
  default = {}
}

variable "subnets" {
  description = "Object containing subnet objects of the target project"
  type = any
  default = {}
}

variable "private_dns_zone_ids" {
  description = "Object containing private DNS zone IDs for the target project"
  type = any
  default = {}
}

variable "tags" {
  description = "Tags for the resources"
  type = map(string)
  default = {}
}

