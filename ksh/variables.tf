variable "project" {
  type = string
}
variable "env" {
  type = string
}
variable "region" {
  type = string
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "vpc_cidr" {
  type = string
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

variable "vpc_id" {}
variable "igw_id" {}
variable "public_subnet_id" {}
variable "project_name" {}
variable "common_tags" {
  type = map(string)
  default = {}
}