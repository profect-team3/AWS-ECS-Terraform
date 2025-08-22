variable "name" { type = string }
variable "tags" {
  type = map(string)
  default = {}
}

variable "vpc_id"     { type = string }
