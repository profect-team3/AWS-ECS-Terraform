# ecs service
resource "aws_ecs_service" "svc" {
  for_each                = var.service_definitions
  name                    = "${var.name}-${each.key}"
  cluster                 = var.cluster_arn
  task_definition         = var.task_definition_arns[each.key]

  desired_count          = each.value.desired_count
  enable_execute_command = each.value.enable_execute_command

  # 배포/안정화 관련 권장 옵션
  # wait_for_steady_state  = coalesce(try(each.value.wait_for_steady_state, null), false)
  # force_new_deployment   = coalesce(try(each.value.force_new_deployment, null), false)

  launch_type = "FARGATE"

  # ALB 헬스체크 유예(앱 초기화 여유)
  # health_check_grace_period_seconds = coalesce(try(each.value.health_check_grace_period_seconds, null), 60)

  # 롤링 업데이트 파라미터
  # deployment_minimum_healthy_percent = coalesce(try(each.value.min_healthy_percent, null), 50)
  # deployment_maximum_percent         = coalesce(try(each.value.max_percent, null), 200)

  # 배포 실패 시 자동 롤백 권장
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }


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

  # Service Connect 연결
  service_connect_configuration {
    enabled = true
    service {
      port_name      = each.key
      discovery_name = each.key
      client_alias {
        dns_name = each.key
        port     = each.value.port
      }
    }
  }

  tags = merge(var.tags, {
    Service = each.key
  })
}
