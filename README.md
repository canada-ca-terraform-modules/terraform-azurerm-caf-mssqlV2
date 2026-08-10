# terraform-azurerm-caf-mssqlV2

Deploys an Azure SQL Server (MSSQL) with optional databases, auditing policy, security alert policy, firewall/VNet rules, private endpoint, and a dedicated logging storage account. Requires azurerm `~> 4.0`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_private_endpoint"></a> [private\_endpoint](#module\_private\_endpoint) | github.com/canada-ca-terraform-modules/terraform-azurerm-caf-private_endpoint.git | v1.2.0 |
| <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account) | github.com/canada-ca-terraform-modules/terraform-azurerm-caf-storage_accountV2.git | v1.2.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_secret.sql-admin-password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_mssql_database.mssql_db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_firewall_rule.firewall_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) | resource |
| [azurerm_mssql_server.mssql_sever](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_mssql_server_extended_auditing_policy.mssql_server_audit_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_extended_auditing_policy) | resource |
| [azurerm_mssql_server_security_alert_policy.mssql_server_security_alert_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_security_alert_policy) | resource |
| [azurerm_mssql_virtual_network_rule.test](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_network_rule) | resource |
| [azurerm_role_assignment.sql_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_password.sql-admin-password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | (Required) Environment for the MSSQL server | `string` | n/a | yes |
| <a name="input_group"></a> [group](#input\_group) | (Required) Group for the project | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) specifies the Azure location where the resource exists | `string` | `"canadacentral"` | no |
| <a name="input_mssql"></a> [mssql](#input\_mssql) | MSSQL object containing all parameters. Supported properties include (but are not limited to):<br/>  - version<br/>  - administrator\_login<br/>  - administrator\_login\_password<br/>  - connection\_policy<br/>  - minimum\_tls\_version<br/>  - public\_network\_access\_enabled<br/>  - outbound\_network\_restriction\_enabled<br/>  - azuread\_administrator<br/>  - identity<br/>  - tags<br/>  - express\_vulnerability\_assessment\_enabled (bool, optional): Enables express vulnerability assessment on the server. Default: false | `any` | `{}` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Object containing private DNS zone IDs for the target project | `any` | `{}` | no |
| <a name="input_project"></a> [project](#input\_project) | (Required) Project name | `string` | n/a | yes |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | (Required) Resource group object for the MSSQL server | `any` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Object containing subnet objects of the target project | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the resources | `map(string)` | `{}` | no |
| <a name="input_userDefinedString"></a> [userDefinedString](#input\_userDefinedString) | (Required) UserDefinedString for the mssql server | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mssql_server"></a> [mssql\_server](#output\_mssql\_server) | MSSQL server object |
| <a name="output_mssql_server_id"></a> [mssql\_server\_id](#output\_mssql\_server\_id) | MSSQL server ID |
| <a name="output_mssql_server_name"></a> [mssql\_server\_name](#output\_mssql\_server\_name) | MSSQL server name |
<!-- END_TF_DOCS -->

