# resource "aws_instance" "example" {
#   ami = "ami-0c55b159cbfafe1f0"
#   instance_type = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.example_sg.id]

#   user_data = <<-EOF
#                 #!/bin/bash
#                 echo "Hello, World!" > index.html
#                 nohup busybox httpd -f -p ${var.server_port} &
#                 EOF
#   tags = {
#     Name = "terraform-example"
#   }
# }

resource "aws_lb" "example" {
  name = "${var.cluster_name}-example"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.lb_example_sg.id]
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"
  
  default_action {
    type = "fixed-response"
    
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}
resource "aws_security_group" "lb_example_sg" {
  name = "${var.cluster_name}-alb"
}
resource "aws_security_group_rule" "http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.lb_example_sg.id
  cidr_blocks = local.all_ips
  from_port = local.http_port
  protocol = local.tcp_protocol
  to_port = local.http_port
}
resource "aws_security_group_rule" "all_outbound" {
  type = "engress"
  security_group_id = aws_security_group.lb_example_sg.id
  cidr_blocks = local.all_ips
  from_port = local.any_port
  protocol = local.any_protocol
  to_port = local.any_port
}
resource "aws_lb_target_group" "alb_tg" {
  name = "${var.cluster_name}-alb-tg"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb_listener_rule" "alb_listener" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_launch_configuration" "example" {
  image_id = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type

  security_groups = [aws_security_group.example_sg.id]

  user_data = data.template_file.user_data.rendered
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.alb_tg.arn]
  health_check_type = "ELB"
  min_size = var.min_size
  max_size = var.max_size

  tag {
    key = "Name"
    value = var.cluster_name
    propagate_at_launch = true
  }
}
resource "aws_security_group" "example_sg" {
  name = "${var.cluster_name}-instance"
}
resource "aws_security_group_rule" "tcp_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.example_sg
  cidr_blocks = local.all_ips
  from_port = var.server_port
  protocol = local.tcp_protocol
  to_port = var.server_port
  
}
data "aws_vpc" "default" {
  default = true

}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = var.db_remote_state_bucket
    key = var.db_remote_state_key
    region = "us-east-2"
   }
}
data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")

  vars = {
    server_port = var.server_port
    db_address = data.terraform_remote_state.db.outputs.address
    db_port = data.terraform_remote_state.db.outputs.port
  }
}
# 아래는 terraform에서 deprecate된다고 해서 추후에는 subnets 쓸것을 권장(https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids)
# data "aws_subnet_ids" "default" {
#   vpc_id = data.aws_vpc.default.id
# }

terraform {
  backend "s3" {
    bucket = "terraform-example-s3-sumin"
    key = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-example-dynamodb-sumin"
    encrypt = true
  }
}
locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}