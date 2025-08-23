output "mongodb_instance_id"      { value = aws_instance.mongo_client.id }
output "mongodb_private_ip"       { value = aws_instance.mongo_client.private_ip }
