resource "aws_subnet" "this" {
  for_each                = { for idx, cidr in var.cidr : tostring(idx) => cidr }
  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  availability_zone       = var.azs[each.key]
  map_public_ip_on_launch = var.public

  tags = merge(
    var.tags,
    { Name = "${var.tags["Project"]}-${var.tags["Env"]}-subnet-${each.key}" }
  )
}