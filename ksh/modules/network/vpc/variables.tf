variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "cidr" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
