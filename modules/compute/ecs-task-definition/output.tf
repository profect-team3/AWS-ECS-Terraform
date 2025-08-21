output "task_definition_arns" {
  value = { for k, t in aws_ecs_task_definition.svc_task : k => t.arn }
}

output "log_group_names" {
  value = { for k, lg in aws_cloudwatch_log_group.svc : k => lg.name }
}
