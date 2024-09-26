## Requirements

No requirements.

## Providers

| Name    | Version |
| ------- | ------- |
| azurerm | 3.116   |
| random  | n/a     |

## Inputs

| Name                    | Description                                                       | Type          | Default           | Required |
| ----------------------- | ----------------------------------------------------------------- | ------------- | ----------------- | :------: |
| userDefinedString       | (Required) UserDefinedString for the mssql server                 | `string`      | n/a               |   yes    |
| env                     | (Required) Environment for the MSSQL server                       | `string`      | n/a               |   yes    |
| group                   | (Required) Group for the project                                  | `string`      | n/a               |   yes    |
| location                | (Required) specifies the Azure location where the resource exists | `string`      | `"canadacentral"` |    no    |
| project                 | (Required) Project name                                           | `string`      | n/a               |   yes    |
| resource\_groups        | (Required) Resource group object for the MSSQL server             | `any`         | n/a               |   yes    |
| mssql                   | MSSQL object containing all parameters                            | `any`         | `{}`              |    no    |
| private\_dns\_zone\_ids | Object containing private DNS zone IDs for the target project     | `any`         | `{}`              |    no    |
| subnets                 | Object containing subnet objects of the target project            | `any`         | `{}`              |    no    |
| tags                    | Tags for the resources                                            | `map(string)` | `{}`              |    no    |

## Outputs

| Name                | Description         |
| ------------------- | ------------------- |
| mssql\_server       | MSSQL server object |
| mssql\_server\_id   | MSSQL server ID     |
| mssql\_server\_name | MSSQL server name   |

## Administrator user

The administrator user can be configured to be either a local user or a EntraID user or both. The password for this admin user follows these rules:

- A generated password by terraform wil be used IF RBAC authorization is enabled on the subscription keyvault AND the server is configured to not only use entraID authentication AND password_overwrite it set to false
- A user chosen password, corresponding to a local admin user, will be used IF RBAC authorization is disabled on the subscription keyvault AND the server is configured to not only use entraID OR password_overwrite is set to true
- No password is required IF the server is configured to only use entraID authorization, then the password for the admin user will be the password of the account configured

## Parameters

For more information, please refer to the terraform documentation for the resources mentioned below. 

### SQL Server
| Name                                 | Possible values                  | Default | Required |
| ------------------------------------ | -------------------------------- | ------- | :------: |
| version                              | 2.0 (for V11) and 12.0 (for v12) | 12.0    |    no    |
| administrator_login                  | string                           | n/a     |    no    |
| administrator_login_password         | string                           | n/a     |    no    |
| connection_policy                    | Default,Proxy,Redirect           | Default |    no    |
| minimum_tls_version                  | 1.0,1.1,1.2,Disabled             | 1.2     |    no    |
| public_network_access_enabled        | True,false                       | false   |    no    |
| outbound_network_restriction_enabled | true,false                       | false   |    no    |
| azuread_administrator                | block                            | n/a     |    no    |
| identity                             | block                            | n/a     |    no    |
| tags                                 | string map                       | n/a     |    no    |

### SQL Database

| Name                                                       | Possible Values                                                      | Default     | Required |
| ---------------------------------------------------------- | -------------------------------------------------------------------- | ----------- | -------- |
| auto_pause_delay_in_minutes                                | int                                                                  | n/a         | No       |
| create_mode                                                | See terraform doc                                                    | Default     | No       |
| creation_source_database_id                                | Azure resource ID                                                    | n/a         | No       |
| collation                                                  | Valid SQL collation value                                            | n/a         | No       |
| elastic_pool_id                                            | Azure resource ID                                                    | n/a         | No       |
| enclave_type                                               | Default,VBS                                                          | Default     | No       |
| geo_backup_enabled                                         | true,false                                                           | true        | No       |
| maintenance_configuration_name                             | See terraform doc                                                    | SQL_Default | No       |
| ledger_enabled                                             | true,false                                                           | true        | No       |
| license_type                                               | LicenceIncluded,BasePrice                                            | BasePrice   | No       |
| max_size_gb                                                | int                                                                  | n/a         | No       |
| min_capacity                                               | int                                                                  | n/a         | No       |
| restore_point_in_time                                      | ISO8601 date format string                                           | n/a         | No       |
| recovery_point_id                                          | Azure resource ID                                                    | n/a         | No       |
| restore_dropped_database_id                                | Azure resource ID                                                    | n/a         | No       |
| restore_long_term_retention_backup_id                      | Azure resource ID                                                    | n/a         | No       |
| read_replica_count                                         | int                                                                  | n/a         | No       |
| read_scale                                                 | true,false                                                           | n/a         | No       |
| sample_name                                                | AdventureWorksLT                                                     | n/a         | No       |
| sku_name                                                   | GP_S_Gen5_2,HS_Gen4_1,BC_Gen5_2,ElasticPool,Basic,S0,P2,DW100c,DS100 | Basic       | No       |
| storage_account_type                                       | Geo,GeoZone,Local,Zone                                               | Geo         | No       |
| transparent_data_encryption_enabled                        | true,false                                                           | n/a         | No       |
| transparent_data_encryption_key_automatic_rotation_enabled | true,false                                                           | n/a         | No       |
| transparent_data_encryption_key_vault_key_id               | Azure resource ID                                                    | n/a         | No       |
| zone_redundant                                             | true,false                                                           | true        | No       |
| secondary_type                                             | Geo,Named                                                            | n/a         | No       |
| tags                                                       | string map                                                           | n/a         | no       |


### Firewall rules
| Name             | Possible Values | Default | Required |
| ---------------- | --------------- | ------- | -------- |
| start_ip_address | CIDR block      | n/a     | yes      |
| end_ip_address   | CIDR block      | n/a     | yes      |

### Virtual network rule

| Name                                 | Possible Values                              | Default | Required |
| ------------------------------------ | -------------------------------------------- | ------- | -------- |
| subnet_id                            | Subnet name (MAZ, OZ, PEP, etc) or subnet ID | n/a     | yes      |
| ignore_missing_vnet_service_endpoint | true,false                                   | false   | no       |

### Extended Auditing Policy

By default this resource is deployed with the database. Omitting the block disables the feature.

| Name                                    | Possible Values                                                                           | Default                            | Required |
| --------------------------------------- | ----------------------------------------------------------------------------------------- | ---------------------------------- | -------- |
| enabled                                 | true, false                                                                               | true                               | no       |
| storage_endpoint                        | Blob endpoint if using a SA different than the one created with the DB, nothing otherwise | Endpoint of the SA created with DB | no       |
| storage_account_access_key              | Access key if using a SA different than the one created with the DB, nothing otherwise    | null                               | no       |
| storage_account_access_key_is_secondary | true,false                                                                                | false                              | no       |
| retention_in_days                       | int                                                                                       | 90                                 | no       |
| log_monitoring_enabled                  | true,false                                                                                | true                               | no       |

### Security Alert policy 

By default, this resource is NOT deployed with the database. Omitting the block disables the feature.

| Name                                    | Possible Values                                                                                              | Default  | Required |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------ | -------- | -------- |
| state                                   | Enabled,Disabled,New                                                                                         | Disabled | no       |
| email_account_admins                    | true,false                                                                                                   | false    | no       |
| email_addresses                         | List of email addresses                                                                                      | null     | no       |
| storage_account_access_key_is_secondary | true,false                                                                                                   | false    | no       |
| retention_days                          | int                                                                                                          | 30       | no       |
| disabled_alerts                         | Array composed of: Sql_injection,Sql_Injection_Vulnerability, Access_Anomaly,Data_Exfiltration,Unsafe_Action | true     | no       |

### Private endpoint

| Name              | Possible Values                                                                                     | Default | Required |
| ----------------- | --------------------------------------------------------------------------------------------------- | ------- | -------- |
| name              | string                                                                                              | n/a     | yes      |
| resource_group    | Name of the resource group (Project, Management,etc) or resource group ID                           | n/a     | yes      |
| subnet            | Name of the subnet (OZ,MAZ,PAZ) or subnet ID                                                        | n/a     | yes      |
| subresource_names | name of the resource the PE will be connected to. For SQL databases, this value should be sqlServer | n/a     | yes      |
| local_dns_zone    | Name or ID of a private DNS zone                                                                    | n/a     | no       |

### Key vault
| Name                | Possible Values | Default | Required |
| ------------------- | --------------- | ------- | -------- |
| name                | name or ID      | n/a     | no       |
| resource_group_name | name or ID      | n/a     | no       |