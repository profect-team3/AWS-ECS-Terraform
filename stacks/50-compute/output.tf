output "ecr_repository_url"  { value = module.ecr.repository_urls }
output "cluster_arn"          { value = module.ecs_cluster.cluster_arn }
output "task_definition_arns"{ value = module.ecs_task.task_definition_arns }

