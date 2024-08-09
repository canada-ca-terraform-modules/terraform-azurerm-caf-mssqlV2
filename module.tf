resource "azurerm_mssql_server" "mssql_sever" {
  name = local.mssql_server_name
  resource_group_name = local.resource_group_name
  location = var.location
  version = var.mssql.version
  
  # Optional parameters
  administrator_login = try(var.mssql.azuread_administrator.azuread_authentication_only, false) == false ? var.mssql.administrator_login : null
  administrator_login_password = local.sql-admin-password
  connection_policy = try(var.mssql.connection_policy, "Default")
  minimum_tls_version = try(var.mssql.minimum_tls_version, "1.2")
  public_network_access_enabled = try(var.mssql.public_network_access_enabled, false)
  outbound_network_restriction_enabled = try(var.mssql.outbound_network_restriction_enabled, true)
  
  dynamic "azuread_administrator" {
    for_each = try(var.mssql.azuread_administrator, false) != false ? [1] : []
    content {
      login_username = var.mssql.azuread_administrator.login_username
      object_id = var.mssql.azuread_administrator.object_id
      tenant_id = try(var.mssql.azuread_administrator.tenant_id, null)
      azuread_authentication_only = try(var.mssql.azuread_administrator.azuread_authentication_only, false)
    }
  }

  dynamic "identity" {
    for_each = try(var.mssql.identity, false) != false ? [1] : []
    content {
      type = var.mssql.identity.type
      identity_ids = try(var.mssql.identity.identity_ids, [])
    }
  }
  #Tags
  tags = merge(var.tags, try(var.mssql.tags, {}))

  lifecycle {
    ignore_changes = [ identity, tags,  ]
  }
}


resource "azurerm_mssql_firewall_rule" "firewall_rules" {
  for_each = try(var.mssql.firewall_rules, {})

  name = each.key
  server_id = azurerm_mssql_server.mssql_sever.id
  start_ip_address = each.value.start_ip_address
  end_ip_address = each.value.end_ip_address
}


# Calls this module if we need a private endpoint attached to the storage account
module "private_endpoint" {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-private_endpoint.git?ref=v1.0.1"
  for_each =  try(var.mssql.private_endpoint, {}) 

  name = "${local.mssql_server_name}-${each.key}"
  location = var.location
  resource_groups = var.resource_groups
  subnets = var.subnets
  private_connection_resource_id = azurerm_mssql_server.mssql_sever.id
  private_endpoint = each.value
  private_dns_zone_ids = var.private_dns_zone_ids
  tags = var.tags
}