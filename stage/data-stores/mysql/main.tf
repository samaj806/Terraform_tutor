provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "example" {
  identifier_prefix         = "terraform-up-and-running"
  engine                    = "mysql"
#   engine_version            = "8.0.35"
  allocated_storage         = 10
  instance_class            = "db.t3.micro"
  skip_final_snapshot       = true
  db_name                   = "example_database"

  username                  = var.db_username
  password                  = var.db_password
}

# terraform {
#     backend "s3" {
#         bucket              = "ajsammy-bucket"
#         key                 = "stage/data-stores/mysql/terraform.tfstate"
#         region              = "us-east-1"

#         dynamodb_table      = "terraform_db-locks"
#         encrypt             = true
#     }
# }