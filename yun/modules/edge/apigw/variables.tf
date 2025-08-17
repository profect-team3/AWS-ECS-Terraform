variable "name" { type = string }
variable "tags" {
  type = map(string)
  default = {}
}
# VPC Link
variable "nlb_arn"  { type = string }
variable "nlb_dns_name" { type = string }
variable "nlb_port" {
  type = number
  default = 80
}

# 리소스 경로(선택). 비우면 ANY /{proxy+}만 생성
variable "paths" {
  type    = list(string)
  default = []
}

variable "stage_name"  {
  type = string
  default = "prod"
}
variable "description" {
  type = string
  default = "Edge REST API"
}

# 커스텀 도메인 (Route53 ALIAS 대상)
variable "domain_name"     { type = string } # api.example.com
variable "certificate_arn" { type = string } # Regional ACM
