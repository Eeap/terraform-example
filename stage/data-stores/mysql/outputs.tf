output "address" {
  value = aws_db_instance.example.address
  description = "Connect to the db"
}
output "port" {
  value = aws_db_instance.example.port
  description = "the db port"
}