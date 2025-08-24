# mongo
resource "aws_security_group" "mongo_db" {
  name        = "${var.name}-mongo-sg"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, {
    Name = "${var.name}-mongo-sg"
  })
}

# postgres
resource "aws_security_group" "postgres_db" {
  name        = "${var.name}-postgres-sg"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, {
    Name = "${var.name}-postgres-sg"
  })
}

# redis
resource "aws_security_group" "redis" {
  name        = "${var.name}-redis-sg"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, {
    Name = "${var.name}-redis-sg"
  })
}

# ecs
resource "aws_security_group" "svc" {
  for_each    = var.service_definitions
  name        = "${var.name}-${each.key}-sg"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, {
    Service = each.key
  })
}

# alb
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, {
    Name = "${var.name}-alb-sg"
  })
}

# VPC Endpoint
resource "aws_security_group" "vpc_endpoint_sg" {
  name   = "${var.name}-vpce-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [for k, _ in var.service_definitions : aws_security_group.svc[k].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# mongo
resource "aws_vpc_security_group_ingress_rule" "mongo_ecs" {
  for_each                     = var.service_definitions
  security_group_id            = aws_security_group.mongo_db.id
  ip_protocol                  = "tcp"
  from_port                    = 27017
  to_port                      = 27017
  referenced_security_group_id = aws_security_group.svc[each.key].id
}

resource "aws_vpc_security_group_egress_rule" "mongo_all_out" {
  security_group_id = aws_security_group.mongo_db.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# postgres
resource "aws_vpc_security_group_ingress_rule" "postgres_ecs" {
  for_each                     = var.service_definitions
  security_group_id            = aws_security_group.postgres_db.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.svc[each.key].id
}

resource "aws_vpc_security_group_egress_rule" "postgres_all_out" {
  security_group_id = aws_security_group.postgres_db.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# redis
resource "aws_vpc_security_group_ingress_rule" "redis_ecs" {
  for_each                     = var.service_definitions
  security_group_id            = aws_security_group.redis.id
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
  referenced_security_group_id = aws_security_group.svc[each.key].id
}

resource "aws_vpc_security_group_egress_rule" "redis_all_out" {
  security_group_id = aws_security_group.redis.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ecs
locals {
  # 각 서비스에서 postgres로 나가야 하는 경우만 추려, 포트값을 뽑아 맵 구성
  svc_to_postgres = {
    for svc, conf in var.service_definitions :
    svc => [for e in conf.egress : e.port if e.to == "postgres"][0]
    if length([for e in conf.egress : e if e.to == "postgres"]) > 0
  }

  svc_to_mongo = {
    for svc, conf in var.service_definitions :
    svc => [for e in conf.egress : e.port if e.to == "mongo"][0]
    if length([for e in conf.egress : e if e.to == "mongo"]) > 0
  }

  svc_to_redis = {
    for svc, conf in var.service_definitions :
    svc => [for e in conf.egress : e.port if e.to == "redis"][0]
    if length([for e in conf.egress : e if e.to == "redis"]) > 0
  }
}

# ECS -> Postgres
resource "aws_vpc_security_group_egress_rule" "ecs_to_postgres" {
  for_each                      = local.svc_to_postgres
  security_group_id             = aws_security_group.svc[each.key].id
  ip_protocol                   = "tcp"
  from_port                     = each.value
  to_port                       = each.value
  referenced_security_group_id  = aws_security_group.postgres_db.id
}

# ECS -> Mongo
resource "aws_vpc_security_group_egress_rule" "ecs_to_mongo" {
  for_each                      = local.svc_to_mongo
  security_group_id             = aws_security_group.svc[each.key].id
  ip_protocol                   = "tcp"
  from_port                     = each.value
  to_port                       = each.value
  referenced_security_group_id  = aws_security_group.mongo_db.id
}

# ECS -> Redis
resource "aws_vpc_security_group_egress_rule" "ecs_to_redis" {
  for_each                      = local.svc_to_redis
  security_group_id             = aws_security_group.svc[each.key].id
  ip_protocol                   = "tcp"
  from_port                     = each.value
  to_port                       = each.value
  referenced_security_group_id  = aws_security_group.redis.id
}

# ALB -> ECS 인바운드
resource "aws_security_group_rule" "alb_ecs_ingress" {
  for_each                 = var.service_definitions
  type                     = "ingress"
  security_group_id        = aws_security_group.svc[each.key].id
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

# ECS -> VPCE (ECR/Logs/Secrets/KMS) 443
resource "aws_vpc_security_group_egress_rule" "ecs_to_vpc_endpoint_https" {
  for_each                     = var.service_definitions
  security_group_id            = aws_security_group.svc[each.key].id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  cidr_ipv4   = "10.0.0.0/0"
  # referenced_security_group_id = aws_security_group.vpc_endpoint_sg.id
}

# resource "aws_security_group_rule" "ecs_egress" {
#   for_each                      = var.service_definitions
#   type                          = "egress"
#   security_group_id             = aws_security_group.svc[each.key].id
#   from_port                     = each.value.egress.port
#   to_port                       = each.value.egress.port
#   protocol                      = each.value.egress.proto
#   destination_security_group_id = local.core_sg_ids[each.value.egress.to]
# }

# alb
resource "aws_vpc_security_group_ingress_rule" "alb_ingress_80_cidr" {
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}


# 인바운드: 443 (CIDR)
# resource "aws_security_group_rule" "alb_ingress_443_cidr" {
#   for_each          = toset(var.allowed_cidrs)
#   type              = "ingress"
#   security_group_id = aws_security_group.alb.id
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = [each.key]
# }

resource "aws_security_group_rule" "alb_egress_all" {
  for_each                     = var.service_definitions
  type                         = "egress"
  security_group_id            = aws_security_group.alb.id
  from_port                    = each.value.port
  to_port                      = each.value.port
  protocol                     = "tcp"
  source_security_group_id     = aws_security_group.svc[each.key].id
}
