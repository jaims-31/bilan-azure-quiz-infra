output "runner_public_ip" {
  description = "IP publique de la VM runner"
  value       = azurerm_public_ip.runner.ip_address
}

output "runner_ssh_private_key" {
  description = "Clé SSH privée pour se connecter à la VM (Ansible)"
  value       = tls_private_key.runner.private_key_openssh
  sensitive   = true
}

output "runner_admin_username" {
  description = "Utilisateur SSH de la VM"
  value       = var.admin_username
}

output "runner_nsg_name" {
  description = "Nom du NSG (utilisé par la pipeline pour ouvrir/fermer le SSH temporairement)"
  value       = azurerm_network_security_group.runner.name
}