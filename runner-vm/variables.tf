variable "resource_group_name" {
  description = "Groupe de ressources existant où créer la VM runner"
  type        = string
  default     = "fbarryRG"
}

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "francecentral"
}

variable "owner" {
  description = "Propriétaire des ressources (tag owner)"
  type        = string
  default     = "fbarry"
}

variable "vm_size" {
  description = "Taille de la VM (si Standard_B2s indisponible : Standard_D2s_v3)"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "Utilisateur Linux créé sur la VM (utilisé par Ansible en SSH)"
  type        = string
  default     = "azureuser"
}

variable "vnet_address_space" {
  description = "Plage d'adresses du VNet du runner"
  type        = string
  default     = "10.20.0.0/16"
}

variable "subnet_address_prefix" {
  description = "Plage d'adresses du sous-réseau du runner"
  type        = string
  default     = "10.20.1.0/24"
}

variable "allowed_ssh_ip" {
  description = "Ton IP publique personnelle, seule autorisée en SSH (format x.x.x.x, sans /32)"
  type        = string
}