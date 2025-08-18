variable "project" { type = string }
variable "env"     { type = string }
variable "region"  { type = string }
variable "tags"    {
  type = map(string)
  default = {}
}

# ALB
variable "alb_allowed_cidrs" {
  type = list(string)
  default = []
}
variable "alb_allowed_sg_ids"{
  type = list(string)
  default = []
}
variable "services" {
  type = map(object({
    port  = number
    paths = list(string)
  }))
}

variable "health_check_path" {
  description = "공통 헬스체크 경로"
  type        = string
  default     = "/health"
}

###



# APIGW 도메인/ACM
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
#
#
# # 퍼블릭 존
# variable "zone_name"              {
#   type = string
#   default = null
# }  # 새 존 만들 때
# variable "existing_hosted_zone_id"{
#   type = string
#   default = null
# }  # 기존 존 쓰면 여기 채움
