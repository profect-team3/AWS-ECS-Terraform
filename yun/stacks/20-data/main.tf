data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "${path.module}/../10-network/terraform.tfstate"  # ← 10-network의 state 파일 경로
  }
}

locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
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