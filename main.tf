provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_template" "test_server" {
  image_id      = "ami-020cba7c55df1f615"
  key_name      = "logkey"
  instance_type = "t2.micro"

  network_interfaces {
    security_groups             = [aws_security_group.internet.id]
    associate_public_ip_address = true
  }

  user_data = base64encode(<<-EOF
                #!/bin/bash
                sudo apt-get update -y
                sudo apt install -y busybox

                      mkdir -p /var/www
                      echo "Hello,World this is the first step we moving forward" > /var/www/index.html
                      nohup busybox httpd -f -p ${var.server_port} -h /var/www &
                      EOF
  )



  tags = {
    Name = "test-server"
  }
}

resource "aws_security_group" "internet" {
  name = "internet-connection"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "The port the srver will use for HTTP requests."
  type        = number
  default     = 8080
}

output "alb_dns_name" {
  value       = aws_lb.load-balancer.dns_name
  description = "The public IP address of the web server"
}


resource "aws_autoscaling_group" "server_increase" {
  min_size            = 3
  max_size            = 10
  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.test_server.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "terraform-test-server"
    propagate_at_launch = true
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


resource "aws_lb" "load-balancer" {
  name               = "terraform-load-balancer"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load-balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404:page not found"
      status_code  = 404
    }
  }

}

resource "aws_security_group" "alb" {
  name = "alb-security-group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}
