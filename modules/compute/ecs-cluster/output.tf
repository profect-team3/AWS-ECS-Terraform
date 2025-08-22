output "cluster_arn" { value = aws_ecs_cluster.this.arn }
output "namespace" { value = aws_service_discovery_private_dns_namespace.svc.name }
