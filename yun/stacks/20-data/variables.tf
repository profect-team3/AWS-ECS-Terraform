variable "project"             { type = string }
variable "env"                 { type = string }
variable "region"              { type = string }
variable "tags" {
  type        = map(string)
  default     = {}
}

# ECS Fargate 서비스 SG들(이 SG들에서만 접근 허용)
variable "ecs_security_group_ids" {
  type = list(string)
}

#SSH 접근 CIDR
# variable "ssh_allowed_cidrs" {
#   type    = list(string)
#   default = []
# }

# 공통 EC2 스펙
variable "ami_id"         { type = string }
variable "instance_type"  { type = string }
variable "key_name"       {
  type = string
  default = null
}
variable "volume_size"    {
  type = number
  default = 30
}
variable "volume_type"    {
  type = string
  default = "gp3"
}
variable "volume_iops"    {
  type = number
  default = null
}

# postgres
variable "postgres_ami_id"        {
  type = string
  default = null
}
variable "postgres_instance_type" {
  type = string
  default = null
}
variable "postgres_volume_size"   {
  type = number
  default = null
}
variable "postgres_volume_type"   {
  type = string
  default = null
}
variable "postgres_key_name"      {
  type = string
  default = null
}

# redis
variable "redis_ami_id"        {
  type = string
  default = null
}
variable "redis_instance_type" {
  type = string
  default = null
}
variable "redis_volume_size"   {
  type = number
  default = null
}
variable "redis_volume_type"   {
  type = string
  default = null
}
variable "redis_key_name"      {
  type = string
  default = null
}

# mongo
variable "mongo_ami_id"        {
  type = string
  default = null
}
variable "mongo_instance_type" {
  type = string
  default = null
}
variable "mongo_volume_size"   {
  type = number
  default = null
}
variable "mongo_volume_type"   {
  type = string
  default = null
}
variable "mongo_key_name"      {
  type = string
  default = null
}
