resource "kubernetes_service_account_v1" "registry_secret_sa" {
  metadata {
    name      = "registry-secret-sa"
    namespace = var.namespace_name
  }

  image_pull_secret {
    name = var.secret_name
  }
}
