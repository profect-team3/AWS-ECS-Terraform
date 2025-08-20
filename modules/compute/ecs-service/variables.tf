variable "name"     { type = string }
variable "region"  { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

variable "service_definitions" {
  type = map(object({
    port         = number
    ingress_from = string
    egress       = list(object({
      to   = string
      port = number
    }))
    cpu    = string
    memory = string
  }))
}

# variable "cluster_arn" {
#   description = "ECS Cluster ARN"
#   type        = string
# }

# variable "vpc_id" {
#   description = "VPC ID (서비스 SG 생성용)"
#   type        = string
# }
#
# variable "private_subnet_ids" {
#   description = "서비스가 배치될 프라이빗 서브넷 목록"
#   type        = list(string)
# }
#
# variable "alb_sg_id" {
#   description = "ALB Security Group ID (ECS 인바운드 소스)"
#   type        = string
# }
