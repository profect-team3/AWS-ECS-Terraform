output "redis_instance_ids"      { value = aws_instance.db.id }
output "redis_private_ips"       { value = aws_instance.db.private_ip }
