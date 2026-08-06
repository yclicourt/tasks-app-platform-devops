variable "namespace_name" {
  description = "Namespace denomination"
  type        = string
}

variable "registry_server" {
  description = "Description registry server"
  type        = string
  sensitive   = true
}

variable "registry_user" {
  description = "Description registry user"
  type        = string
  sensitive   = true
}

variable "registry_password" {
  description = "Description registry password"
  type        = string
  sensitive   = true
}

variable "registry_email" {
  description = "Description registry email"
  type        = string
  sensitive   = true
}

variable "description_annotations" {
  description = "Development environment namespace"
  type        = string
}

variable "environment" {
  description = "Deployment Environment"
  type        = string


  validation {
    condition = contains([
      "dev", "staging", "prod"
    ], var.environment)
    error_message = "Environment must be dev, staging or prod"
  }
}

variable "secret_name" {
  description = "Secret name denomination"
  type        = string
  sensitive   = true
}
