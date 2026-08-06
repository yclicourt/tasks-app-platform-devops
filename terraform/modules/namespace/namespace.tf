resource "kubernetes_namespace_v1" "namespace" {
  
  metadata {
    name = "tasks-app"
    labels = {
      environment = var.environment
      managed_by  = "terraform"
      team        = "DevOps"
    }
    annotations = {
      "description" = var.description_annotations
    }
  }

}