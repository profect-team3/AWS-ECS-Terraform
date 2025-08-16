variable "project" {
  type = string
}
variable "env"     {
  type = string
}
variable "region"  {
  type = string
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "vpc_cidr" {
  type = string
  validation {
    condition = can(cidrnetmask(var.vpc_cidr))
    error_message = "NotValid CIDR block"
  }
}
