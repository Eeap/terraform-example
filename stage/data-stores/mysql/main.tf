provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-example-db"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  name = "example-db"
  username = "admin"
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "mysql-master-password-stage"
}

terraform {
  backend "s3" {
    bucket = "terraform-example-s3-sumin"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-example-dynamodb-sumin"
    encrypt = true
  }
}