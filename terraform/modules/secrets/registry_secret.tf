resource "kubernetes_secret_v1" "registry_secret" {
  metadata {
    name      = "registry-secret"
    namespace = var.namespace_name
  }
  type                           = "kubernetes.io/dockerconfigjson"
  wait_for_service_account_token = false
  data = {
    ".dockerconfigjson" = jsonencode(local.registry_auth)
  }
}