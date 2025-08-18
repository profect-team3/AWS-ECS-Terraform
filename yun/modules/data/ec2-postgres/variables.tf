variable "name" { type = string }
variable "tags" {
  type = map(string)
  default = {}
}

variable "vpc_id"  { type = string }
variable "subnet_id" { type = string }

variable "ami_id"        { type = string }
variable "instance_type" { type = string }
variable "key_name"      {
  type = string
  default = null
}

variable "volume_size" {
  type = number
  default = 30
}
variable "volume_type" {
  type = string
  default = "gp3"
}
variable "volume_iops" {
  type = number
  default = null
}

# (선택) SSH 허용 CIDR
variable "ssh_allowed_cidrs" {
  type    = list(string)
  default = []
}
