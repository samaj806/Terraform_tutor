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

output "public_ip" {
  value       = aws_instance.test_server.public_ip
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
