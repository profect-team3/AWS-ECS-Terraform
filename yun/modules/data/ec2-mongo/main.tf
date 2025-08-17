# SG
resource "aws_security_group" "db" {
  name        = "${var.name}-mongo-sg"
  description = "mongoDB SG"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, {
    Name = "${var.name}-mongo-sg"
  })
}

# SSH
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each          = toset(var.ssh_allowed_cidrs)
  security_group_id = aws_security_group.db.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.db.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# EC2
resource "aws_instance" "db" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.db.id]
  key_name               = var.key_name
  associate_public_ip_address = false

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
    iops        = var.volume_iops
  }

  user_data = <<-EOF
    #!/bin/bash
    #
  EOF

  tags = merge(var.tags, {
    Name = "${var.name}-mongo"
  })
}