# igw
resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id
  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}

# 퍼블릭 RT + IGW
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  tags = merge(var.tags, {
    Name = "${var.name}-rt-public"
  })
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_ids)
  route_table_id = aws_route_table.public.id
  subnet_id      = var.public_subnet_ids[count.index]
}

# NAT: 기본 1개 (첫 번째 퍼블릭 서브넷)
resource "aws_eip" "nat" {
  count = var.multi_nat ? length(var.public_subnet_ids) : 1
  domain = "vpc"
  tags = merge(var.tags, {
    Name = "${var.name}-eip-nat-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "this" {
  count         = var.multi_nat ? length(var.public_subnet_ids) : 1
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.public_subnet_ids[count.index]
  tags = merge(var.tags, {
    Name = "${var.name}-nat-${count.index + 1}"
  })
  depends_on    = [aws_internet_gateway.this]
}

# 프라이빗 RT + NAT
resource "aws_route_table" "private" {
  count = var.multi_nat ? length(var.private_subnet_ids) : 1
  vpc_id = var.vpc_id
  tags = merge(var.tags, {
    Name = "${var.name}-rt-private-${count.index}"
  })
}

resource "aws_route" "private_nat" {
  count = var.multi_nat ? length(var.private_subnet_ids) : 1
  route_table_id          = aws_route_table.private[count.index].id
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = aws_nat_gateway.this[ var.multi_nat ? count.index : 0 ].id
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnet_ids)
  route_table_id = aws_route_table.private[ var.multi_nat ? count.index : 0 ].id
  subnet_id      = var.private_subnet_ids[count.index]
}



