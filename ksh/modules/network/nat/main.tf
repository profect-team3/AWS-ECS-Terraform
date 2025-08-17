resource "aws_nat_gateway" "nat" {
  count = length(var.availability_zones)
  subnet_id = var.private_subnet_id[count.index]
  tags = merge(var.common_tags, {Name = "${var.project_name}-nat-${count.index + 1}"})
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-nat-${count.index + 1}"
  })
}

resource "aws_route_table_association" "private_subnet" {
  count = length(var.private_subnet_id)
  subnet_id = var.private_subnet_id[count.index]
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "private_internet_access" {
  count = length(var.private_subnet_id)
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat[count.index].id
}