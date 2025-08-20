# output "service_security_group_ids" {
#   description = "서비스별 ECS ENI SG (DB SG에서 이 SG들을 소스로 허용)"
#   value       = { for k, sg in aws_security_group.svc : k => sg.id }
# }
#
# output "service_arns" {
#   value = { for k, s in aws_ecs_service.svc : k => s.arn }
# }
#
# output "task_definition_arns" {
#   value = { for k, t in aws_ecs_task_definition.svc : k => t.arn }
# }
#
# output "log_group_names" {
#   value = { for k, lg in aws_cloudwatch_log_group.svc : k => lg.name }
# }
