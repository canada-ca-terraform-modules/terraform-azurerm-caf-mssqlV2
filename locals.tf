locals {
  # Parses the resource group name. If the module received an ID (contains /resourceGroups/) then gets the name after the last /
  # If not, then fetch the resource group name with the resource group object that was also passed
  resource_group_name = strcontains(var.mssql.resource_group, "/resourceGroups/") ? regex("[^\\/]+$", var.mssql.resource_group) : var.resource_groups[var.mssql.resource_group].name

  # This line determines what the SQL admin login password will be. 3 options are possible:
  # Generated password if   ->  azuread_authentication_only = false AND RBAC authorization is enabled on the subscription keyvault AND password_overwrite = false
  # User chosen password if ->  azuread_authentication_only = false AND RBAC authorization is disabled on the subscription keyvault OR password_overwrite = true
  # No password required if ->  azuread_authentication_only = true
  sql-admin-password = try(var.mssql.azuread_administrator.azuread_authentication_only, false) ?  null : try(data.azurerm_key_vault.key_vault[0].rbac_authorization_enabled, false) ? random_password.sql-admin-password[0].result : var.mssql.administrator_login_password
}