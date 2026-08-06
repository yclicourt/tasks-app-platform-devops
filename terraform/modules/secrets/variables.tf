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

variable "namespace_name" {
  type = string
}
