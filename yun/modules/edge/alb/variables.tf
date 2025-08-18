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

variable "listener_port"     {
  type = number
  default = 80
}
variable "listener_protocol" {
  type = string
  default = "HTTP"
}

# 서비스별 TargetGroup + Path 라우팅
variable "target_groups" {
  type = list(object({
    name          = string
    port          = number
    protocol      = string              # HTTP/HTTPS
    path_patterns = list(string)
    health_check  = optional(object({
      enabled             = optional(bool, true)
      path                = optional(string, "/health")
      healthy_threshold   = optional(number, 2)
      unhealthy_threshold = optional(number, 2)
      interval            = optional(number, 30)
      timeout             = optional(number, 5)
      matcher             = optional(string, "200-399")
    }), {})
  }))
}
