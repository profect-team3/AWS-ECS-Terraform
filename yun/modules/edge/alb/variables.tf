variable "name" { type = string }
variable "tags"    {
  type = map(string)
  default = {}
}

variable "vpc_id"     { type = string }
variable "subnet_ids" { type = list(string) }  # 프라이빗 서브넷

# VPC Link/NLB에서 들어올 소스만 허용
variable "allowed_cidrs" {
  type = list(string)
  default = []
}
variable "allowed_sg_ids"{
  type = list(string)
  default = []
}

# variable "alb_certificate_arn" {
#   description = "내부 ALB에서 TLS 종단 시 사용할 ACM 인증서(선택, 있으면 HTTPS 리스너 생성)"
#   type        = string
#   default     = null
# }

variable "health_check_path" {
  description = "공통 헬스체크 경로"
  type        = string
  default     = "/health"
}

variable "services" {
  description = "서비스별 포트와 라우팅 경로"
  type = map(object({
    port  = number
    paths = list(string)
  }))
}

