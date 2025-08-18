data "aws_subnet" "first" {
  id = var.subnet_ids[0]
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  tags               = var.tags
}

resource "aws_lb_target_group" "alb" {
  name        = "${var.name}-tg"
  port        = var.listener_port
  protocol    = "TCP"    # L4 레벨로 ALB로 터널
  target_type = "alb"    # 핵심: ALB를 대상으로 지정
  vpc_id      = data.aws_subnet.first.vpc_id
}

resource "aws_lb_listener" "tcp" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}

resource "aws_lb_target_group_attachment" "attach_alb" {
  target_group_arn = aws_lb_target_group.alb.arn
  target_id        = var.alb_arn
  port             = var.listener_port
}
