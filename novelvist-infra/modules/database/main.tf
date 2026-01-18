resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
/*
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = var.server_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.database_config.version
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password != "" ? var.administrator_password : random_password.db_password.result
  storage_mb             = var.storage_mb
  sku_name               = var.sku_name
  zone                   = "1"

  delegated_subnet_id = var.db_subnet_id
  private_dns_zone_id = azurerm_private_dns_zone.postgres.id

  tags = var.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.vnet_link]
}
*/

resource "azurerm_postgresql_flexible_server" "main" {
  name                = var.database_config.server_name
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login    = var.database_config.administrator_login
  administrator_password = var.administrator_password != "" ? var.administrator_password : random_password.db_password.result
  version                = "13"
  sku_name               = var.database_config.sku_name
  storage_mb             = var.database_config.storage_mb
  delegated_subnet_id    = var.db_subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.postgres.id

  tags = var.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.vnet_link]
}


resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "${var.server_name}.private.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "${var.server_name}-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.resource_group_name
}