output "vpc_id"            { value = module.vpc.vpc_id }
output "public_subnet_ids" { value = module.subnets.public_subnet_ids }
output "private_subnet_ids"{ value = module.subnets.private_subnet_ids }
output "private_route_table_ids" { value = module.igw_nat.private_route_table_ids }
