provider "aws" {
    region = "us-east-2"
}

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
  name = "terraform-lb-example"
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
  name = "terraform-example-alb"

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }
  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
}
resource "aws_lb_target_group" "alb_tg" {
  name = "terraform-alb-tg"
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

output "alb_dns_name" {
  value=aws_lb.example.dns_name
  description = "alb dns name"
}

resource "aws_launch_configuration" "example" {
  image_id = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  security_groups = [aws_security_group.example_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.alb_tg.arn]
  health_check_type = "ELB"
  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}
resource "aws_security_group" "example_sg" {
    name = "terraform-example-instance"

    ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = var.server_port
      protocol = "tcp"
      to_port = var.server_port
    } 
  
}

variable "server_port" {
  description = "example variable"
  type = number
  default = 8080
}

# output "public_ip" {
#   value=aws_instance.example.public_ip
#   description = "ec2-public-ip"
# }

data "aws_vpc" "default" {
  default = true

}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 아래는 terraform에서 deprecate된다고 해서 추후에는 subnets 쓸것을 권장(https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids)
# data "aws_subnet_ids" "default" {
#   vpc_id = data.aws_vpc.default.id
# }
