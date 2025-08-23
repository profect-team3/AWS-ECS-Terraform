output "mongo_instance_ids"      { value = aws_instance.mongo_client.id }
output "mongo_private_ips"       { value = aws_instance.mongo_client.private_ip }
