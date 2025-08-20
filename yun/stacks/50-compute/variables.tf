variable "project"             { type = string }
variable "env"                 { type = string }
variable "region"              { type = string }
variable "tags" {
  type        = map(string)
  default     = {}
}

# 네트워크 (서비스 배포용)
# variable "service_security_group_ids"{ type = list(string) }

# api services
variable "repositories" {
  type    = list(string)
  default = ["repo"]
}

variable "api_services" {
  type    = list(string)
  default = ["user","store","auth","order","payment","review","mcpserver","ai"]
}
variable "image_mutability" {
  type = string
  default = "MUTABLE"
}
# variable "scan_on_push"     {
#   type = bool
#   default = true
# }
# variable "encryption_type"  {
#   type = string
#   default = "AES256"
# }
# variable "kms_key_arn"      {
#   type = string
#   default = null
# }
variable "keep_tag_prefixes"{
  type    = list(string)
  default = ["latest"]
}
variable "keep_any_last"    {
  type = number
  default = 5
}


# ECS Services 리스트
# variable "services" {
#   type = list(object({
#     name            = string
#     cpu             = number
#     memory          = number
#     desired_count   = number
#     image           = string
#     container_port  = number
#     env_vars        = map(string)
#     secrets         = list(object({ name = string, arn = string }))
#     autoscaling     = object({ min = number, max = number, target_cpu = number })
#   }))
# }
# variable "enable_execute_command" {
#   type = bool
#   default = true
# }
# variable "log_retention_days"     {
#   type = number
#   default = 7
# }
