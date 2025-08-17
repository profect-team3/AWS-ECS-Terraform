variable "vpc_id" {
  type = string
  description = "VPC ID - endpoint"
}

variable "private_route_table_ids" {
  type = list(string)
  description = "Private Subnet RT ID - VPC Endpoint"
}

variable "service_name" {
  type = string
  description = "VPC Endpoint - AWS service name"
}

variable "project_name" {
  type = string
  description = "Project Name - tagging"
}

variable "region" {
  type = string
  default = "ap-northeast-2"
}

variable "common_tags" {
  type = map(string)
  default = {}
}