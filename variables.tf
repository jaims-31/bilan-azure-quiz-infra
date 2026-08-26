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