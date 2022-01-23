
resource "azurerm_mssql_server" "jupdb" {
  name                         = "${var.hostname}sysdb"
  resource_group_name          = data.azurerm_resource_group.spokerg.name
  location                     = data.azurerm_resource_group.spokerg.location
  version                      = "12.0"
  administrator_login          = "dbuser"
  administrator_login_password = "8SOF5mTWeRbJ7h7B"
}

resource "azurerm_mssql_database" "jupdb" {
  name         = "${var.hostname}db"
  server_id    = azurerm_mssql_server.jupdb.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  #   max_size_gb  = 4
  #   read_scale     = true
  sku_name = "Basic"
  #   zone_redundant = true

  #   tags = {
  #     foo = "bar"
  #   }

}
