provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "test_server" {
  ami                    = "ami-020cba7c55df1f615"
  key_name               = "logkey"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.internet.id]

  user_data = base64encode(<<-EOF
                #!/bin/bash
                sudo apt-get update -y
                sudo apt install -y busybox

                      mkdir -p /var/www
                      echo "Hello,World this is the first step we moving forward" > /var/www/index.html
                      nohup busybox httpd -f -p 8080 -h /var/www &
                      EOF
  )

  user_data_replace_on_change = true

  tags = {
    Name = "test-server"
  }
}

resource "aws_security_group" "internet" {
  name = "internet-connection"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

