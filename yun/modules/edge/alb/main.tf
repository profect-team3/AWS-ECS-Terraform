resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, {
    Name = "${var.name}-alb-sg"
  })
}
# 인바운드: 80 (CIDR)
resource "aws_security_group_rule" "ingress_80_cidr" {
  for_each          = toset(var.allowed_cidrs)
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [each.key]
  description       = "HTTP from CIDR"
}

# 인바운드: 443 (CIDR)
# resource "aws_security_group_rule" "ingress_443_cidr" {
#   for_each          = toset(var.allowed_cidrs)
#   type              = "ingress"
#   security_group_id = aws_security_group.alb.id
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = [each.key]
#   description       = "HTTPS from CIDR"
# }

# 인바운드: 80 (SG)
resource "aws_security_group_rule" "ingress_80_sg" {
  for_each                 = toset(var.allowed_sg_ids)
  type                     = "ingress"
  security_group_id        = aws_security_group.alb.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = each.key
  description              = "HTTP from SG"
}

# 인바운드: 443 (SG)
# resource "aws_security_group_rule" "ingress_443_sg" {
#   for_each                 = toset(var.allowed_sg_ids)
#   type                     = "ingress"
#   security_group_id        = aws_security_group.alb.id
#   from_port                = 443
#   to_port                  = 443
#   protocol                 = "tcp"
#   source_security_group_id = each.key
#   description              = "HTTPS from SG"
# }

# 아웃바운드 전체 허용(타겟으로의 연결 허용)
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all egress"
}

resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids
  tags               = var.tags
}

# 서비스별 Target Group (ECS에서 나중에 attach)
resource "aws_lb_target_group" "svc" {
  for_each    = var.services

  name        = substr("${var.name}-${each.key}-tg", 0, 32)
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    path                = var.health_check_path
    matcher             = "200-399"
  }

  tags = merge(var.tags, {
    Service = each.key
  })
}

# HTTP(80) 리스너: 기본은 404, 규칙으로 경로 라우팅
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# HTTPS(443) 리스너: 인증서 제공 시에만 생성
# resource "aws_lb_listener" "https" {
#   count             = var.alb_certificate_arn != null ? 1 : 0
#   load_balancer_arn = aws_lb.this.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.alb_certificate_arn
#
#   default_action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "Not Found"
#       status_code  = "404"
#     }
#   }
# }

# 경로 기반 라우팅 규칙 (HTTP 80)
resource "aws_lb_listener_rule" "http_paths" {
  for_each     = var.services

  listener_arn = aws_lb_listener.http.arn
  priority     = 100 + index(keys(var.services), each.key)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.svc[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.paths
    }
  }
}

# HTTPS(443) 경로 라우팅 규칙 (인증서 있을 때만)
# resource "aws_lb_listener_rule" "https_paths" {
#   for_each     = var.alb_certificate_arn != null ? var.services : {}
#   listener_arn = aws_lb_listener.https[0].arn
#   priority     = 200 + index(local.service_keys, each.key)
#
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.svc[each.key].arn
#   }
#
#   condition {
#     path_pattern { values = each.value.paths }
#   }
# }