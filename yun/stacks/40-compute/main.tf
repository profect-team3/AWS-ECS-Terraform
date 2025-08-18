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
  # vpc_id = "vpc-xxxxxxxx"
  # private_subnet_ids = ["subnet-xxxxxxxxxxxxxxxxx"]
}

# ECR
module "ecr" {
  source            = "../../modules/compute/ecr"
  name              = local.name
  repositories      = var.api_services
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

# # ECS Services (다중)
# module "ecs_service" {
#   source                 = "../../modules/compute/ecs-service"
#   name                   = local.name
#   cluster_id             = module.ecs_cluster.id
#   subnet_ids             = local.private_subnet_ids
#   security_group_ids     = var.service_security_group_ids
#   services               = var.services
#   enable_execute_command = var.enable_execute_command
#   log_retention_days     = var.log_retention_days
# }

module "iam" {
  source   = "../../modules/compute/iam"
  name     = local.name
  region   = var.region
  services = var.api_services

  # Execution Role 전략
  create_execution_role_per_service = true
  exec_extra_policy_arns = []

  # (선택) secrets/parameters 권한
  # exec_secret_arns = {
  #   user  = ["arn:aws:secretsmanager:ap-northeast-2:123456789012:secret:user/*"]
  #   auth  = ["arn:aws:ssm:ap-northeast-2:123456789012:parameter/auth/*"]
  # }
  # exec_secret_arns_global   = []  # 모든 서비스 공통
  # exec_kms_key_arns         = {}  # { user=["arn:aws:kms:..:key/.."], ... }
  # exec_kms_key_arns_global  = []  # 공통 KMS 키

  # Task Role 권한
  task_role_policy_arns = {
    user  = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
    order = ["arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"]
  }

  task_role_inline_policies = {
    payment = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Effect = "Allow",
        Action = ["sqs:SendMessage"],
        Resource = ["arn:aws:sqs:ap-northeast-2:123456789012:payments-*"]
      }]
    })
  }

  # permissions_boundary_arn = "arn:aws:iam::123456789012:policy/Boundary/ecs-boundary"
  tags = var.tags
}