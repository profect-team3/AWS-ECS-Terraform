# ecs service
resource "aws_ecs_service" "svc" {
  for_each                = var.service_definitions
  name                    = "${var.name}-${each.key}"
  cluster                 = var.cluster_arn
  task_definition         = var.task_definition_arns[each.key]
  # desired_count           = each.value.desired_count
  enable_execute_command  = lookup(each.value, "enable_execute_command", true)
  launch_type             = "FARGATE"
  platform_version        = lookup(each.value, "platform_version", "LATEST")
  propagate_tags          = lookup(each.value, "propagate_tags_from_service", true) ? "SERVICE" : "NONE"
  health_check_grace_period_seconds = lookup(each.value, "health_check_grace_period_seconds", 30)

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.sg_ecs_service_ids[each.key]]
    assign_public_ip = lookup(each.value, "assign_public_ip", false)
  }

  load_balancer {
    target_group_arn = var.target_group_arns[each.key]
    container_name   = each.key
    container_port   = each.value.port
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  lifecycle {
    # 외부 오토스케일러/배포툴과 충돌 방지
    ignore_changes = [desired_count]
  }

  tags = merge(var.tags, {
    Service = each.key
  })
}
