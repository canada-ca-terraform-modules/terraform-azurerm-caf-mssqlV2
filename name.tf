locals {
  mssql_regex = "/[^0-9a-z]/"
  env-regex_compliant_4 = replace(lower(substr(var.env, 0, 4)), local.mssql_regex, "")
  group-regex_compliant = replace(lower(var.group), local.mssql_regex, "")
  project-regex_compliant = replace(lower(var.project), local.mssql_regex, "")
  mssql-userDefinedString-regex_compliant = replace(lower(var.userDefinedString), local.mssql_regex, "")
  mssql_prefix = "${local.env-regex_compliant_4}-${local.group-regex_compliant}-${local.project-regex_compliant}"
  mssql_server_name = substr("${local.mssql_prefix}-${local.mssql-userDefinedString-regex_compliant}", 0, 63)
}
