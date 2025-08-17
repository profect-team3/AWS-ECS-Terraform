module "vpc" {
  source  = "./modules/network/vpc"
  project = var.project
  env     = var.env
  cidr    = var.vpc_cidr
  tags    = var.tags
}

module "public_subnet" {
  source = "./modules/network/subnet"
  vpc_id = module.vpc.vpc_id
  cidr   = var.public_subnet_cidr
  azs    = var.availability_zones
  public = true
  tags   = var.tags
}

module "private_subnet" {
  source = "./modules/network/subnet"
  vpc_id = module.vpc.vpc_id
  cidr   = var.private_subnet_cidr
  azs    = var.availability_zones
  public = false
  tags   = var.tags
}

module "igw" {
  source = "./modules/network/igw"
  vpc_id = module.vpc.vpc_id
}
