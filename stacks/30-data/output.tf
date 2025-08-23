# # PostgreSQL
# output "postgres_private_ips" {
#   value = { for k, v in module.postgres : k => v.private_ips }
# }
# output "postgres_instance_id" {
#   value = { for k, v in module.postgres : k => v.instance_ids }
# }
#
#
# # Redis
# output "redis_private_ips" {
#   value = { for k, v in module.redis : k => v.private_ips }
# }
# output "redis_instance_id" {
#   value = { for k, v in module.redis : k => v.instance_ids }
# }
#
# # MongoDB
# output "mongo_private_ips" {
#   value = { for k, v in module.mongo : k => v.private_ips }
# }
# output "mongo_instance_id" {
#   value = { for k, v in module.mongo : k => v.instance_ids }
# }
#
# # DocDB
# output "docdb_cluster_id" {
#   value = module.docdb.docdb_cluster_id
# }
#
# output "docdb_instance_ids" {
#   value = module.docdb.docdb_instance_ids
# }
