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