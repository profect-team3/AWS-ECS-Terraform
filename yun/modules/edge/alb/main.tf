resource "aws_security_group" "alb" {
  name        = "${var.name}-sg"
  description = "Allow only from VPC Link/NLB"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, {
    Name = "${var.name}-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_cidr" {
  for_each          = toset(var.allowed_cidrs)
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "tcp"
  from_port         = var.listener_port
  to_port           = var.listener_port
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "alb_sg" {
  for_each                     = toset(var.allowed_sg_ids)
  security_group_id            = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = var.listener_port
  to_port                      = var.listener_port
  referenced_security_group_id = each.value
}

resource "aws_vpc_security_group_egress_rule" "alb_all_out" {
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids
  tags               = var.tags
}

resource "aws_lb_target_group" "tg" {
  for_each = { for t in var.target_groups : t.name => t }

  name        = "${var.name}-${each.key}"
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = try(each.value.health_check.enabled, true)
    path                = try(each.value.health_check.path, "/health")
    healthy_threshold   = try(each.value.health_check.healthy_threshold, 2)
    unhealthy_threshold = try(each.value.health_check.unhealthy_threshold, 2)
    interval            = try(each.value.health_check.interval, 30)
    timeout             = try(each.value.health_check.timeout, 5)
    matcher             = try(each.value.health_check.matcher, "200-399")
  }

  tags = var.tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[keys(aws_lb_target_group.tg)[0]].arn
  }
}

resource "aws_lb_listener_rule" "paths" {
  for_each = { for t in var.target_groups : t.name => t if length(t.path_patterns) > 0 }

  listener_arn = aws_lb_listener.http.arn
  priority     = 100 + index(keys(aws_lb_target_group.tg), each.key)

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.path_patterns
    }
  }
}
