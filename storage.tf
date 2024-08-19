module "storage_account" {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-storage_accountV2.git?ref=v1.0.2"

  userDefinedString = "${var.userDefinedString}-logs"
  location = var.location
  env = var.env
  resource_groups = var.resource_groups
  subnets = var.subnets
  private_dns_zone_ids = var.private_dns_zone_ids
  tags = var.tags
  storage_account = {
    resource_group = var.mssql.resource_group 
    account_tier = "Standard"
    account_replication_type = "GRS"
    shared_access_key_enabled = true
  }
}