variable "project" { type = string }
variable "env"     { type = string }
variable "region"  { type = string }
variable "tags"    {
  type = map(string)
  default = {}
}

# # 퍼블릭 존
# variable "zone_name"              {
#   type = string
#   default = null
# }  # 새 존 만들 때
# variable "existing_hosted_zone_id"{
#   type = string
#   default = null
# }  # 기존 존 쓰면 여기 채움
#
# # ALB
# variable "alb_allowed_cidrs" {
#   type = list(string)
#   default = []
# }
# variable "alb_allowed_sg_ids"{
#   type = list(string)
#   default = []
# }
# variable "alb_target_groups" {
#   type = list(object({
#     name          = string
#     port          = number
#     protocol      = string
#     path_patterns = list(string)
#     health_check  = optional(object({
#       enabled             = optional(bool, true)
#       path                = optional(string, "/health")
#       healthy_threshold   = optional(number, 2)
#       unhealthy_threshold = optional(number, 2)
#       interval            = optional(number, 30)
#       timeout             = optional(number, 5)
#       matcher             = optional(string, "200-399")
#     }), {})
#   }))
# }
#
# # APIGW 도메인/ACM
# variable "edge_domain"         { type = string } # api.example.com
# variable "acm_certificate_arn" { type = string } # Regional
#
# # Route53 (퍼블릭)
# variable "route53_zone_id" { type = string }
#
# # (선택) 추가 경로
# variable "apigw_paths" {
#   type = list(string)
#   default = []
# }