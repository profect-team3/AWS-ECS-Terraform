output "alb_arn"          { value = aws_lb.this.arn }
output "alb_dns_name"     { value = aws_lb.this.dns_name }
output "listener_arn"     { value = aws_lb_listener.http.arn }
output "security_group_id"{ value = aws_security_group.alb.id }
output "target_group_arns"{ value = { for k,t in aws_lb_target_group.tg : k => t.arn } }
