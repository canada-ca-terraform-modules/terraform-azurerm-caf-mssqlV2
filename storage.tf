module "storage_account" {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-storage_accountV2.git?ref=v1.0.2"
  count = try(var.mssql.logging_storage_account_enabled, true) ? 1 : 0
  userDefinedString    = "${var.userDefinedString}-logs"
  location             = var.location
  env                  = var.env
  resource_groups      = var.resource_groups
  subnets              = var.subnets
  private_dns_zone_ids = var.private_dns_zone_ids
  tags                 = var.tags
  storage_account = {
    resource_group            = var.mssql.resource_group
    account_tier              = "Standard"
    account_replication_type  = "GRS"
    public_network_access_enabled = try(var.mssql.storage_account_public_access_enabled, false)
    shared_access_key_enabled = true
    private_endpoint = {
      "mssqllogs" = {                       
        resource_group    = var.mssql.resource_group
        subnet            = var.mssql.subnet     
        subresource_names = ["blob"]  
      }
    }
  }
}

resource "azurerm_role_assignment" "sql_contributor" {
  count = try(var.mssql.logging_storage_account_enabled, true) ? 1 : 0
  scope = module.storage_account[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = azurerm_mssql_server.mssql_sever.identity[0].principal_id
}