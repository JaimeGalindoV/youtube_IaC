output "alb_dns_name" {
  description = "DNS publico del ALB backend"
  value       = aws_lb.backend_alb.dns_name
}

output "alb_arn" {
  description = "ARN del ALB backend"
  value       = aws_lb.backend_alb.arn
}

output "target_group_arn" {
  description = "ARN del target group del backend"
  value       = aws_lb_target_group.backend_tg.arn
}

output "asg_name" {
  description = "Nombre del Auto Scaling Group del backend"
  value       = aws_autoscaling_group.backend_asg.name
}
