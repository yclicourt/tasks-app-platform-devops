locals {
  registry_auth = {
    auths = {
      "${var.registry_server}" : {
        username : var.registry_user
        password : var.registry_password
        email : var.registry_email
        auth : base64encode("${var.registry_user}:${var.registry_password}")
      }
    }

  }
}