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

# 1) ALB (Private)
# module "alb" {
#   source           = "../../modules/edge/alb"
#   name           = local.name
#   vpc_id           = local.vpc_id
#   subnet_ids       = local.private_subnet_ids
#   allowed_cidrs    = var.alb_allowed_cidrs
#   allowed_sg_ids   = var.alb_allowed_sg_ids
#   listener_port    = 80
#   listener_protocol= "HTTP"
#   target_groups    = var.alb_target_groups
#   tags             = var.tags
# }

# 2) NLB (Private) → ALB 체인
# module "nlb" {
#   source        = "../../modules/edge/nlb"
#   name          = local.name
#   subnet_ids    = local.private_subnet_ids
#   listener_port = 80
#   alb_arn       = module.alb.alb_arn
#   tags          = var.tags
# }

# 3) API Gateway (REST) + VPC Link → NLB
# module "apigw" {
#   source        = "../../modules/edge/apigw"
#   name          = local.name
#   nlb_arn       = module.nlb.nlb_arn
#   nlb_dns_name  = module.nlb.nlb_dns_name
#   nlb_port      = 80
#   paths         = var.apigw_paths
#   stage_name    = "prod"
#   description   = "Edge REST API"
#   domain_name   = var.edge_domain
#   certificate_arn = var.acm_certificate_arn
#   tags          = var.tags
# }

# 4) Route53 → APIGW 커스텀 도메인 Alias
# module "route53" {
#   source         = "../../modules/edge/route53"
#   name           = local.name
#   existing_hosted_zone_id = var.route53_zone_id
#   zone_name      = null
#   record_name    = var.edge_domain
#   alias_name     = module.apigw.domain_regional_domain_name
#   alias_zone_id  = module.apigw.domain_regional_zone_id
#   create_aaaa    = true
#   tags = local.tags
# }
