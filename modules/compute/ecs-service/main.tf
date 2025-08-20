# locals {
#   svc_keys = sort(keys(var.service_definitions))
# }
#
# # -------- CloudWatch Log Group (per service) --------
# resource "aws_cloudwatch_log_group" "svc" {
#   for_each          = var.service_definitions
#   name              = "/ecs/${var.name}-${each.key}"
#   retention_in_days = lookup(each.value, "log_retention_days", 14)
#   tags              = merge(var.tags, { Service = each.key })
# }
#
# # -------- Task Definitions (per service) --------
# resource "aws_ecs_task_definition" "svc" {
#   for_each                 = var.service_definitions
#   family                   = "${var.name}-${each.key}"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = each.value.cpu
#   memory                   = each.value.memory
#
#   # IAM은 외부 모듈 주입
#   execution_role_arn       = each.value.exec_role_arn
#   task_role_arn            = each.value.task_role_arn
#
#   runtime_platform { operating_system_family = "LINUX" }
#
#   container_definitions = jsonencode([
#     {
#       name      = each.key
#       image     = each.value.image
#       essential = true
#       portMappings = [
#         { containerPort = each.value.port, hostPort = each.value.port, protocol = "tcp" }
#       ]
#       environment = [ for k, v in lookup(each.value, "env", {}) : { name = k, value = v } ]
#       secrets     = [ for s in lookup(each.value, "secrets", []) : { name = s.name, valueFrom = s.valueFrom } ]
#       logConfiguration = {
#         logDriver = "awslogs",
#         options = {
#           awslogs-group         = aws_cloudwatch_log_group.svc[each.key].name
#           awslogs-region        = var.region
#           awslogs-stream-prefix = each.key
#         }
#       }
#     }
#   ])
#
#   # 필수 입력 검증
#   lifecycle {
#     precondition {
#       condition     = length(trimspace(each.value.exec_role_arn)) > 0 && length(trimspace(each.value.task_role_arn)) > 0
#       error_message = "Service '${each.key}': exec_role_arn/task_role_arn 은 필수입니다(외부 IAM 모듈에서 전달)."
#     }
#   }
#
#   tags = merge(var.tags, { Service = each.key })
# }
#
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
