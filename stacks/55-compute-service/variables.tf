variable "project"             { type = string }
variable "env"                 { type = string }
variable "region"              { type = string }
variable "tags" {
  type        = map(string)
  default     = {}
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
    desired_count          = number
    enable_execute_command = bool
  }))
}