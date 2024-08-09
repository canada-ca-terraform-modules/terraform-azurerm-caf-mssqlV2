output "mssql_server" {
  description = "MSSQL server object"
  value = azurerm_mssql_server.mssql_sever
}

output "mssql_server_name" {
  description = "MSSQL server name"
  value = azurerm_mssql_server.mssql_sever.name
}

output "mssql_server_id" {
  description = "MSSQL server ID"
  value = azurerm_mssql_server.mssql_sever.id
}