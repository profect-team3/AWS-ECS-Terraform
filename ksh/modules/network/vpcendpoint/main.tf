resource "aws_vpc_endpoint" "s3" {
  vpc_id = var.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = var.private_route_table_ids
  vpc_endpoint_type = "Gateway"

  tags = merge(var.common_tags, {Name = "${var.project_name}-s3-endpoint"})
}