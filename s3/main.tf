provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "example" {
  bucket = "terraform-example-s3-sumin"
  force_destroy = true
  # 삭제 방지
  lifecycle {
    prevent_destroy = false
  }
  # deprecated 된 내용들 (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
#   versioning {
#     enabled = true
#   }
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }
}
resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_dynamodb_table" "example" {
  name = "terraform-example-dynamodb-sumin"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
terraform {
  backend "s3" {
    bucket = "terraform-example-s3-sumin"
    key = "global/s3/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-example-dynamodb-sumin"
    encrypt = true
  }
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.example.arn
  description = "The ARN of the S3 bucket"
}
output "dynamodb_table_name" {
  value = aws_dynamodb_table.example.name
  description = "The name of the DynamoDB table"
}