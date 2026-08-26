resource "azurerm_postgresql_flexible_server_firewall_rule" "backend_outbound" {
  for_each = toset(split(",", azurerm_linux_web_app.backend.outbound_ip_addresses))

  name             = "allow-backend-${replace(each.value, ".", "-")}"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = each.value
  end_ip_address   = each.value
}