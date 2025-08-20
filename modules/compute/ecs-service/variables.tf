variable "name"     { type = string }
variable "region"  { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

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

variable "cluster_arn" {
  description = "ECS Cluster ARN"
  type        = string
}

variable "task_definition_arns" {
  description = "서비스가 배치될 프라이빗 서브넷 목록"
  type        = map(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "sg_ecs_service_ids" {
  type = map(string)
}

variable "target_group_arns" {
  type = map(string)
}
