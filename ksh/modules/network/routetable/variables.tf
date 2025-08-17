variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "igw_id" {
  description = "IGW ID"
  type = string
}

variable "public_subnet_id" {
  description = "Public Subnet ID"
  type = string
}

variable "project_name" {
  description = "Project Name"
  type = string
}

variable "common_tags" {
  description = "Common Tags - All Resources"
  type = map(string)
  default = {}
}