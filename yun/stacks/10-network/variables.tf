variable "project"             { type = string }
variable "env"                 { type = string }
variable "region"              { type = string }
variable "tags" {
  type        = map(string)
  default     = {}
}

# Network
variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}
variable "azs" {
  description = "가용 영역 리스트 (하나 또는 여러 개)"
  type        = list(string)
}
variable "public_subnets" {
  description = "퍼블릭 서브넷 CIDR 리스트"
  type        = list(string)
}
variable "private_subnets" {
  description = "프라이빗 서브넷 CIDR 리스트"
  type        = list(string)
}
variable "multi_nat" {
  description = "AZ 별 NAT Gateway 여부"
  type        = bool
  default     = false
}
