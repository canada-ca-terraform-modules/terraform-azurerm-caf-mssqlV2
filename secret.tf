locals {
  group_4 = substr(var.group, 0, 4)
  project_3 = substr(var.project, 0, 3)
  kv_sha = substr(sha1(var.resource_groups["Keyvault"].id), 0, 4)
  kv_name = "${var.env}CKV-${local.group_4}-${local.project_3}-${local.kv_sha}-kv"
}

data "azurerm_key_vault" "key_vault" {
  name = local.kv_name
  resource_group_name = var.resource_groups["Keyvault"].name
}

resource "random_password" "sql-admin-password" {
  count            = try(data.azurerm_key_vault.key_vault.enable_rbac_authorization, false) && !try(var.mssql.azuread_administrator.azuread_authentication_only, false) ? 1 : 0
  length           = 16
  special          = true
  override_special = "!#$%&*"
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "sql-admin-password" {
  count        = try(data.azurerm_key_vault.key_vault.enable_rbac_authorization, false) && !try(var.mssql.azuread_administrator.azuread_authentication_only, false) ? 1 : 0
  name         = "${local.mssql_server_name}-sql-admin-password"
  value        = random_password.sql-admin-password[0].result
  key_vault_id = data.azurerm_key_vault.key_vault.id

  lifecycle {
    ignore_changes = all
  }
}




