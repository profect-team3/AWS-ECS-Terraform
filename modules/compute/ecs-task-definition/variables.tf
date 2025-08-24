variable "name"     { type = string }
variable "region"  { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

# env
variable "secret_names"        { type = map(string) }

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
    image  = string
    env_map     = map(string)
    secret_keys = list(string)
  }))
}

variable "ecs_task_execution_role_arn" {
  description = "ecs task execution role arn"
  type        = string
}

variable "ecs_task_role_arns" {
  description = "ecs task role anrs"
  type        = string
  # type        = map(string)
}

# variable "repository_urls" {
#   description = "서비스별 ECR 리포지토리 URL"
#   type        = map(string)
# }
#
# variable "repository_names" {
#   description = "서비스별 ECR 리포지토리 이름"
#   type        = map(string)
# }
