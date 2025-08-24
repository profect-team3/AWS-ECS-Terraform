# 시크릿 이름 → ARN 조회
data "aws_secretsmanager_secret" "this" {
  for_each = var.secret_names
  name     = each.value
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
  task_role_arn      = var.ecs_task_role_arns
  # task_role_arn      = var.ecs_task_role_arns[each.key]

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

      # env
      environment = concat(
        [
          { name = "SPRING_PROFILES_ACTIVE", value = "prod" },
          { name = "TZ", value = "Asia/Seoul" }
        ],
        [for k, v in lookup(each.value, "env_map", {}) : { name = k, value = v }]
      )

      secrets = [
        for key_name in lookup(each.value, "secret_keys", []) : {
          name      = key_name
          valueFrom = data.aws_secretsmanager_secret.this[key_name].arn
        }
      ]
    }
  ])

  tags = merge(var.tags, {
    Service = each.key
  })
}
