variable "name" { type = string }
variable "tags" {
  type = map(string)
  default = {}
}

variable "subnet_id" { type = string }
variable "subnet_ids" {type = list(string)}
variable "sg_mongo_id" { type = string }

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
variable "db_username" {
  type = string
  default = "Goorm3project"
}
variable "db_password" {
  type = string
  default = "Goorm3project"
}

variable "instance_class" {
  type = string
  default = "db.t3.medium"
}
