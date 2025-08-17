locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
}

# VPC
module "vpc" {
  source   = "../../modules/network/vpc"
  name     = local.name
  tags     = local.tags
  vpc_cidr = var.vpc_cidr
}

# Subnet
module "subnets" {
  source          = "../../modules/network/subnets"
  name            = local.name
  tags            = local.tags
  vpc_id          = module.vpc.vpc_id
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

# IGW / NAT
module "igw_nat" {
  source                = "../../modules/network/igw-nat"
  name                 = local.name
  tags                 = local.tags
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.subnets.public_subnet_ids
  private_subnet_ids   = module.subnets.private_subnet_ids
  multi_nat            = var.multi_nat
}
