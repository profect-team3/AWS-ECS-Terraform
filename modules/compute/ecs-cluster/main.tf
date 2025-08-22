resource "aws_service_discovery_private_dns_namespace" "svc" {
  name = var.namespace
  vpc  = var.vpc_id
  tags = var.tags
}

resource "aws_ecs_cluster" "this" {
  name = "${var.name}-ecs-cluster"

  # cloudwatch 모니터링
  # setting {
  #   name  = "containerInsights"
  #   value = "enabled"
  # }

  service_connect_defaults {
    namespace = aws_service_discovery_private_dns_namespace.svc.arn
  }

  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 0
  }
}