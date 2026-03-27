mock_provider "azurerm" {}
mock_provider "random" {}

variables {
  env               = "Dev"
  group             = "SLRD"
  project           = "test"
  userDefinedString = "server"
  location          = "canadacentral"
  resource_groups = {
    Project  = { name = "rg-proj", id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-proj" }
    Keyvault = { name = "rg-kv", id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-kv" }
  }
  subnets              = {}
  private_dns_zone_ids = {}
  tags                 = { environment = "dev" }
}

# ─── naming_convention ──────────────────────────────────────────────────────
run "naming_convention" {
  command = plan

  variables {
    mssql = {
      resource_group = "Project"
      subnet         = "OZ"
      azuread_administrator = {
        login_username              = "admin@example.com"
        object_id                   = "00000000-0000-0000-0000-000000000001"
        azuread_authentication_only = true
      }
      identity                        = { type = "SystemAssigned" }
      logging_storage_account_enabled = false
    }
  }

  assert {
    condition     = azurerm_mssql_server.mssql_sever.name == "dev-slrd-test-server"
    error_message = "Server name must follow {env4}-{group}-{project}-{userDefinedString} convention"
  }
}

# ─── default_values ─────────────────────────────────────────────────────────
run "default_values" {
  command = plan

  variables {
    mssql = {
      resource_group = "Project"
      subnet         = "OZ"
      azuread_administrator = {
        login_username              = "admin@example.com"
        object_id                   = "00000000-0000-0000-0000-000000000001"
        azuread_authentication_only = true
      }
      identity                        = { type = "SystemAssigned" }
      logging_storage_account_enabled = false
    }
  }

  assert {
    condition     = azurerm_mssql_server.mssql_sever.version == "12.0"
    error_message = "Default server version must be 12.0"
  }

  assert {
    condition     = azurerm_mssql_server.mssql_sever.minimum_tls_version == "1.2"
    error_message = "Default minimum TLS version must be 1.2"
  }

  assert {
    condition     = azurerm_mssql_server.mssql_sever.public_network_access_enabled == false
    error_message = "Default public_network_access_enabled must be false"
  }

  assert {
    condition     = azurerm_mssql_server.mssql_sever.connection_policy == "Default"
    error_message = "Default connection_policy must be Default"
  }
}

# ─── with_database ───────────────────────────────────────────────────────────
run "with_database" {
  command = plan

  variables {
    mssql = {
      resource_group = "Project"
      subnet         = "OZ"
      azuread_administrator = {
        login_username              = "admin@example.com"
        object_id                   = "00000000-0000-0000-0000-000000000001"
        azuread_authentication_only = true
      }
      identity                        = { type = "SystemAssigned" }
      logging_storage_account_enabled = false
      database = {
        mydb = {
          sku_name    = "S0"
          max_size_gb = 10
          collation   = "SQL_Latin1_General_CP1_CI_AS"
          short_term_retention_policy = {
            retention_days           = 35
            backup_interval_in_hours = 12
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_mssql_database.mssql_db["mydb"].sku_name == "S0"
    error_message = "DB sku_name must match input"
  }

  assert {
    condition     = azurerm_mssql_database.mssql_db["mydb"].name == "dev-slrd-test-mydb"
    error_message = "DB name must follow {prefix}-{key} convention"
  }
}

# ─── with_auditing_policy ────────────────────────────────────────────────────
run "with_auditing_policy" {
  command = plan

  variables {
    mssql = {
      resource_group = "Project"
      subnet         = "OZ"
      azuread_administrator = {
        login_username              = "admin@example.com"
        object_id                   = "00000000-0000-0000-0000-000000000001"
        azuread_authentication_only = true
      }
      identity                        = { type = "SystemAssigned" }
      logging_storage_account_enabled = false
      extended_auditing_policy = {
        enabled                = true
        retention_in_days      = 90
        log_monitoring_enabled = true
        storage_endpoint       = "https://example.blob.core.windows.net"
      }
    }
  }

  assert {
    condition     = azurerm_mssql_server_extended_auditing_policy.mssql_server_audit_policy[0].retention_in_days == 90
    error_message = "Auditing policy retention_in_days must be 90"
  }
}

# ─── with_primary_user_assigned_identity ─────────────────────────────────────
run "with_primary_user_assigned_identity" {
  command = plan

  variables {
    mssql = {
      resource_group = "Project"
      subnet         = "OZ"
      azuread_administrator = {
        login_username              = "admin@example.com"
        object_id                   = "00000000-0000-0000-0000-000000000001"
        azuread_authentication_only = true
      }
      identity = {
        type         = "UserAssigned"
        identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-proj/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-test"]
      }
      primary_user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-proj/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-test"
      logging_storage_account_enabled   = false
    }
  }

  assert {
    condition     = azurerm_mssql_server.mssql_sever.primary_user_assigned_identity_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-proj/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-test"
    error_message = "primary_user_assigned_identity_id must be set on the server"
  }
}

# ─── database_with_ltr_immutable_backups ─────────────────────────────────────
run "database_with_ltr_immutable_backups" {
  command = plan

  variables {
    mssql = {
      resource_group = "Project"
      subnet         = "OZ"
      azuread_administrator = {
        login_username              = "admin@example.com"
        object_id                   = "00000000-0000-0000-0000-000000000001"
        azuread_authentication_only = true
      }
      identity                        = { type = "SystemAssigned" }
      logging_storage_account_enabled = false
      database = {
        immutabledb = {
          sku_name    = "S0"
          max_size_gb = 10
          long_term_retention_policy = {
            weekly_retention          = "P1Y"
            monthly_retention         = "P1Y"
            yearly_retention          = "P1Y"
            week_of_year              = 1
            immutable_backups_enabled = true
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_mssql_database.mssql_db["immutabledb"].long_term_retention_policy[0].immutable_backups_enabled == true
    error_message = "immutable_backups_enabled must be true when set"
  }
}

# ─── auditing_policy_with_subscription_id ────────────────────────────────────
run "auditing_policy_with_subscription_id" {
  command = plan

  variables {
    mssql = {
      resource_group = "Project"
      subnet         = "OZ"
      azuread_administrator = {
        login_username              = "admin@example.com"
        object_id                   = "00000000-0000-0000-0000-000000000001"
        azuread_authentication_only = true
      }
      identity                        = { type = "SystemAssigned" }
      logging_storage_account_enabled = false
      extended_auditing_policy = {
        enabled                         = true
        retention_in_days               = 90
        log_monitoring_enabled          = true
        storage_endpoint                = "https://example.blob.core.windows.net"
        storage_account_subscription_id = "00000000-0000-0000-0000-000000000000"
      }
    }
  }

  assert {
    condition     = azurerm_mssql_server_extended_auditing_policy.mssql_server_audit_policy[0].storage_account_subscription_id == "00000000-0000-0000-0000-000000000000"
    error_message = "storage_account_subscription_id must be set on auditing policy"
  }
}
