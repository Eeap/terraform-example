provider "aws" {
  region = "us-east-2"
}
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster/services/webserver-cluster"
  db_remote_state_bucket = "terraform-example-s3-sumin"
  db_db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
  cluster_name = "webserver-stage"
  min_size = 2
  max_size = 2
  instance_type = "t2.micro"
}