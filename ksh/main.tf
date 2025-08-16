# VPC
module "vpc" {
  source  = "./modules/network/vpc"
  project = var.project
  env     = var.env
  cidr    = var.vpc_cidr
  tags    = var.tags
}
