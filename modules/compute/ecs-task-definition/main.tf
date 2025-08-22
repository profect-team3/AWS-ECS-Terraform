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
      image     = each.value.image
      essential = true
      portMappings = [
        {
          containerPort = each.value.port
          hostPort      = each.value.port
          protocol      = "tcp"
          name          = each.key
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
      # environment = [
      #     name  = each.value.
      #     value = v
      #   }
      # ]
    }
  ])

  tags = merge(var.tags, {
    Service = each.key
  })
}
