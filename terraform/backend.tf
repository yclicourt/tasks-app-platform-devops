terraform {
  required_version = "1.15.8"
  cloud {
    organization = "yoadevOps"
    workspaces {
      name = "Infrastructure-TasksApp"
    }
  }
}