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

module "public_route_table" {
  source = "./modules/network/routetable"
  vpc_id = var.vpc_id
  igw_id = var.igw_id
  public_subnet_id = var.public_subnet_id
  project_name = var.project_name
  common_tags = var.common_tags
}

module "private_nat" {
  source = "./modules/network/nat"
  vpc_id = var.vpc_id
  private_subnet_id = var.private_subnet_id
  nat_eip_allocation_id = var.nat_eip_allocation_id
  availability_zones = var.availability_zones
  project_name = var.project
  common_tags = var.tags
}
