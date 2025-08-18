variable "name" { type = string }
variable "tags" {
  type = map(string)
  default = {}
}

variable "subnet_ids" { type = list(string) }
variable "listener_port" {
  type = number
  default = 80
}
variable "alb_arn" { type = string }

