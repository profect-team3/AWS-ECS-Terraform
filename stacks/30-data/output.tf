# # PostgreSQL
# output "postgres_private_ips" {
#   value = { for k, v in module.postgres : k => v.private_ip }
# }
# output "postgres_sg_ids" {
#   value = { for k, v in module.postgres : k => v.security_group_id }
# }
#
# # Redis
# output "redis_private_ips" {
#   value = { for k, v in module.redis : k => v.private_ip }
# }
# output "redis_sg_ids" {
#   value = { for k, v in module.redis : k => v.security_group_id }
# }
#
# # MongoDB
# output "mongo_private_ips" {
#   value = { for k, v in module.mongo : k => v.private_ip }
# }
# output "mongo_sg_ids" {
#   value = { for k, v in module.mongo : k => v.security_group_id }
# }