SQL_Server = {
  "server" = {                 # Key defines the UserDefinedString
    resource_group = "Project" # Required: Can be the name or ID of the resource group                            
    version        = "12.0"    # Required: 2.0 for v11 or 12.0 for v12
    subnet         = "OZ"      # Required: Can be the name or the ID of a subnet  
    # logging_storage_account_enabled = true                 # Optional: Set to false if you don't want to create a storage account for logging purposes                                    

    administrator_login = "maxime.mahdavian" # Optional: This sets a local admin account with this username                   
    # administrator_login_password = "Canada123!"            # Optional: Set the password of the local admin account. See documentation for rules about the password

    # Uncomment any of the values in this block to set them explicitly
    # connection_policy = "Default"
    # minimum_tls_version = "1.2"
    # public_network_access_enabled = false
    # outbound_network_restriction_enabled = false

    # express_vulnerability_assessment_enabled = true  # Optional: Enables express vulnerability assessment on the server. Default: false

    # Optional: Set this block if you want to set the admin user with a entraID account
    # azuread_administrator = {
    #   login_username = "Maxime.Mahdavian_ssc-spc.gc.ca#EXT#@ent.cloud-nuage.canada.ca"
    #   object_id = "4d0c4240-9ded-432f-848d-2c49a23d39a0"
    #   azuread_authentication_only = false                   # Set this to true if you want the admin user to only be this entraID account
    # }

    # Optional: Uncomment this block if you want to set firewall rules. Only applicable when public access is enabled. Can create more than one. 
    # firewall_rules = {
    #   "firwall_rule1" = {                     # Key is the name of the rule
    #     start_ip_address = "0.0.0.0"          
    #     end_ip_address = "255.255.255.255"    
    #   }
    # }

    # Optional: Uncomment this block if you want to set virtual network rules. Only applicable when public access is enabled. Can create more than one.
    # virtual_network_rules = {
    #   "network_rules1" = {                                  # Key is the name of the rule
    #     subnet = "OZ"                                       # Subnet can be a name or a subnet ID
    #     ignore_missing_vnet_service_endpoint = false
    #   }
    # }

    # Optional: Comment this out if you don't need it
    extended_auditing_policy = {
      enabled                = true
      retention_in_days      = 90
      log_monitoring_enabled = true
    }

    # Optional, uncomment this if you want to set alert policies
    # sever_security_alert_policy = {
    #   state = "Enabled"
    #   email_account_admins = false
    #   email_addresses = [ "firstname.lastname@ssc-spc.gc.ca" ]
    #   retention_days = 30
    #   disabled_alerts = ["Data_Exfiltration"]
    # }

    # Identity is required if a logging storage account is enabled
    identity = {
      type = "SystemAssigned"
    }

    # Optional: Comment this out if you don't need a private endpoint
    private_endpoint = {
      sqlserver = {                       # Key defines the userDefinedstring
        resource_group    = "Project"     # Required: Resource group name, i.e Project, Management, DNS, etc, or the resource group ID
        subnet            = "APP"         # Required: Subnet name, i.e OZ,MAZ, etc, or the subnet ID
        subresource_names = ["sqlServer"] # Required: Subresource name determines to what service the private endpoint will connect to. see: https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource for list of subresrouce
        # local_dns_zone    = "privatelink.blob.core.windows.net" # Optional: Name of the local DNS zone for the private endpoint
      }
    }

    # Optional: Set a keyvault where the admin password will be stored. Defaults to project subscription
    # key_vault = {
    #   name = ""
    #   resource_group_name = ""
    # }

    # Required: This block configures SQL databases. Can configure more than one DB at a time
    # NOTE: Multiple options in this database require azurerm 3.116.0 You need to upgrade the version if it's older
    database = {
      "database" = {                                 # Key defines the userDefinedString                                                                     
        collation   = "SQL_Latin1_General_CP1_CI_AS" # 
        max_size_gb = 10
        read_scale  = false
        sku_name    = "S0"

        # Uncomment any of these values to set their values explicitly 
        # auto_pause_delay_in_minutes = -1
        # create_mode = "Default"
        # creation_source_database_id = ""
        # elastic_pool_id = ""
        # enclave_type = "Default"
        # geo_backup_enabled = true
        # maintenance_configuration_name = "SQL_Default"
        # ledger_enabled = true
        # license_type = "BasePrice"
        # min_capacity = null
        # restore_point_in_time = null
        # recovery_point_id = ""
        # restore_dropped_database_id = ""
        # restore_long_term_retention_backup_id = ""
        # read_replica_count = null
        # sample_name = null
        # storage_account_type = "Geo"
        # transparent_data_encryption_enabled = null
        # transparent_data_encryption_key_automatic_rotation_enabled = null
        # transparent_data_encryption_key_vault_key_id = ""
        # zone_redundant = true
        # secondary_type = null

        short_term_retention_policy = {
          retention_days           = 35
          backup_interval_in_hours = 12
        }

        long_term_retention_policy = {
          weekly_retention  = "P1Y"
          monthly_retention = "P1Y"
          yearly_retention  = "P1Y"
          week_of_year      = 1
        }
      }
    }
  }
}
