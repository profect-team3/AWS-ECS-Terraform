locals {
  svc_keys = sort(keys(var.service_definitions))
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "svc" {
  for_each          = var.service_definitions
  name              = "/ecs/${var.name}-${each.key}"
  retention_in_days = lookup(each.value, "log_retention_days", 7)
  tags              = merge(var.tags, {
    Service = each.key
  })
}

# Task Definitions
resource "aws_ecs_task_definition" "svc_task" {
  for_each     = var.service_definitions
  family       = "${var.name}-${each.key}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu          = each.value.cpu
  memory       = each.value.memory

  execution_role_arn = var.ecs_task_execution_role_arn
  task_role_arn      = var.ecs_task_role_arns[each.key]

  runtime_platform {
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name      = each.key
      image     = "${lookup(var.repository_urls, each.key, values(var.repository_urls)[0])}/${lookup(var.repository_names, each.key, values(var.repository_names)[0])}:${each.key}"
      essential = true
      portMappings = [
        {
          containerPort = each.value.port
          hostPort      = each.value.port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.svc[each.key].name
          awslogs-region        = var.region
          awslogs-stream-prefix = each.key
        }
      }
    }
  ])

  tags = merge(var.tags, {
    Service = each.key
  })
}


# # -------- ECS Services (per service) --------
# resource "aws_ecs_service" "svc" {
#   for_each                = var.service_definitions
#   name                    = "${var.name}-${each.key}"
#   cluster                 = var.cluster_arn
#   task_definition         = aws_ecs_task_definition.svc[each.key].arn
#   desired_count           = each.value.desired_count
#   enable_execute_command  = lookup(each.value, "enable_execute_command", true)
#   launch_type             = "FARGATE"
#   platform_version        = lookup(each.value, "platform_version", "LATEST")
#   propagate_tags          = lookup(each.value, "propagate_tags_from_service", true) ? "SERVICE" : "NONE"
#   health_check_grace_period_seconds = lookup(each.value, "health_check_grace_period_seconds", 30)
#
#   network_configuration {
#     subnets          = var.private_subnet_ids
#     security_groups  = [aws_security_group.svc[each.key].id]
#     assign_public_ip = lookup(each.value, "assign_public_ip", false)
#   }
#
#   load_balancer {
#     target_group_arn = each.value.target_group_arn
#     container_name   = each.key
#     container_port   = each.value.port
#   }
#
#   deployment_minimum_healthy_percent = 50
#   deployment_maximum_percent         = 200
#
#   lifecycle {
#     # 외부 오토스케일러/배포툴과 충돌 방지
#     ignore_changes = [desired_count]
#   }
#
#   tags = merge(var.tags, {
#     Service = each.key
#   })
# }
