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
  outbound_network_restriction_enabled = try(var.mssql.outbound_network_restriction_enabled, false)

  # azuread_administrator is optional
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

  # Required
  name      = "${local.mssql_prefix}-${each.key}"
  server_id = azurerm_mssql_server.mssql_sever.id

  # Optional
  auto_pause_delay_in_minutes                                = try(each.value.auto_pause_delay_in_minutes, null)
  create_mode                                                = try(each.value.create_mode, "Default")
  creation_source_database_id                                = try(each.value.creation_source_database_id, null)
  collation                                                  = try(each.value.collation, null)
  elastic_pool_id                                            = try(each.value.elastic_pool_id, null)
  # enclave_type                                               = try(each.value.enclave_type, "Default")
  geo_backup_enabled                                         = try(each.value.geo_backup_enabled, true)
  maintenance_configuration_name                             = try(each.value.maintenance_configuration_name, "SQL_Default")
  ledger_enabled                                             = try(each.value.ledger_enabled, false)
  license_type                                               = try(each.value.license_type, "BasePrice")
  max_size_gb                                                = try(each.value.max_size_gb, null)
  min_capacity                                               = try(each.value.min_capacity, null)
  restore_point_in_time                                      = try(each.value.restore_point_in_time, null)
  # recovery_point_id                                          = try(each.value.recovery_point_id, null)
  restore_dropped_database_id                                = try(each.value.restore_dropped_database_id, null)
  # restore_long_term_retention_backup_id                      = try(each.value.restore_long_term_retention_backup_id, null)
  read_replica_count                                         = try(each.value.read_replica_count, null)
  read_scale                                                 = try(each.value.read_scale, null)
  sample_name                                                = try(each.value.sample_name, null)
  sku_name                                                   = try(each.value.sku_name, "Basic")
  storage_account_type                                       = try(each.value.storage_account_type, "Geo")
  transparent_data_encryption_enabled                        = try(each.value.transparent_data_encryption_enabled, null)
  # transparent_data_encryption_key_automatic_rotation_enabled = try(each.value.transparent_data_encryption_key_automatic_rotation_enabled, null)
  # transparent_data_encryption_key_vault_key_id               = try(each.value.transparent_data_encryption_key_vault_key_id, null)
  zone_redundant                                             = try(each.value.zone_redundant, null)
  # secondary_type                                             = try(each.value.secondary_type, null)

  tags = merge(var.tags, try(each.value.tags, {}))

  dynamic "import" { 
    for_each = try(each.value.import, false) != false ? [1] : []
    content {
      storage_uri                  = each.value.import.storage_uri
      storage_key                  = each.value.import.storage_key
      storage_key_type             = each.value.import.storage_key_type
      administrator_login          = each.value.import.administrator_login
      administrator_login_password = each.value.import.administrator_login_password
      authentication_type          = each.value.import.authentication_type
      storage_account_id           = try(each.value.import.storage_account_id, null)
    }
  }

  dynamic "short_term_retention_policy" {
    for_each = try(each.value.short_term_retention_policy, false) != false ? [1] : []
    content {
      retention_days           = each.value.short_term_retention_policy.retention_days
      backup_interval_in_hours = try(each.value.short_term_retention_policy.backup_interval_in_hours, 12)
    }
  }

  dynamic "long_term_retention_policy" {
    for_each = try(each.value.long_term_retention_policy, false) != false ? [1] : []
    content {
      weekly_retention          = try(each.value.long_term_retention_policy.weekly_retention, "P1Y")
      monthly_retention         = try(each.value.long_term_retention_policy.monthly_retention, "P1Y")
      yearly_retention          = try(each.value.long_term_retention_policy.yearly_retention, "P1Y")
      week_of_year              = try(each.value.long_term_retention_policy.week_of_year, 1)
      # immutable_backups_enabled = try(each.value.long_term_retention_policy.immutable_backups_enabled, false)
    }
  }


  lifecycle {
    ignore_changes = [tags, ]
  }
}

# Sets firewal rules for the server. Not applicable if public_network_access_enabled is false
resource "azurerm_mssql_firewall_rule" "firewall_rules" {
  for_each = try(var.mssql.firewall_rules, {})

  name             = each.key
  server_id        = azurerm_mssql_server.mssql_sever.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

# Sets network rules for the server. Not applicable if public_network_access_enabled is false
resource "azurerm_mssql_virtual_network_rule" "test" {
  for_each = try(var.mssql.virtual_network_rules, {})

  name = each.key
  server_id = azurerm_mssql_server.mssql_sever.id
  subnet_id = strcontains(each.value.subnet, "/resourceGroups/") ? each.value.subnet : var.subnets[each.value.subnet].id
  ignore_missing_vnet_service_endpoint = try(each.value.ignore_missing_vnet_service_endpoint, false)
}

resource "azurerm_mssql_server_extended_auditing_policy" "mssql_server_audit_policy" {
  count = try(var.mssql.auditing_policy_enabled, true) ? 1 : 0
  server_id                               = azurerm_mssql_server.mssql_sever.id
  enabled                                 = try(var.mssql.extended_auditing_policy.enabled, true)
  storage_endpoint                        = try(var.mssql.extended_auditing_policy.storage_endpoint, false) != false ? var.mssql.extended_auditing_policy.storage_endpoint : module.storage_account[0].storage-account-object.primary_blob_endpoint
  storage_account_access_key              = try(var.mssql.extended_auditing_policy.storage_account_access_key, false) != false ? var.mssql.extended_auditing_policy.storage_account_access_key : null
  storage_account_access_key_is_secondary = try(var.mssql.extended_auditing_policy.storage_account_access_key_is_secondary, false)
  retention_in_days                       = try(var.mssql.extended_auditing_policy.retention_in_days, 6)
  log_monitoring_enabled                  = try(var.mssql.extended_auditing_policy.log_monitoring_enabled, true)
}

resource "azurerm_mssql_server_security_alert_policy" "mssql_server_security_alert_policy" {
  count = try(var.mssql.server_security_alert_policy_enabled, false) ? 1 : 0
  resource_group_name = local.resource_group_name
  server_name = azurerm_mssql_server.mssql_sever.name
  state = try(var.mssql.server_security_alert_policy.state, "Enabled")
  email_account_admins = try(var.mssql.server_security_alert_policy.email_account_admins, false)
  email_addresses = try(var.mssql.server_security_alert_policy.email_addresses, null)
  retention_days = try(var.mssql.server_security_alert_policy.retention_days, 30)
  storage_endpoint = module.storage_account[0].storage-account-object.primary_blob_endpoint
  storage_account_access_key = module.storage_account[0].storage-account-object.primary_access_key
  disabled_alerts = try(var.mssql.server_security_alert_policy.disabled_alerts, ["Data_Exfiltration"])
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
