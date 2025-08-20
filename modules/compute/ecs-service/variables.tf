# variable "name"     { type = string }
# variable "region"  { type = string }
# variable "tags" {
#   type    = map(string)
#   default = {}
# }
#
# variable "cluster_arn" {
#   description = "ECS Cluster ARN"
#   type        = string
# }
#
# variable "vpc_id" {
#   description = "VPC ID (서비스 SG 생성용)"
#   type        = string
# }
#
# variable "private_subnet_ids" {
#   description = "서비스가 배치될 프라이빗 서브넷 목록"
#   type        = list(string)
# }
#
# variable "alb_sg_id" {
#   description = "ALB Security Group ID (ECS 인바운드 소스)"
#   type        = string
# }
#
# variable "service_definitions" {
#   description = "서비스별 설정 (IAM Role은 외부 모듈에서 주입)"
#   type = map(object({
#     image                  = string              # ECR URL:TAG 등
#     port                   = number              # 컨테이너 포트
#     cpu                    = number              # 256/512/1024...
#     memory                 = number              # MiB
#     desired_count          = number
#     target_group_arn       = string              # ALB Target Group ARN
#     exec_role_arn          = string              # ← 외부 IAM 모듈에서 주입
#     task_role_arn          = string              # ← 외부 IAM 모듈에서 주입
#
#     env                    = optional(map(string), {})
#     secrets                = optional(list(object({
#       name      = string
#       valueFrom = string
#     })), [])
#
#     assign_public_ip                      = optional(bool, false)
#     health_check_grace_period_seconds     = optional(number, 30)
#     platform_version                      = optional(string, "LATEST")
#     enable_execute_command                = optional(bool, true)
#     propagate_tags_from_service           = optional(bool, true)
#     log_retention_days                    = optional(number, 14)
#   }))
# }
