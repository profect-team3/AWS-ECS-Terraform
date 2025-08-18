# 퍼블릭 서브넷
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnets : idx => { cidr = cidr, az = var.azs[idx] } }
  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "${var.name}-subnet-public-${each.key + 1}"
  })
}

# 프라이빗 서브넷
resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnets : idx => { cidr = cidr, az = var.azs[idx] } }
  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = merge(var.tags, {
    Name = "${var.name}-subnet-private-${each.key + 1}"
  })
}
