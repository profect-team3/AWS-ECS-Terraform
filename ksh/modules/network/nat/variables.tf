variable "vpc_id" {
  type = string
}

variable "private_subnet_id" {
  type = list(string)
}

variable "nat_eip_allocation_id" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "project_name" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
