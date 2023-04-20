# output "public_ip" {
#   value=aws_instance.example.public_ip
#   description = "ec2-public-ip"
# }
output "alb_dns_name" {
  value=aws_lb.example.dns_name
  description = "alb dns name"
}
output "alb_security_group_id" {
 value = aws_security_group.lb_example_sg.id
 description = "This is security group id of ALB" 
}