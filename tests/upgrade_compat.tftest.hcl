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

# Step 1: Simulate a currently-deployed resource (pre-upgrade inputs — no new args)
run "baseline_apply" {
  command = apply

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
    error_message = "Baseline apply: unexpected server name"
  }
}

# Step 2: Plan upgraded code against that state — no resource replacement should occur
run "upgrade_plan_no_replacement" {
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
      # New server-level args in 4.50.0 — must not force replacement
      primary_user_assigned_identity_id            = null
      transparent_data_encryption_key_vault_key_id = null
    }
  }

  assert {
    condition     = azurerm_mssql_server.mssql_sever.name == "dev-slrd-test-server"
    error_message = "Upgrade plan: server name must not change"
  }
}
