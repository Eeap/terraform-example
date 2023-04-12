provider "aws" {
    region = "us-west-2"
}

resource "aws_instance" "example" {
  ami = "ami-830c94e3"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.example_sg.id]

  user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World!" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF
  tags = {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "example_sg" {
    name = "terraform-example-instance"

    ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 8080
      protocol = "tcp"
      to_port = 8080
    } 
  
}