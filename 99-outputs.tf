//  Output the load balancer DNS.
output "alb_dns" {
  value = ["${aws_alb.cluster-alb.dns_name}"]
}
