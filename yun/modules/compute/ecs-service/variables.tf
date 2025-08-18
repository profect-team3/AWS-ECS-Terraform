variable "name" { type = string }
variable "tags" {
  type = map(string)
  default = {}
}

variable "cluster_id" { type = string }

variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }

variable "enable_execute_command" {
  type    = bool
  default = true
}
variable "log_retention_days" {
  type    = number
  default = 7
}

# 개별 서비스 정의
variable "services" {
  type = list(object({
    name            = string
    cpu             = number
    memory          = number
    desired_count   = number
    image           = string
    container_port  = number
    env_vars        = map(string)
    secrets         = list(object({ name = string, arn = string }))
    autoscaling     = object({ min = number, max = number, target_cpu = number })
  }))
}
