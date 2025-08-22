# output "mongo_instance_id"      { value = aws_instance.db.id }
# output "mongo_private_ip"       { value = aws_instance.db.private_ip }

output "docdb_cluster_endpoint" {
  description = "The endpoint of the DocumentDB cluster"
  value       = aws_docdb_cluster.this.endpoint
}

output "docdb_cluster_reader_endpoint" {
  description = "The reader endpoint of the DocumentDB cluster"
  value       = aws_docdb_cluster.this.reader_endpoint
}

output "docdb_instance_ids" {
  description = "List of DocumentDB instance IDs"
  value       = [for instance in aws_docdb_cluster_instance.this : instance.id]
}
