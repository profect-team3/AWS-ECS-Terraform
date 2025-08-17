output "instance_id"      { value = aws_instance.db.id }
output "private_ip"       { value = aws_instance.db.private_ip }
output "security_group_id"{ value = aws_security_group.db.id }
