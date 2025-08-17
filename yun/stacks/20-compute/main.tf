# data "terraform_remote_state" "network" {
#   backend = "local"
#   config = {
#     path = "${path.module}/../10-network/terraform.tfstate"
#   }
# }

locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
  # vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  # private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  vpc_id = "vpc-xxxxxxxx"
  private_subnet_ids = ["subnet-xxxxxxxxxxxxxxxxx"]
}

# ECR (단일)
module "ecr" {
  source           = "../../modules/compute/ecr"
  name             = local.name
  repository_name  = var.repository_name
  image_mutability = var.image_mutability
  scan_on_push     = var.scan_on_push
  encryption_type  = var.encryption_type
  kms_key_arn      = var.kms_key_arn

  keep_tag_prefixes = var.keep_tag_prefixes
  keep_any_last     = var.keep_any_last
}

# ECS Cluster
module "ecs_cluster" {
  source       = "../../modules/compute/ecs-cluster"
  name         = local.name
}

# ECS Services (다중)
module "ecs_service" {
  source                 = "../../modules/compute/ecs-service"
  name                   = local.name
  cluster_id             = module.ecs_cluster.id
  subnet_ids             = local.private_subnet_ids
  security_group_ids     = var.service_security_group_ids
  services               = var.services
  enable_execute_command = var.enable_execute_command
  log_retention_days     = var.log_retention_days
}