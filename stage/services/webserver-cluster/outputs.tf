# output "public_ip" {
#   value=aws_instance.example.public_ip
#   description = "ec2-public-ip"
# }
output "alb_dns_name" {
  value=aws_lb.example.dns_name
  description = "alb dns name"
}