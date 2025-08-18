# # 서비스별 Execution Role ARN 맵 (ecs-service 모듈에 그대로 입력)
# output "exec_role_arns" {
#   description = "서비스별 Execution Role ARNs (공유 모드일 경우 모든 서비스가 동일 ARN)"
#   value = var.create_execution_role_per_service
#     ? { for s in var.services : s => aws_iam_role.exec[s].arn }
#     : { for s in var.services : s => aws_iam_role.exec_shared[0].arn }
# }
#
# # 서비스별 Task Role ARN 맵
# output "task_role_arns" {
#   value = { for s in var.services : s => aws_iam_role.task[s].arn }
# }
