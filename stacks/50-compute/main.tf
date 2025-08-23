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

data "terraform_remote_state" "database" {
  backend = "local"
  config = {
    path = "${path.module}/../30-data/terraform.tfstate"
  }
}

locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

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
  vpc_id       = local.vpc_id
  namespace    = var.namespace
}

locals {
  env_value_source = {
    DB_URL                 = "jdbc:postgresql://${data.terraform_remote_state.database.outputs.postgres_private_ips}:5432/order_platform"
    DB_USERNAME            = var.db_username
    # MONGODB_HOST           = var.mongodb_host
    # MONGO_NAME             = var.mongo_name
    REDIS_HOST             = data.terraform_remote_state.database.outputs.redis_private_ips
    REDIS_PORT             = var.redis_port
    ORDER_SVC_URI          = "http://order.${var.namespace}:8084"
    STORE_SVC_URI          = "http://store.${var.namespace}:8082"
    MCP_SERVER_SVC_URI     = "http://mcpserver.${var.namespace}:8099"
    OAUTH_JWKS_URI         = var.oauth_jwks_uri
    AUTH_INTERNAL_AUDIENCE = var.auth_internal_audience
    TOSS_URL               = var.toss_url
  }

  service_definitions_resolved = {
    for svc, def in var.service_definitions :
    svc => merge(def, {
      image = "${lookup(module.ecr.repository_urls, svc, module.ecr.repository_names["user"])}:latest"
      env_map     = { for k in def.env_keys : k => lookup(local.env_value_source, k, "") }
      secret_keys = def.secret_keys
    })
  }
}

# ECS Task
module "ecs_task" {
  source                 = "../../modules/compute/ecs-task-definition"
  name                   = local.name
  region                 = var.region
  tags                   = local.tags

  secret_names           = var.secret_names
  service_definitions    = local.service_definitions_resolved
  ecs_task_role_arns     = local.ecs_task_role_arns
  ecs_task_execution_role_arn = local.ecs_task_execution_role_arn
}
