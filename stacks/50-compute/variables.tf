variable "project"             { type = string }
variable "env"                 { type = string }
variable "region"              { type = string }
variable "tags" {
  type        = map(string)
  default     = {}
}

# ecr
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

# ecs cluster
variable "namespace" {
  type = string
  default = "svc.local"
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
    env_keys    = list(string)
    secret_keys = list(string)
  }))
}

# env
variable "db_username"            { type = string }
# variable "mongodb_host"           { type = string }
# variable "mongo_name"             { type = string }
variable "redis_port"             { type = string }
variable "oauth_jwks_uri"         { type = string }
variable "auth_internal_audience" { type = string }
variable "toss_url"               { type = string }

variable "secret_names" {
  type        = map(string)
}
