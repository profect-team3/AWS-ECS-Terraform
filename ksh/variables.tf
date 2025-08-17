variable "project_name" {
  type = string
}
variable "env" {
  type = string
}
variable "region" {
  type = string
  default = "ap-northeast-2"
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "NotValid CIDR block"
  }
}

variable "public_subnet_cidr" {
  type = list(string)
}

variable "private_subnet_cidr" {
  type = list(string)
}

variable "availability_zones"{
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "igw_id" {}
variable "public_subnet_id" {}
variable "common_tags" {
  type = map(string)
  default = {}
}

variable "private_subnet_id" {
  type = list(string)
}

variable "my_ip" {
  type = string
  description = "IP - SSH Access"
}