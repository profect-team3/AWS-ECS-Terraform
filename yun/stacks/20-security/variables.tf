variable "project"             { type = string }
variable "env"                 { type = string }
variable "region"              { type = string }
variable "tags" {
  type        = map(string)
  default     = {}
}

variable "service_definitions" {
  description = "Per-service SG definition (ingress from ALB, and specific egress to DB/Cache)"
  type = map(object({
    port         = number
    egress = list(object({
      to    = string
      port  = number
      proto = optional(string, "tcp")
    }))
  }))
}