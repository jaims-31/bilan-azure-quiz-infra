variable "owner" {
  description = "Propriétaire des ressources (utilisé pour le tag owner)"
  type        = string
  default     = "fbarry"
}

variable "location" {
  description = "Région Azure de déploiement des ressources"
  type        = string
  default     = "francecentral"
}

variable "storage_account_name" {
  description = "Nom du Storage Account applicatif (unique dans tout Azure)"
  type        = string
  default     = "stfbarryquizapp"
}

variable "storage_container_name" {
  description = "Nom du conteneur blob applicatif"
  type        = string
  default     = "quiz-media"
}

variable "admin_object_id" {
  description = "Object ID Azure AD (accès Key Vault / Storage)"
  type        = string
  default     = "5722cb22-8d89-4281-a2e8-50351d87e976"
}