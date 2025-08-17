# output "service_arns" {
#   value = { for name, svc in aws_ecs_service.svc : name => svc.arn }
# }
# output "task_definition_arns" {
#   value = { for name, td in aws_ecs_task_definition.td : name => td.arn }
# }
# output "log_groups" {
#   value = { for name, lg in aws_cloudwatch_log_group.log : name => lg.name }
# }
# output "execution_role_arns" {
#   value = { for name, r in aws_iam_role.exec : name => r.arn }
# }
# output "task_role_arns" {
#   value = { for name, r in aws_iam_role.task : name => r.arn }
# }
