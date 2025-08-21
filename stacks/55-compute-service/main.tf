data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "${path.module}/../10-network/terraform.tfstate"
  }
}

data "terraform_remote_state" "security" {
  backend = "local"
  config = {
    path = "${path.module}/../20-security/terraform.tfstate"
  }
}

data "terraform_remote_state" "edge" {
  backend = "local"
  config = {
    path = "${path.module}/../40-edge/terraform.tfstate"
  }
}

data "terraform_remote_state" "compute" {
  backend = "local"
  config = {
    path = "${path.module}/../50-compute/terraform.tfstate"
  }
}

locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })

  sg_ecs_service_ids = data.terraform_remote_state.security.outputs.sg_ecs_service_ids
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  cluster_arn = data.terraform_remote_state.compute.outputs.cluster_arn
  task_definition_arns = data.terraform_remote_state.compute.outputs.task_definition_arns

  alb_tgs =data.terraform_remote_state.edge.outputs.alb_tgs
}

# ECS Services (다중)
module "ecs_service" {
  source                 = "../../modules/compute/ecs-service"
  name                   = local.name
  region                 = var.region
  tags                   = local.tags

  service_definitions    = var.service_definitions
  cluster_arn            = local.cluster_arn
  task_definition_arns   = local.task_definition_arns
  private_subnet_ids     = local.private_subnet_ids
  sg_ecs_service_ids     = local.sg_ecs_service_ids
  target_group_arns      = local.alb_tgs

  # enable_execute_command = var.enable_execute_command
  # log_retention_days     = var.log_retention_days
}
