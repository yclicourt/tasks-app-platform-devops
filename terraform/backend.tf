terraform {
  required_version = "1.15.9"
  cloud {
    organization = "yoadevOps"
    workspaces {
      name = "Infrastructure-TasksApp"
    }
  }
}