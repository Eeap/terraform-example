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
resource "aws_security_group_rule" "test_inbound" {
  type = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id
  from_port = 12345
  to_port = 12345
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}