module "namespace" {
  source         = "./modules/namespace"
  namespace_name = var.namespace_name
  description_annotations = var.description_annotations
  environment = var.environment

}

module "secret" {
  source            = "./modules/secrets"
  namespace_name    = var.namespace_name
  registry_user     = var.registry_user
  registry_password = var.registry_password
  registry_server   = var.registry_server
  registry_email    = var.registry_email
}

module "service_account" {
  source = "./modules/service_account"
  namespace_name = var.namespace_name
  secret_name = var.secret_name
}