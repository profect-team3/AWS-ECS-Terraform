#VPC
module "vpc" {
  source  = "./modules/network/vpc"
  project = var.project_name
  env     = var.env
  cidr    = var.vpc_cidr
  tags    = var.tags
}

#Subnet
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

#IGW
module "igw" {
  source = "./modules/network/igw"
  vpc_id = module.vpc.vpc_id
}

#Route Table
module "public_route_table" {
  source = "./modules/network/routetable"
  vpc_id = module.vpc.vpc_id
  igw_id = module.igw.igw_id
  public_subnet_id = module.private_subnet.subnet_id
  project_name = var.project_name
  common_tags = var.common_tags
}

#NAT
module "private_nat" {
  source = "./modules/network/nat"
  vpc_id = var.vpc_id
  private_subnet_id = var.private_subnet_id
  availability_zones = var.availability_zones
  project_name = var.project_name
  common_tags = var.tags
}

#Security Group
module "sg" {
  source = "./modules/network/sg"
  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  my_ip = var.my_ip
}

#VPC Endpoint (S3)
module "vpc_endpoint_s3" {
  source = "./modules/network/vpcendpoint"
  vpc_id = module.vpc.vpc_id
  private_route_table_ids = [module.private_nat.private_route_table_id]
  service_name = "com.amazonaws.ap-northeast-2.s3"
  project_name = var.project_name
  common_tags = var.tags
}

#IAM
module "iam" {
  source = "./modules/iam"
  project_name = var.project_name
  env = var.env
  tags = var.tags
}