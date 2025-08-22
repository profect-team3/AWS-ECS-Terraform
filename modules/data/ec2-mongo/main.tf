# EC2
locals {
  mongo_names = ["mongoPrimary", "mongoSecondary", "mongoArbiter"]
}

resource "aws_instance" "db" {
  count                  = length(local.mongo_names)
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_mongo_id]
  key_name               = var.key_name
  associate_public_ip_address = false

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
    iops        = var.volume_iops
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e
    sudo apt update
    sudo apt install -y gnupg wget lsb-release
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | \
    sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb.gpg
    echo "deb [ arch=amd64,arm64 signed-by=/etc/apt/trusted.gpg.d/mongodb.gpg ] https://repo.mongodb.org/apt/ubuntu \$(lsb_release -cs)/mongodb-org/6.0 multiverse" | \
    sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    sudo apt update
    sudo apt install -y mongodb-org
    sudo systemctl start mongod
    sudo systemctl enable mongod
    sudo ufw allow 27017/tcp || true
    EOF

  tags = merge(var.tags, {
    Name = local.mongo_names[count.index]
  })
}
