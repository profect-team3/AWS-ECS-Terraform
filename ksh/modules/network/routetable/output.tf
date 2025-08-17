output "route_table_id" {
  description = "Created public route table ID"
  value = aws_route_table.public.id
}

output "route_table_association_id" {
  description = "Route Table Association ID"
  value = aws_route_table_association.public_subnet.id
}