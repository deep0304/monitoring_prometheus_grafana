output "public_ip_1" {
  value = aws_instance.nginx_server.public_ip
}
output "public_ip_2" {
  value = aws_instance.server_with_prometheus.public_ip
}