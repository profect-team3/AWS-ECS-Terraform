output "nat_gateway_id" {
  description = "Created NAT Gateway ID"
  value = aws_nat_gateway.nat[*].id
}

output "private_route_table_id" {
  description = "Private Route Table ID"
  value = aws_route_table.private.id
}