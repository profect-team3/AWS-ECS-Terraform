# EC2
resource "aws_instance" "db" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_redis_id]
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
    Name = "${var.name}-redis"
  })
}