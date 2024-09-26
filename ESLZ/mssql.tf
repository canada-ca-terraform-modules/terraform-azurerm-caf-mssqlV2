variable "SQL_Server" {
  description = "SQL server to deploy"
  type = any
  default = {}
}

module "mssql" {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-mssqlV2.git?ref=v1.0.1"
  for_each = var.SQL_Server

  userDefinedString = each.key 
  env = var.env
  group = var.group 
  project = var.project
  location = var.location
  resource_groups = local.resource_groups_all
  mssql = each.value
  subnets = local.subnets
  private_dns_zone_ids = local.Project-dns-zone
}
