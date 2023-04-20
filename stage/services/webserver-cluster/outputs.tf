# output "public_ip" {
#   value=aws_instance.example.public_ip
#   description = "ec2-public-ip"
# }
output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
  description = "alb dns name"
}