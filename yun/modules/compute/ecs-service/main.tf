data "aws_region" "current" {}

# Log Group
resource "aws_cloudwatch_log_group" "log" {
  count             = length(var.services)
  name              = "/ecs/${var.name}-${var.services[count.index].name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# IAM Roles (Execution + Task)
data "aws_iam_policy_document" "task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "exec" {
  count              = length(var.services)
  name               = "${var.name}-${var.services[count.index].name}-exec"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
  tags               = var.tags
}

resource "aws_iam_role" "task" {
  count              = length(var.services)
  name               = "${var.name}-${var.services[count.index].name}-task"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "exec_managed" {
  count      = length(var.services)
  role       = aws_iam_role.exec[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
#
# # 최소 권한: SecretsManager에서 지정된 ARN 읽기
# data "aws_iam_policy_document" "task_inline" {
#   for_each = local.svc_map
#
#   dynamic "statement" {
#     for_each = length(each.value.secrets) > 0 ? [1] : []
#     content {
#       actions   = ["secretsmanager:GetSecretValue"]
#       resources = [for s in each.value.secrets : s.arn]
#       effect    = "Allow"
#     }
#   }
# }
#
# resource "aws_iam_policy" "task_inline" {
#   for_each = local.svc_map
#   name     = "${var.name}-${each.key}-task-inline"
#   policy   = data.aws_iam_policy_document.task_inline[each.key].json
# }
#
# resource "aws_iam_role_policy_attachment" "task_inline_attach" {
#   for_each   = local.svc_map
#   role       = aws_iam_role.task[each.key].name
#   policy_arn = aws_iam_policy.task_inline[each.key].arn
# }

# Task Definition
resource "aws_ecs_task_definition" "this" {
  count                  = length(var.services)
  family                 = "${var.name}-${var.services[count.index].name}"
  network_mode           = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                    = tostring(var.services[count.index].cpu)
  memory                 = tostring(var.services[count.index].memory)
  execution_role_arn     = aws_iam_role.exec[count.index].arn
  task_role_arn          = aws_iam_role.task[count.index].arn

  container_definitions = jsonencode([
    {
      name      = var.services[count.index].name
      image     = var.services[count.index].image
      essential = true

      portMappings = [{
        containerPort = var.services[count.index].container_port
        hostPort      = var.services[count.index].container_port
        protocol      = "tcp"
      }]

      environment = [
        for k, v in var.services[count.index].env_vars : {
          name  = k
          value = v
        }
      ]

      secrets = [
        for s in var.services[count.index].secrets : {
          name      = s.name
          valueFrom = s.arn
        }
      ]

      # logConfiguration = {
      #   logDriver = "awslogs"
      #   options = {
      #     awslogs-group         = aws_cloudwatch_log_group.svc[each.key].name
      #     awslogs-region        = data.aws_region.current.name
      #     awslogs-stream-prefix = "ecs"
      #   }
      # }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = var.tags
}


# ECS Service
resource "aws_ecs_service" "this" {
  count                = length(var.services)
  name                 = "${var.name}-${var.services[count.index].name}"
  cluster              = var.cluster_id
  task_definition      = aws_ecs_task_definition.this[count.index].arn
  desired_count        = var.services[count.index].desired_count
  launch_type          = "FARGATE"
  enable_execute_command = var.enable_execute_command

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = var.security_group_ids
    assign_public_ip = false
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.log,
    aws_iam_role.exec,
    aws_iam_role.task,
  ]
}

# Application Auto Scaling (DesiredCount)
# resource "aws_appautoscaling_target" "svc" {
#   for_each           = local.svc_map
#   max_capacity       = each.value.autoscaling.max
#   min_capacity       = each.value.autoscaling.min
#   resource_id        = "service/${split("/", var.cluster_id)[length(split("/", var.cluster_id)) - 1]}/${aws_ecs_service.this[each.key].name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"
# }

# resource "aws_appautoscaling_policy" "cpu" {
#   for_each           = local.svc_map
#   name               = "${var.name}-${each.key}-cpu-scaling"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.svc[each.key].resource_id
#   scalable_dimension = aws_appautoscaling_target.svc[each.key].scalable_dimension
#   service_namespace  = aws_appautoscaling_target.svc[each.key].service_namespace
#
#   target_tracking_scaling_policy_configuration {
#     target_value       = each.value.autoscaling.target_cpu
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageCPUUtilization"
#     }
#     scale_in_cooldown  = 60
#     scale_out_cooldown = 60
#   }
# }
