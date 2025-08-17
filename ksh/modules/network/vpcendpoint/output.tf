output "s3_vpc_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
  description = "VPC Endpoint - S3"
}