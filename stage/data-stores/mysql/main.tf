provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-example-db"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  db_name = "exampleDb"
  username = "admin"
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.example.key_id
  skip_final_snapshot = true
}
resource "aws_kms_key" "example" {
  description = "mysql KMS Key"
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