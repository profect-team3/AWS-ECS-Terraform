output "redis_instance_id"      { value = aws_instance.db.id }
output "redis_private_ip"       { value = aws_instance.db.private_ip }
