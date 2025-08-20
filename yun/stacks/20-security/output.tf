output "sg_alb_id" {
  description = "ALB Security Group ID"
  value       = module.security.sg_alb_id
}

output "sg_mongo_id" {
  description = "MongoDB Security Group ID"
  value       = module.security.sg_mongo_id
}

output "sg_postgres_id" {
  description = "Postgres Security Group ID"
  value       = module.security.sg_postgres_id
}

output "sg_redis_id" {
  description = "Redis Security Group ID"
  value       = module.security.sg_redis_id
}

output "sg_ecs_service_ids" {
  description = "Per-service ECS SG IDs"
  value       = module.security.sg_ecs_service_ids
}
