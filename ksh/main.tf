# VPC
module "vpc" {
  source  = "./modules/network/vpc"
  project = var.project
  env     = var.env
  cidr    = var.vpc_cidr
  tags    = var.tags
}

module "subnet" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc_id
  cidr   = var.subnet_cidr
  azs    = var.availability_zones
  public = true
  tags   = var.tags
}