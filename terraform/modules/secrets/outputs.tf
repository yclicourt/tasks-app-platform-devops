output "secret_name" {
  value = kubernetes_secret_v1.registry_secret.metadata[0].name
}