output "public_subnet_ids" { value = values(aws_subnet.public)[*].id }
output "private_subnet_ids"{ value = values(aws_subnet.private)[*].id }
# output "public_subnet_azs" { value = values(aws_subnet.public)[*].availability_zone }
