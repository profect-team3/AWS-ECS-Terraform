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

# PostgreSQL
module "postgres" {
  for_each             = toset(local.private_subnet_ids)
  source              = "../../modules/data/ec2-postgres"
  name                = local.name
  vpc_id              = local.vpc_id
  subnet_id           = each.value
  # ssh_allowed_cidrs   = var.ssh_allowed_cidrs

  ami_id        = coalesce(var.postgres_ami_id, var.ami_id)
  instance_type = coalesce(var.postgres_instance_type, var.instance_type)
  key_name      = coalesce(var.postgres_key_name, var.key_name)

  volume_size = coalesce(var.postgres_volume_size, var.volume_size)
  volume_type = coalesce(var.postgres_volume_type, var.volume_type)
  volume_iops = var.volume_iops

  tags        = local.tags
}

# Redis
module "redis" {
  for_each             = toset(local.private_subnet_ids)
  source              = "../../modules/data/ec2-redis"
  name                = local.name
  vpc_id              = local.vpc_id
  subnet_id           = each.value
  # ssh_allowed_cidrs   = var.ssh_allowed_cidrs

  ami_id        = coalesce(var.redis_ami_id, var.ami_id)
  instance_type = coalesce(var.redis_instance_type, var.instance_type)
  key_name      = coalesce(var.redis_key_name, var.key_name)

  volume_size = coalesce(var.redis_volume_size, var.volume_size)
  volume_type = coalesce(var.redis_volume_type, var.volume_type)
  volume_iops = var.volume_iops

  tags        = local.tags
}

# MongoDB
module "mongo" {
  for_each             = toset(local.private_subnet_ids)
  source              = "../../modules/data/ec2-mongo"
  name                = local.name
  vpc_id              = local.vpc_id
  subnet_id           = each.value
  # ssh_allowed_cidrs   = var.ssh_allowed_cidrs

  ami_id        = coalesce(var.mongo_ami_id, var.ami_id)
  instance_type = coalesce(var.mongo_instance_type, var.instance_type)
  key_name      = coalesce(var.mongo_key_name, var.key_name)

  volume_size = coalesce(var.mongo_volume_size, var.volume_size)
  volume_type = coalesce(var.mongo_volume_type, var.volume_type)
  volume_iops = var.volume_iops

  tags        = local.tags
}

# # Postgres 접근 허용
# resource "aws_security_group_rule" "ecs_to_postgres" {
#   type                     = "ingress"
#   security_group_id        = data.terraform_remote_state.data.outputs.postgres_sg_ids["0"] # 키는 환경에 따라
#   from_port                = 5432
#   to_port                  = 5432
#   protocol                 = "tcp"
#   source_security_group_id = var.ecs_service_sg_id
# }

# Redis, Mongo도 동일 패턴으로 추가
