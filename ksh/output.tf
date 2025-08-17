#VPC
output "vpc_id" {
  value = module.vpc.vpc_id
}

#Subnet
output "public_subnet_id" {
  value = module.public_subnet.subnet_id
}

output "private_subnet_id" {
  value = module.private_subnet.subnet_id
}

#IGW
output "igw_id" {
  value = module.igw.igw_id
}

#Route Table
output "public_route_table_id" {
  value = module.public_route_table.route_table_id
}

#NAT
output "private_route_table_id" {
  value = module.private_nat.private_route_table_id
}

output "nat_gateway_id" {
  value = module.private_nat.nat_gateway_id
}

#Security Group
output "sg_public_id" {
  value = module.sg.sg_public_id
}

output "sg_private_id" {
  value = module.sg.sg_private_id
}

#VPC Endpoint (S3)
output "vpc_endpoint_s3_id" {
  value = module.vpc_endpoint_s3.s3_vpc_endpoint_id
  description = "Private Subnet S3 - VPC Endpoint ID"
}

#IAM
output "iam_admin_group_id" {
  value = module.iam.admin_group_id
}

output "iam_users" {
  value = module.iam.iam_users
}

output "iam_roles" {
  value = module.iam.roles
}

output "iam_policies" {
  value = module.iam.policies
}