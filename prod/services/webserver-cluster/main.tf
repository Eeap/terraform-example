provider "aws" {
  region = "us-east-2"
}
module "webserver_cluster" {
  # source = "../../../modules/services/webserver-cluster/services/webserver-cluster"
  source = "github.com/brikis98/terraform-up-and-running-code//code/terraform/04-terraform-module/module-example/modules/services/webserver-cluster?ref=v0.1.0"
  db_remote_state_bucket = "terraform-example-s3-sumin"
  db_db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"
  cluster_name = "webserver-prod"
  min_size = 2
  max_size = 10
  instance_type = "m4.large"
}
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"
  autoscaling_group_name = module.webserver_cluster.asg_name
}
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"
  autoscaling_group_name = module.webserver_cluster.asg_name
}