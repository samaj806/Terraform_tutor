provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "test_server" {
  ami           = "ami-020cba7c55df1f615"
  key_name      = "logkey"
  instance_type = "t2.micro"

  tags = {
    Name = "test-server"
  }
}
