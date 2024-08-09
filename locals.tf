locals {
  resource_group_name = strcontains(var.mssql.resource_group, "/resourceGroups/") ? regex("[^\\/]+$", var.mssql.resource_group) : var.resource_groups[var.mssql.resource_group].name

  # This line determines what to SQL admin login password will be. 3 options are possible:
  # Generated password if   ->  azuread_authentication_only = false AND RBAC authorization is enabled on the subscription keyvault
  # User chosen password if ->  azuread_authentication_only = false AND RBAC authorization is disabled on the subscription keyvault 
  # No password required if ->  azuread_authentication_only = true
  sql-admin-password = try(var.mssql.azuread_administrator.azuread_authentication_only, false) ?  null : try(data.azurerm_key_vault.key_vault.enable_rbac_authorization, false) ? random_password.sql-admin-password[0].result : var.mssql.administrator_login_password
}