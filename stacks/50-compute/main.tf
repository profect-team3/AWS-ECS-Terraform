data "terraform_remote_state" "security" {
  backend = "local"
  config = {
    path = "${path.module}/../20-security/terraform.tfstate"
  }
}

locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })

  ecs_task_execution_role_arn = data.terraform_remote_state.security.outputs.ecs_task_execution_role_arn
  ecs_task_role_arns = data.terraform_remote_state.security.outputs.ecs_task_role_arns
}

# ECR
module "ecr" {
  source            = "../../modules/compute/ecr"
  name              = local.name
  repositories      = keys(var.service_definitions)
  image_mutability  = var.image_mutability
  # scan_on_push     = var.scan_on_push
  # encryption_type  = var.encryption_type
  # kms_key_arn      = var.kms_key_arn

  keep_tag_prefixes = var.keep_tag_prefixes
  keep_any_last     = var.keep_any_last
}

# ECS Cluster
module "ecs_cluster" {
  source       = "../../modules/compute/ecs-cluster"
  name         = local.name
}


locals {
  expanded_service_definitions = {
    for svc, conf in var.service_definitions : svc => merge(conf, {
      image = "${lookup(module.ecr.repository_urls, svc, module.ecr.repository_names["user"])}:latest"
      # environment = [
      #   for e in lookup(conf, "egress", []) : {
      #     name  = "${upper(e.to)}_HOST"
      #     value = "${e.to}.service.local"
      #   }
      #   if contains(["postgres", "redis", "mongo"], e.to)
      # ]
    })
  }
}

# ECS Task
module "ecs_task" {
  source                 = "../../modules/compute/ecs-task-definition"
  name                   = local.name
  region                 = var.region
  tags                   = local.tags

  service_definitions    = local.expanded_service_definitions
  ecs_task_role_arns     = local.ecs_task_role_arns
  ecs_task_execution_role_arn = local.ecs_task_execution_role_arn
}
