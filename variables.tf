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
  description = "MSSQL object containing all paramaters"
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

