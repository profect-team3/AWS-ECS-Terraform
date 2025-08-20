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

locals {
  name = "${var.project}-${var.env}"
  tags = merge(var.tags, { Project = var.project, Env = var.env })
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids
  sg_alb_id = data.terraform_remote_state.security.outputs.sg_alb_id
  # vpc_id = "vpc-xxxxxxxx"
  # private_subnet_ids = ["subnet-xxxxxxxxxxxxxxxxx"]
}

# 1) ALB (Private)
module "alb" {
  source            = "../../modules/edge/alb"
  name              = local.name
  vpc_id            = local.vpc_id
  subnet_ids        = local.private_subnet_ids
  sg_alb_id         = local.sg_alb_id
  # alb_certificate_arn = var.alb_certificate_arn
  health_check_path = var.health_check_path
  services          = var.services
  tags              = var.tags
}

# 2) NLB (Private) → ALB 체인
module "nlb" {
  source        = "../../modules/edge/nlb"
  name          = local.name
  vpc_id            = local.vpc_id
  subnet_ids    = local.private_subnet_ids
  listener_ports= [80]
  alb_arn       = module.alb.alb_arn
  tags          = var.tags

  depends_on = [module.alb]
}

