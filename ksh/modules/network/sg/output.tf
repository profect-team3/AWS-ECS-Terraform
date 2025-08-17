output "sg_public_id" {
  value = aws_security_group.public.id
}

output "sg_private_id" {
  value = aws_security_group.private.id
}
