data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "${path.module}/../10-network/terraform.tfstate"
  }
}

locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
}

module "security" {
  source   = "../../modules/security"
  name     = local.name
  tags     = local.tags
  vpc_id   = local.vpc_id
  service_definitions = var.service_definitions
}
