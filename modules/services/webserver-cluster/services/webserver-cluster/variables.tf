variable "server_port" {
  description = "example variable"
  type = number
  default = 8080
}
variable "cluster_name" {
  description = "To use for all cluster resources"
  type = string
}
variable "db_remote_state_bucket" {
  description = "S3 bucket for the database's remote state"
  type = string
}
variable "db_remote_state_key" {
  description = "The path for the db remote state in S3"
  type = string
}
variable "instance_type" {
  description = "EC2 instances to run"
  type = string
}
variable "min_size" {
  description = "minimum number of EC2 instances in the ASG"
  type = number
}
variable "max_size" {
  description = "maximum number of EC2 instances in the ASG"
  type = number
}