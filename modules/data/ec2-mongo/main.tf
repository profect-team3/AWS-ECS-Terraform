# # EC2
# locals {
#   mongo_names = ["mongoPrimary", "mongoSecondary"]
# }
#
# resource "aws_instance" "db" {
#   count                  = length(local.mongo_names)
#   ami                    = var.ami_id
#   instance_type          = var.instance_type
#   subnet_id              = var.subnet_id
#   vpc_security_group_ids = [var.sg_mongo_id]
#   key_name               = var.key_name
#   associate_public_ip_address = false
#
#   root_block_device {
#     volume_size = var.volume_size
#     volume_type = var.volume_type
#     iops        = var.volume_iops
#   }
#
#   user_data = <<-EOF
#     #!/bin/bash
#     set -e
#     sudo apt update
#     sudo apt install -y gnupg wget lsb-release
#     wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb.gpg
#     DISTRO=$(lsb_release -cs)
#     echo "deb [ arch=amd64,arm64 signed-by=/etc/apt/trusted.gpg.d/mongodb.gpg ] https://repo.mongodb.org/apt/ubuntu $DISTRO/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
#     sudo apt update
#     sudo apt install -y mongodb-org
#     sudo systemctl start mongod
#     sudo systemctl enable mongod
#     sudo ufw allow 27017/tcp || true
#     EOF
#
#   tags = merge(var.tags, {
#     Name = local.mongo_names[count.index]
#   })
# }
#
#
# resource "aws_instance" "Arbiterdb" {
#   ami                    = var.ami_id
#   instance_type          = var.instance_type
#   subnet_id              = var.subnet_id
#   vpc_security_group_ids = [var.sg_mongo_id]
#   key_name               = var.key_name
#   associate_public_ip_address = false
#
#   root_block_device {
#     volume_size = var.volume_size
#     volume_type = var.volume_type
#     iops        = var.volume_iops
#   }
#
#   user_data = <<-EOF
#     #!/bin/bash
#     set -e
#     sudo apt update
#     sudo apt install -y gnupg wget lsb-release
#     wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb.gpg
#     DISTRO=$(lsb_release -cs)
#     echo "deb [ arch=amd64,arm64 signed-by=/etc/apt/trusted.gpg.d/mongodb.gpg ] https://repo.mongodb.org/apt/ubuntu $DISTRO/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
#     sudo apt update
#     sudo apt install -y mongodb-org
#     sudo systemctl start mongod
#     sudo systemctl enable mongod
#     sudo ufw allow 27017/tcp || true
#
#     MY_IP=$(ip a | grep inet | grep 10 | cut -d/ -f1)
#     rs.initiate({
#     id: "mongoReplicaSet",
#     members: [
#     { id: 0, host: "$MY_IP:27017" },   // Primary
#     { _id: 1, host: "${aws_instance.db[0].private_ip}:27017" },
#     { _id: 2, host: "${aws_instance.db[1].private_ip}:27017", arbiterOnly: true }
#     ]
#     });
#     EOF
#
#   tags = merge(var.tags, {
#     Name = "mongoArbiter"  # mongoPrimary로
#   })
# }

# DocumentDB Subnet Group
resource "aws_docdb_subnet_group" "this" {
  name       = "${var.name}-docdb-subnets"
  subnet_ids = var.subnet_ids
}

# DocumentDB Cluster
resource "aws_docdb_cluster" "this" {
  cluster_identifier      = "${var.name}-docdb"
  engine                  = "docdb"
  engine_version          = "5.0.0"
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  vpc_security_group_ids  = [var.sg_mongo_id]
  db_subnet_group_name    = aws_docdb_subnet_group.this.name
  apply_immediately       = true
  tags                    = var.tags
}

# DocumentDB Cluster Instances
resource "aws_docdb_cluster_instance" "this" {
  count              = 3
  identifier         = "${var.name}-docdb-${count.index}"
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = "db.t3.medium"
  engine             = aws_docdb_cluster.this.engine
  apply_immediately  = true
  tags               = var.tags
}
