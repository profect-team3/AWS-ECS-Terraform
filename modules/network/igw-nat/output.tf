output "private_route_table_ids" {
  value       = [for rt in aws_route_table.private : rt.id]
}