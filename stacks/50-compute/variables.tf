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

# ecs task definitions
variable "service_definitions" {
  type = map(object({
    port         = number
    ingress_from = string
    egress       = list(object({
      to   = string
      port = number
    }))
    cpu    = string
    memory = string
  }))
}
