output "alb_dns_name" {
  value       = aws_lb.load-balancer.dns_name
  description = "The public IP address of the web server"
}