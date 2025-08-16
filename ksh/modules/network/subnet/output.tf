output "subnet_id" {
  description = "Created Subnets ID"
  value       = [for subnet in aws_subnet.this : subnet.id]
}