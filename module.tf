resource "azurerm_mssql_server" "mssql_sever" {
  name                = local.mssql_server_name
  resource_group_name = local.resource_group_name
  location            = var.location
  version             = var.mssql.version

  # Optional parameters
  administrator_login                  = try(var.mssql.azuread_administrator.azuread_authentication_only, false) == false ? var.mssql.administrator_login : null
  administrator_login_password         = local.sql-admin-password
  connection_policy                    = try(var.mssql.connection_policy, "Default")
  minimum_tls_version                  = try(var.mssql.minimum_tls_version, "1.2")
  public_network_access_enabled        = try(var.mssql.public_network_access_enabled, false)
  outbound_network_restriction_enabled = try(var.mssql.outbound_network_restriction_enabled, true)

  dynamic "azuread_administrator" {
    for_each = try(var.mssql.azuread_administrator, false) != false ? [1] : []
    content {
      login_username              = var.mssql.azuread_administrator.login_username
      object_id                   = var.mssql.azuread_administrator.object_id
      tenant_id                   = try(var.mssql.azuread_administrator.tenant_id, null)
      azuread_authentication_only = try(var.mssql.azuread_administrator.azuread_authentication_only, false)
    }
  }

  dynamic "identity" {
    for_each = try(var.mssql.identity, false) != false ? [1] : []
    content {
      type         = var.mssql.identity.type
      identity_ids = try(var.mssql.identity.identity_ids, [])
    }
  }
  #Tags
  tags = merge(var.tags, try(var.mssql.tags, {}))

  lifecycle {
    ignore_changes = [identity, tags, ]
  }
}

resource "azurerm_mssql_database" "mssql_db" {
  for_each = try(var.mssql.database, {})

  name      = "${local.mssql_prefix}-${each.key}"
  server_id = azurerm_mssql_server.mssql_sever.id

  auto_pause_delay_in_minutes                                = try(each.value.auto_pause_delay_in_minutes, -1)
  create_mode                                                = try(each.value.create_mode, "Default")
  creation_source_database_id                                = try(each.value.creation_source_database_id, null)
  collation                                                  = try(each.value.collation, null)
  elastic_pool_id                                            = try(each.value.elastic_pool_id, null)
  enclave_type                                               = try(each.value.enclave_type, "Default")
  geo_backup_enabled                                         = try(each.value.geo_backup_enabled, true)
  maintenance_configuration_name                             = try(each.value.maintenance_configuration_name, "SQL_Default")
  ledger_enabled                                             = try(each.value.ledger_enabled, false)
  license_type                                               = try(each.value.license_type, "BasePrice")
  max_size_gb                                                = try(each.value.max_size_gb, null)
  min_capacity                                               = try(each.value.min_capacity, null)
  restore_point_in_time                                      = try(each.value.restore_point_in_time, null)
  recovery_point_id                                          = try(each.value.recovery_point_id, null)
  restore_dropped_database_id                                = try(each.value.restore_dropped_database_id, null)
  restore_long_term_retention_backup_id                      = try(each.value.restore_long_term_retention_backup_id, null)
  read_replica_count                                         = try(each.value.read_replica_count, null)
  read_scale                                                 = try(each.value.read_scale, null)
  sample_name                                                = try(each.value.sample_name, null)
  sku_name                                                   = try(each.value.sku_name, "Basic")
  storage_account_type                                       = try(each.value.storage_account_type, "Geo")
  transparent_data_encryption_enabled                        = try(each.value.transparent_data_encryption_enabled, true)
  transparent_data_encryption_key_automatic_rotation_enabled = try(each.value.transparent_data_encryption_key_automatic_rotation_enabled, false)
  zone_redundant                                             = try(each.value.zone_redundant, null)
  secondary_type                                             = try(each.value.secondary_type, "Geo")

  tags = merge(var.tags, try(each.value.tags, {}))

  dynamic "import" {
    for_each = try(each.value.import, false) != false ? [1] : [0]
    content {
      storage_uri = each.value.import.storage_uri
      storage_key = each.value.import.storage_key
      storage_key_type = each.value.import.storage_key_type
      administrator_login = each.value.import.administrator_login
      administrator_login_password = each.value.import.administrator_login_password
      authentication_type = each.value.import.authentication_type
      storage_account_id = try(each.value.import.storage_account_id, null)
    }
  }


  lifecycle {
    ignore_changes = [tags, ]
  }


}



resource "azurerm_mssql_firewall_rule" "firewall_rules" {
  for_each = try(var.mssql.firewall_rules, {})

  name             = each.key
  server_id        = azurerm_mssql_server.mssql_sever.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}


# Calls this module if we need a private endpoint attached to the storage account
module "private_endpoint" {
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-private_endpoint.git?ref=v1.0.1"
  for_each = try(var.mssql.private_endpoint, {})

  name                           = "${local.mssql_server_name}-${each.key}"
  location                       = var.location
  resource_groups                = var.resource_groups
  subnets                        = var.subnets
  private_connection_resource_id = azurerm_mssql_server.mssql_sever.id
  private_endpoint               = each.value
  private_dns_zone_ids           = var.private_dns_zone_ids
  tags                           = var.tags
}
